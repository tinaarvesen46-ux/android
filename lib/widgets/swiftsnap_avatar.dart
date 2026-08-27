import 'dart:math' as math;
import 'package:flutter/material.dart';

/// SwiftSnapAvatar — an ORIGINAL, procedurally-drawn avatar (no external/
/// proprietary artwork). It renders a headshot from the backend avatar config
/// map (component IDs like `skin_03`, `hair_02`, `eyes_05`). Every category
/// visibly affects the drawing, so the Studio preview is truly live.
class SwiftSnapAvatar extends StatelessWidget {
  final Map<String, String> config;
  final double size;
  const SwiftSnapAvatar({super.key, required this.config, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AvatarPainter(config)),
    );
  }
}

int _idx(String? id) {
  if (id == null) return 0;
  final m = RegExp(r'(\d+)$').firstMatch(id);
  return m == null ? 0 : int.parse(m.group(1)!);
}

const _skin = [
  Color(0xFFFCE0BD), Color(0xFFF6C89A), Color(0xFFE8B888), Color(0xFFD69C6E),
  Color(0xFFB97C4E), Color(0xFF8D5A34), Color(0xFF6B4326), Color(0xFF4A2E1A),
];
const _hairCol = [
  Color(0xFF2B2B2B), Color(0xFF4A2C13), Color(0xFF6B4226), Color(0xFF8D5A2B),
  Color(0xFFB87333), Color(0xFFD9A441), Color(0xFFE7C56B), Color(0xFFF2E4A9),
  Color(0xFF9E9E9E), Color(0xFFE0E0E0), Color(0xFF7B3FE4), Color(0xFFE0457B),
];
const _eyeCol = [
  Color(0xFF5B3A1E), Color(0xFF7B5230), Color(0xFF3E6B52), Color(0xFF2F7DB0),
  Color(0xFF4A4A4A), Color(0xFF6A4CA0), Color(0xFF2E8B57), Color(0xFF1C1C1C),
];
const _cloth = [
  Color(0xFF7B3FE4), Color(0xFFE0457B), Color(0xFF2F7DB0), Color(0xFF2E8B57),
  Color(0xFFE7A33E), Color(0xFFE24A4A), Color(0xFF3A3A3A), Color(0xFFECECEC),
  Color(0xFF16B5A0), Color(0xFF9E5BF5), Color(0xFFF06292), Color(0xFF546E7A),
];
const _bg = [
  Color(0xFF1E1B2E), Color(0xFF2A1E3F), Color(0xFF1B2E2A), Color(0xFF2E2418),
  Color(0xFF241E2E), Color(0xFF16232E), Color(0xFF2E1620), Color(0xFF20262E),
  Color(0xFF3A2E5A), Color(0xFF102A24),
];

Color _pick(List<Color> p, int i) => p[(i - 1).clamp(0, p.length - 1) % p.length];

