package com.track60.security;

import com.track60.model.UserDocument;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Map;

@Service
public class JwtService {

    private final SecretKey key;
    private final long expirationMs;
    private final long refreshExpirationMs;

    public JwtService(
            @Value("${track60.jwt.secret}") String secret,
            @Value("${track60.jwt.expiration-ms:86400000}") long expirationMs,
            @Value("${track60.jwt.refresh-expiration-ms:604800000}") long refreshExpirationMs) {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < 32) {
            byte[] padded = new byte[32];
            System.arraycopy(keyBytes, 0, padded, 0, keyBytes.length);
            keyBytes = padded;
        }
        this.key = Keys.hmacShaKeyFor(keyBytes);
        this.expirationMs = expirationMs;
        this.refreshExpirationMs = refreshExpirationMs;
    }

    public String generateAccessToken(UserDocument user) {
        return buildToken(user, expirationMs, "access");
    }

    public String generateRefreshToken(UserDocument user) {
        return buildToken(user, refreshExpirationMs, "refresh");
    }

    private String buildToken(UserDocument user, long ttlMs, String type) {
        Date now = new Date();
        Date exp = new Date(now.getTime() + ttlMs);
        return Jwts.builder()
                .subject(user.getId())
                .claims(Map.of(
                        "cedula", user.getCedula() != null ? user.getCedula() : "",
                        "nombre", user.getNombre() != null ? user.getNombre() : "",
                        "rol", user.getRol() != null ? user.getRol() : "operador",
                        "plantId", user.getPlantId() != null ? user.getPlantId() : "",
                        "type", type
                ))
                .issuedAt(now)
                .expiration(exp)
                .signWith(key)
                .compact();
    }

    public Claims parseClaims(String token) {
        return Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public boolean isValid(String token) {
        try {
            Claims claims = parseClaims(token);
            return claims.getExpiration().after(new Date());
        } catch (Exception e) {
            return false;
        }
    }
}

