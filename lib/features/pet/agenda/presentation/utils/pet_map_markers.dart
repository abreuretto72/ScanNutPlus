import 'dart:ui' as ui;
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PetMapMarkers {
  /// Converte um IconData + Cor em um BitmapDescriptor para o Google Maps
  static Future<BitmapDescriptor> getMarkerIcon(
      IconData iconData, Color color, Color backgroundColor, double size) async {
    
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // 1. Definições de Limites para evitar clipping em altas densidades
    final double radius = size / 2;
    final double strokeWidth = size * 0.10; // Reduzido ligeiramente a borda
    final double drawingRadius = radius - (strokeWidth / 2);

    // 2. Desenha o Círculo de Fundo
    final Paint circlePaint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(radius, radius), drawingRadius, circlePaint);

    // 3. Desenha um contorno branco para contraste
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(radius, radius), drawingRadius, borderPaint);

    // 3. Configura o Ícone de Texto
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size * 0.7, // Ícone ocupa 70% do círculo (era 60%)
        fontFamily: iconData.fontFamily,
        color: color,
        fontWeight: FontWeight.w900, // Força negrito máximo no ícone
      ),
    );

    textPainter.layout();
    
    // 4. Centraliza o Ícone no Círculo
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );

    // 5. Converte para Imagem -> Bytes -> BitmapDescriptor
    final ui.Image image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();

    if (pngBytes == null) {
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(pngBytes);
  }
}
