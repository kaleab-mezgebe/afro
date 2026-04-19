import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';

class MapHelper {
  /// Builds a circular avatar marker with:
  ///  - Provider photo (or initials fallback)
  ///  - Yellow ring border
  ///  - Name label below
  ///  - Star + rating badge
  ///  - Drop shadow
  static Future<BitmapDescriptor> getMarkerIcon(
    String imageUrl,
    Size size, {
    String name = '',
    double rating = 0,
  }) async {
    const double avatarSize = 80.0;
    const double borderWidth = 4.0;
    const double badgeH = 22.0;
    const double labelH = 20.0;
    const double shadowBlur = 8.0;
    const double totalW = avatarSize + shadowBlur * 2;
    const double totalH = avatarSize + badgeH + labelH + shadowBlur * 2 + 4;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final double cx = totalW / 2;
    final double cy = shadowBlur + avatarSize / 2;
    final double r = avatarSize / 2;

    // ── Drop shadow ──────────────────────────────────────────────────────────
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, shadowBlur / 2);
    canvas.drawCircle(Offset(cx, cy + 2), r, shadowPaint);

    // ── White backing circle ─────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);

    // ── Avatar image (clipped to circle) ────────────────────────────────────
    final double innerR = r - borderWidth - 1;
    try {
      final ui.Image img = await _loadNetworkImage(imageUrl);
      final Rect dst = Rect.fromCircle(center: Offset(cx, cy), radius: innerR);
      final Rect src = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );

      canvas.save();
      canvas.clipPath(Path()..addOval(dst));
      canvas.drawImageRect(
        img,
        src,
        dst,
        Paint()..filterQuality = FilterQuality.high,
      );
      canvas.restore();
    } catch (_) {
      // Initials fallback
      canvas.save();
      canvas.clipPath(
        Path()
          ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: innerR)),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        innerR,
        Paint()..color = const Color(0xFF1C1C1E),
      );
      canvas.restore();

      if (name.isNotEmpty) {
        final initials = name
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join();
        _drawText(
          canvas,
          initials,
          Offset(cx, cy),
          fontSize: innerR * 0.65,
          color: Colors.white,
          bold: true,
        );
      }
    }

    // ── Yellow border ring ───────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r - borderWidth / 2,
      Paint()
        ..color = const Color(0xFFFFB900)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // ── Rating badge (bottom-right of circle) ────────────────────────────────
    if (rating > 0) {
      final double bx = cx + r * math.cos(math.pi / 4) - 2;
      final double by = cy + r * math.sin(math.pi / 4) - 2;
      const double bR = 11.0;

      // Badge shadow
      canvas.drawCircle(
        Offset(bx, by + 1),
        bR,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Badge background
      canvas.drawCircle(Offset(bx, by), bR, Paint()..color = Colors.white);
      // Star icon (drawn as text ★)
      _drawText(
        canvas,
        '★',
        Offset(bx - 1, by - 1),
        fontSize: 8,
        color: const Color(0xFFFFB900),
      );
      _drawText(
        canvas,
        rating.toStringAsFixed(1),
        Offset(bx + 5, by),
        fontSize: 7,
        color: const Color(0xFF1C1C1E),
        bold: true,
      );
    }

    // ── Name label below circle ──────────────────────────────────────────────
    if (name.isNotEmpty) {
      final String displayName = name.length > 14
          ? '${name.substring(0, 13)}…'
          : name;

      // Pill background
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: displayName,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double pillW = tp.width + 16;
      final double pillH = 18;
      final double pillX = cx - pillW / 2;
      final double pillY = cy + r + 6;

      final RRect pillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillY, pillW, pillH),
        const Radius.circular(9),
      );

      // Pill shadow
      canvas.drawRRect(
        pillRRect.shift(const Offset(0, 1)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Pill fill
      canvas.drawRRect(pillRRect, Paint()..color = const Color(0xFF1C1C1E));

      // Pill text
      tp.paint(canvas, Offset(pillX + 8, pillY + (pillH - tp.height) / 2));
    }

    final ui.Image markerImg = await recorder.endRecording().toImage(
      totalW.toInt(),
      totalH.toInt(),
    );
    final ByteData? byteData = await markerImg.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static Future<ui.Image> _loadNetworkImage(String url) async {
    final Completer<ui.Image> completer = Completer();
    final ImageStream stream = NetworkImage(
      url,
    ).resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (_, __) {
        if (!completer.isCompleted) completer.completeError('load failed');
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future.timeout(const Duration(seconds: 5));
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    required double fontSize,
    required Color color,
    bool bold = false,
  }) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
