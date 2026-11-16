package com.track60.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.track60.model.AccessLogDocument;
import com.track60.model.UserDocument;
import com.track60.repository.AccessLogRepository;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
@RequiredArgsConstructor
public class AccessLogService {

    private final AccessLogRepository accessLogRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofMillis(1200))
            .build();

    public void recordAttempt(
            HttpServletRequest request,
            String rawIdentifier,
            UserDocument user,
            boolean success,
            String failureReason
    ) {
        try {
            final String ip = extractClientIp(request);
            final String ua = request != null ? safeHeader(request, "User-Agent") : "";
            final ParsedAgent agent = parseUserAgent(ua);
            final String safeIdentifier = maskIdentifier(rawIdentifier, user);
            final String userId = user != null ? user.getId() : null;
            final String userNombre = user != null ? user.getNombre() : "Desconocido";
            final String rol = user != null ? user.getRol() : null;
            final String plantId = user != null ? user.getPlantId() : null;

            CompletableFuture.runAsync(() -> {
                try {
                    GeoInfo geo = resolveGeo(ip);
                    AccessLogDocument entry = AccessLogDocument.builder()
                            .userId(userId)
                            .userNombre(userNombre)
                            .identifier(safeIdentifier)
                            .rol(rol)
                            .plantId(plantId)
                            .success(success)
                            .failureReason(failureReason)
                            .ipAddress(ip)
                            .city(geo.city)
                            .region(geo.region)
                            .country(geo.country)
                            .isp(geo.isp)
                            .deviceType(agent.deviceType)
                            .os(agent.os)
                            .browser(agent.browser)
                            .userAgent(ua.length() > 300 ? ua.substring(0, 300) : ua)
                            .build();
                    accessLogRepository.save(entry);
                } catch (Exception e) {
                    log.warn("No se pudo guardar access_log async: {}", e.getMessage());
                }
            });
        } catch (Exception e) {
            log.warn("No se pudo iniciar access_log: {}", e.getMessage());
        }
    }

    public List<AccessLogDocument> getRecentLogs() {
        return accessLogRepository.findTop200ByOrderByCreatedAtDesc();
    }

    private String maskIdentifier(String rawIdentifier, UserDocument user) {
        if (user != null) {
            return user.getCedula() != null && !user.getCedula().isBlank()
                    ? user.getCedula()
                    : user.getId();
        }
        if (rawIdentifier == null || rawIdentifier.isBlank()) return "-";
        String trimmed = rawIdentifier.trim();
        if (trimmed.length() <= 6) {
            return trimmed.substring(0, Math.min(2, trimmed.length())) + "****";
        }
        return trimmed;
    }

    public String extractClientIp(HttpServletRequest request) {
        if (request == null) return "unknown";
        String xff = safeHeader(request, "X-Forwarded-For");
        if (!xff.isBlank()) {
            String first = xff.split(",")[0].trim();
            if (!first.isBlank()) return first;
        }
        String realIp = safeHeader(request, "X-Real-IP");
        if (!realIp.isBlank()) return realIp.trim();
        return request.getRemoteAddr() != null ? request.getRemoteAddr() : "unknown";
    }

    private String safeHeader(HttpServletRequest request, String name) {
        String val = request.getHeader(name);
        return val != null ? val : "";
    }

    private GeoInfo resolveGeo(String ip) {
        if (ip == null || ip.isBlank() || isPrivateIp(ip)) {
            return new GeoInfo("Red Local", "Local", "Local", "Red Interna");
        }
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("http://ip-api.com/json/" + ip + "?fields=status,country,regionName,city,isp"))
                    .timeout(Duration.ofMillis(1400))
                    .GET()
                    .build();
            HttpResponse<String> resp = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() == 200 && resp.body() != null) {
                JsonNode root = objectMapper.readTree(resp.body());
                if ("success".equalsIgnoreCase(root.path("status").asText())) {
                    return new GeoInfo(
                            root.path("city").asText("Desconocida"),
                            root.path("regionName").asText(""),
                            root.path("country").asText(""),
                            root.path("isp").asText("")
                    );
                }
            }
        } catch (Exception ignored) {
            // Nunca bloquear el login si la geolocalización externa falla o expira
        }
        return new GeoInfo("Desconocida", "", "", "");
    }

    private boolean isPrivateIp(String ip) {
        return ip.equals("127.0.0.1")
                || ip.equals("::1")
                || ip.equals("0:0:0:0:0:0:0:1")
                || ip.startsWith("10.")
                || ip.startsWith("192.168.")
                || ip.startsWith("172.16.")
                || ip.startsWith("172.17.")
                || ip.startsWith("172.18.")
                || ip.startsWith("172.19.")
                || ip.startsWith("172.2")
                || ip.startsWith("172.30.")
                || ip.startsWith("172.31.")
                || ip.equals("unknown");
    }

    private ParsedAgent parseUserAgent(String ua) {
        if (ua == null || ua.isBlank()) {
            return new ParsedAgent("Desconocido", "Desconocido", "Desconocido");
        }
        String lower = ua.toLowerCase();

        String deviceType = "Escritorio / PC";
        if (lower.contains("dart/") || lower.contains("okhttp")) {
            deviceType = "App Móvil (APK)";
        } else if (lower.contains("iphone") || lower.contains("ipad") || lower.contains("mobile") || lower.contains("android")) {
            deviceType = lower.contains("ipad") || lower.contains("tablet") ? "Tablet" : "Teléfono Móvil";
        }

        String os = "Otro";
        if (lower.contains("android")) os = "Android";
        else if (lower.contains("iphone") || lower.contains("ipad") || lower.contains("ios")) os = "iOS / iPadOS";
        else if (lower.contains("windows")) os = "Windows";
        else if (lower.contains("mac os") || lower.contains("macintosh")) os = "macOS";
        else if (lower.contains("linux")) os = "Linux";

        String browser = "Navegador";
        if (lower.contains("dart/") || lower.contains("okhttp")) browser = "App Nativa Flutter";
        else if (lower.contains("edg/")) browser = "Microsoft Edge";
        else if (lower.contains("opr/") || lower.contains("opera")) browser = "Opera";
        else if (lower.contains("chrome") && !lower.contains("edg")) browser = "Google Chrome";
        else if (lower.contains("safari") && !lower.contains("chrome")) browser = "Safari";
        else if (lower.contains("firefox")) browser = "Firefox";

        return new ParsedAgent(deviceType, os, browser);
    }

    private record GeoInfo(String city, String region, String country, String isp) {}
    private record ParsedAgent(String deviceType, String os, String browser) {}
}

