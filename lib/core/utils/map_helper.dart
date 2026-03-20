import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';

class MapHelper {
  static Future<BitmapDescriptor> getMarkerIcon(String url, Size size) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double radius = size.width / 2;

    // Draw circular background
    final Paint paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    // Add border
    final Paint borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(radius, radius), radius - 2, borderPaint);

    // Draw avatar
    try {
      final Completer<ui.Image> completer = Completer();
      final ImageStream stream = NetworkImage(url).resolve(ImageConfiguration.empty);
      stream.addListener(ImageStreamListener((ImageInfo image, bool synchronousCall) {
        completer.complete(image.image);
      }));
      final ui.Image image = await completer.future;

      Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
      Rect imageRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
      
      canvas.clipPath(Path()..addOval(rect.deflate(6)));
      canvas.drawImageRect(image, imageRect, rect.deflate(6), Paint());
    } catch (e) {
      // Fallback if image fails to load
      final Paint fallbackPaint = Paint()..color = Colors.grey;
      canvas.drawCircle(Offset(radius, radius), radius - 6, fallbackPaint);
    }

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
    final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}