class _AvatarPainter extends CustomPainter {
  final Map<String, String> c;
  _AvatarPainter(this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2;
    final p = Paint()..isAntiAlias = true;

    // Background
    p.color = _pick(_bg, _idx(c['background']));
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.12)), p);

    final skin = _pick(_skin, _idx(c['skin']));
    final hairColor = _pick(_hairCol, _idx(c['hair_color']));
    final topColor = _pick(_cloth, _idx(c['top_color']));

    // Shoulders / top
    p.color = topColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.34, h * 0.78, w * 0.68, h * 0.30), Radius.circular(w * 0.16)),
      p,
    );
    // Neck
    p.color = skin.withOpacity(0.95);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.08, h * 0.62, w * 0.16, h * 0.16), Radius.circular(w * 0.04)), p);

    // Face shape (width varies by face id)
    final faceW = w * (0.30 + _idx(c['face']) * 0.012);
    final faceH = h * 0.30;
    final faceCy = h * 0.42;
    p.color = skin;
    // ears
    canvas.drawCircle(Offset(cx - faceW, faceCy + faceH * 0.1), w * 0.045, p);
    canvas.drawCircle(Offset(cx + faceW, faceCy + faceH * 0.1), w * 0.045, p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, faceCy), width: faceW * 2, height: faceH * 2), p);

    // Facial hair (behind mouth, on jaw) — beard_00 = none
    final beard = _idx(c['facialHair']);
    if (beard > 0) {
      p.color = hairColor.withOpacity(0.92);
      final path = Path()
        ..moveTo(cx - faceW * 0.9, faceCy + faceH * 0.2)
        ..quadraticBezierTo(cx, faceCy + faceH * (1.0 + beard * 0.04), cx + faceW * 0.9, faceCy + faceH * 0.2)
        ..quadraticBezierTo(cx, faceCy + faceH * 0.7, cx - faceW * 0.9, faceCy + faceH * 0.2)
        ..close();
      canvas.drawPath(path, p);
      p.color = skin;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, faceCy - faceH * 0.1), width: faceW * 1.9, height: faceH * 1.7), p);
    }

    // Eyebrows (brow id → thickness/tilt)
    final brow = _idx(c['eyebrows']);
    p.color = hairColor;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = w * (0.012 + brow * 0.002);
    p.strokeCap = StrokeCap.round;
    for (final s in [-1, 1]) {
      final ex = cx + s * faceW * 0.42;
      canvas.drawLine(Offset(ex - w * 0.06, faceCy - faceH * 0.28), Offset(ex + w * 0.06, faceCy - faceH * (0.30 + brow * 0.01)), p);
    }
    p.style = PaintingStyle.fill;

    // Eyes (eyes id → size, eye_color)
    final eyeSize = w * (0.03 + _idx(c['eyes']) * 0.004);
    final eyeColor = _pick(_eyeCol, _idx(c['eye_color']));
    for (final s in [-1, 1]) {
      final ex = cx + s * faceW * 0.42;
      final ey = faceCy - faceH * 0.08;
      p.color = Colors.white;
      canvas.drawOval(Rect.fromCenter(center: Offset(ex, ey), width: eyeSize * 2.4, height: eyeSize * 1.8), p);
      p.color = eyeColor;
      canvas.drawCircle(Offset(ex, ey), eyeSize * 0.75, p);
      p.color = Colors.black;
      canvas.drawCircle(Offset(ex, ey), eyeSize * 0.35, p);
    }

    // Nose (nose id → length)
    final nose = _idx(c['nose']);
    p.color = skin.withOpacity(0.0);
    p.style = PaintingStyle.stroke;
    p.color = _darken(skin, 0.18);
    p.strokeWidth = w * 0.012;
    canvas.drawPath(
      Path()
        ..moveTo(cx, faceCy - faceH * 0.02)
        ..lineTo(cx - w * 0.02, faceCy + faceH * (0.12 + nose * 0.015))
        ..lineTo(cx + w * 0.02, faceCy + faceH * (0.12 + nose * 0.015)),
      p,
    );
    p.style = PaintingStyle.fill;

    // Mouth (mouth id → smile/neutral/open)
    final mouth = _idx(c['mouth']);
    final my = faceCy + faceH * 0.42;
    p.color = const Color(0xFFB94A48);
    if (mouth % 3 == 0) {
      // smile
      final path = Path()
        ..moveTo(cx - w * 0.06, my)
        ..quadraticBezierTo(cx, my + h * (0.02 + mouth * 0.002), cx + w * 0.06, my);
      p.style = PaintingStyle.stroke;
      p.strokeWidth = w * 0.02;
      p.strokeCap = StrokeCap.round;
      canvas.drawPath(path, p);
      p.style = PaintingStyle.fill;
    } else if (mouth % 3 == 1) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, my), width: w * 0.10, height: h * 0.018), Radius.circular(w * 0.02)), p);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, my), width: w * 0.08, height: h * 0.05), p);
    }

    // Hair (hair_00 = none) — draw after face, before hat
    final hair = _idx(c['hair']);
    if (hair > 0) {
      p.color = hairColor;
      final style = hair % 5;
      final top = faceCy - faceH * 1.02;
      if (style == 0) {
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, faceCy - faceH * 0.2), width: faceW * 2.2, height: faceH * 2.1), math.pi, math.pi, true, p);
      } else if (style == 1) {
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, top + faceH * 0.2), width: faceW * 2.3, height: faceH * 1.1), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - faceW * 1.05, top + faceH * 0.2, w * 0.06, faceH * 1.2), Radius.circular(w * 0.03)), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + faceW * 0.9, top + faceH * 0.2, w * 0.06, faceH * 1.2), Radius.circular(w * 0.03)), p);
      } else if (style == 2) {
        // spiky
        for (int i = -3; i <= 3; i++) {
          final sx = cx + i * faceW * 0.28;
          final path = Path()
            ..moveTo(sx - faceW * 0.16, faceCy - faceH * 0.7)
            ..lineTo(sx, faceCy - faceH * 1.25)
            ..lineTo(sx + faceW * 0.16, faceCy - faceH * 0.7)
            ..close();
          canvas.drawPath(path, p);
        }
        canvas.drawArc(Rect.fromCenter(center: Offset(cx, faceCy - faceH * 0.5), width: faceW * 2.1, height: faceH * 1.4), math.pi, math.pi, true, p);
      } else if (style == 3) {
        // curly bun
        for (int i = 0; i < 7; i++) {
          final a = math.pi + i * math.pi / 6;
          canvas.drawCircle(Offset(cx + math.cos(a) * faceW, faceCy - faceH * 0.4 + math.sin(a) * faceH * 0.5), w * 0.06, p);
        }
      } else {
        // long hair
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, faceCy - faceH * 0.35), width: faceW * 2.4, height: faceH * 1.6), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - faceW * 1.15, faceCy - faceH * 0.5, w * 0.08, faceH * 2.2), Radius.circular(w * 0.04)), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + faceW * 1.0, faceCy - faceH * 0.5, w * 0.08, faceH * 2.2), Radius.circular(w * 0.04)), p);
        p.color = skin;
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, faceCy + faceH * 0.05), width: faceW * 1.9, height: faceH * 1.9), p);
      }
    }

    // Glasses (glasses_00 = none)
    final glasses = _idx(c['glasses']);
    if (glasses > 0) {
      p.style = PaintingStyle.stroke;
      p.strokeWidth = w * 0.012;
      p.color = glasses % 2 == 0 ? const Color(0xFF222222) : const Color(0xFFB87333);
      final ey = faceCy - faceH * 0.08;
      for (final s in [-1, 1]) {
        final ex = cx + s * faceW * 0.42;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(ex, ey), width: w * 0.13, height: w * 0.11), Radius.circular(w * 0.03)), p);
      }
      canvas.drawLine(Offset(cx - faceW * 0.42 + w * 0.06, ey), Offset(cx + faceW * 0.42 - w * 0.06, ey), p);
      p.style = PaintingStyle.fill;
    }

    // Hat (hat_00 = none)
    final hat = _idx(c['hat']);
    if (hat > 0) {
      p.color = _pick(_cloth, hat);
      final top = faceCy - faceH * 1.0;
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, top + faceH * 0.35), width: faceW * 2.3, height: faceH * 1.5), math.pi, math.pi, true, p);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, top + faceH * 0.35), width: faceW * 2.6, height: h * 0.03), Radius.circular(w * 0.02)), p);
    }

    // Accessories (acc_00 = none) — simple earrings
    if (_idx(c['accessories']) > 0) {
      p.color = const Color(0xFFE7C56B);
      canvas.drawCircle(Offset(cx - faceW, faceCy + faceH * 0.35), w * 0.02, p);
      canvas.drawCircle(Offset(cx + faceW, faceCy + faceH * 0.35), w * 0.02, p);
    }
  }

  Color _darken(Color c, double amt) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amt).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.c.toString() != c.toString();
}
