import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;
  final image = img.Image(width: size, height: size);

  // Colores corporativos Darnel
  // #002F6C = R: 0, G: 47, B: 108
  // #0095D9 = R: 0, G: 149, B: 217
  // Blanco = R: 255, G: 255, B: 255
  final cAzul = img.ColorRgba8(0, 47, 108, 255);
  final cAzulClaro = img.ColorRgba8(0, 149, 217, 255);
  final cBlanco = img.ColorRgba8(255, 255, 255, 255);
  final cVerde = img.ColorRgba8(22, 163, 74, 255);
  final cSombra = img.ColorRgba8(0, 20, 60, 255);

  // 1. Fondo: Degradado corporativo de Azul Oscuro (#002F6C) a Azul Acento (#0095D9)
  for (int y = 0; y < size; y++) {
    final double t = y / size;
    final int r = ((1 - t) * 0 + t * 0).round();
    final int g = ((1 - t) * 47 + t * 149).round();
    final int b = ((1 - t) * 108 + t * 217).round();
    final col = img.ColorRgba8(r, g, b, 255);
    for (int x = 0; x < size; x++) {
      image.setPixel(x, y, col);
    }
  }

  // 2. Tarjeta Central / Portapapeles Ejecutivo (Standard Work Board)
  const int cardL = 200;
  const int cardR = 824;
  const int cardT = 180;
  const int cardB = 860;

  // Sombra de la tarjeta
  img.fillRect(image,
      x1: cardL + 12, y1: cardT + 18, x2: cardR + 12, y2: cardB + 18,
      color: cSombra);

  // Tarjeta blanca principal
  img.fillRect(image,
      x1: cardL, y1: cardT, x2: cardR, y2: cardB,
      color: cBlanco);

  // 3. Clip Superior del Portapapeles (Identidad Operativa)
  const int clipL = 380;
  const int clipR = 644;
  const int clipT = 140;
  const int clipB = 220;
  img.fillRect(image,
      x1: clipL, y1: clipT, x2: clipR, y2: clipB,
      color: cAzul);
  // Pequeño orificio central del clip
  img.fillCircle(image, x: 512, y: 175, radius: 14, color: cBlanco);

  // 4. Filas de Tareas Estándar (Checklist con Checks de Verificación)
  _drawCheckItem(image, yCenter: 320, isChecked: true, checkColor: cVerde, barColor: cAzul);
  _drawCheckItem(image, yCenter: 440, isChecked: true, checkColor: cVerde, barColor: cAzul);
  _drawCheckItem(image, yCenter: 560, isChecked: true, checkColor: cAzulClaro, barColor: cAzul);

  // 5. Monograma "SW" en la parte inferior del portapapeles
  const int badgeL = 360;
  const int badgeR = 664;
  const int badgeT = 670;
  const int badgeB = 760;
  img.fillRect(image,
      x1: badgeL, y1: badgeT, x2: badgeR, y2: badgeB,
      color: cAzul);

  // Letras SW centrales en blanco
  // Dibujar 'S'
  _drawLetterS(image, startX: 430, startY: 690, color: cBlanco);
  // Dibujar 'W'
  _drawLetterW(image, startX: 520, startY: 690, color: cBlanco);

  // Exportar el Master Icon a 1024x1024
  final masterFile = File('assets/icon/app_icon_master.png');
  masterFile.parent.createSync(recursive: true);
  masterFile.writeAsBytesSync(img.encodePng(image));
  print('Master icon generated: ${masterFile.path}');

  // 6. Generar las distintas densidades para Android mipmap
  final densities = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in densities.entries) {
    final resized = img.copyResize(image, width: entry.value, height: entry.value, interpolation: img.Interpolation.cubic);
    final targetPath = 'android/app/src/main/res/${entry.key}/ic_launcher.png';
    File(targetPath).writeAsBytesSync(img.encodePng(resized));
    print('Generated: $targetPath (${entry.value}x${entry.value})');
  }

  // 7. Generar Imagen para Splash Screen (Launch Image)
  for (final entry in densities.entries) {
    final scale = entry.value / 48.0;
    final sSize = (64 * scale).round();
    final sImg = img.copyResize(image, width: sSize, height: sSize, interpolation: img.Interpolation.cubic);
    final sPath = 'android/app/src/main/res/${entry.key}/launch_image.png';
    File(sPath).writeAsBytesSync(img.encodePng(sImg));
    print('Splash launch image generated: $sPath');
  }
}

void _drawLetterS(img.Image image, {required int startX, required int startY, required img.Color color}) {
  img.fillRect(image, x1: startX, y1: startY, x2: startX + 40, y2: startY + 8, color: color); // barra superior
  img.fillRect(image, x1: startX, y1: startY, x2: startX + 8, y2: startY + 25, color: color); // lado sup izq
  img.fillRect(image, x1: startX, y1: startY + 22, x2: startX + 40, y2: startY + 30, color: color); // barra media
  img.fillRect(image, x1: startX + 32, y1: startY + 25, x2: startX + 40, y2: startY + 50, color: color); // lado inf der
  img.fillRect(image, x1: startX, y1: startY + 44, x2: startX + 40, y2: startY + 52, color: color); // barra inferior
}

void _drawLetterW(img.Image image, {required int startX, required int startY, required img.Color color}) {
  img.fillRect(image, x1: startX, y1: startY, x2: startX + 8, y2: startY + 52, color: color); // col 1
  img.fillRect(image, x1: startX + 18, y1: startY + 20, x2: startX + 26, y2: startY + 52, color: color); // col medio
  img.fillRect(image, x1: startX + 36, y1: startY, x2: startX + 44, y2: startY + 52, color: color); // col 3
  img.fillRect(image, x1: startX, y1: startY + 44, x2: startX + 44, y2: startY + 52, color: color); // base
}

void _drawCheckItem(img.Image image, {
  required int yCenter,
  required bool isChecked,
  required img.Color checkColor,
  required img.Color barColor,
}) {
  // Checkbox redondo
  const int boxX = 290;
  img.fillCircle(image, x: boxX, y: yCenter, radius: 36, color: checkColor);

  // Marca de verificación interna blanca en V (Checkmark)
  final cWhite = img.ColorRgba8(255, 255, 255, 255);
  for (int i = 0; i <= 14; i++) {
    for (int t = -3; t <= 3; t++) {
      image.setPixel(boxX - 16 + i + t, yCenter - 2 + i, cWhite);
    }
  }
  for (int i = 0; i <= 28; i++) {
    for (int t = -3; t <= 3; t++) {
      image.setPixel(boxX - 2 + i + t, yCenter + 12 - i, cWhite);
    }
  }

  // Barra de texto de actividad
  img.fillRect(image,
      x1: 360, y1: yCenter - 14, x2: 720, y2: yCenter + 14,
      color: barColor);
}
