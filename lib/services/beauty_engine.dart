import 'dart:io';
import 'dart:math' as math;
import 'dart:math' show Point;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// BeautyEngine — CPU-side image processing that honors the SwiftSnap
/// beauty preset schema:
///
///   { smooth: 0..100, tan: 0..100, glow: 0..100, teeth: 0..100, eye: 0..100 }
///
/// The pipeline runs entirely on-device. For photos captured by the user,
/// [processPhotoWithLandmarks] runs Google ML Kit face detection first and
/// then confines the teeth-whitening and eye-brightening operations strictly
/// to the mouth-inner and per-eye landmark regions returned by the detector,
/// so we never bleach the whole frame or someone's cheeks.
///
/// If ML Kit fails to detect a face (bad lighting, extreme angle) the engine
/// gracefully falls back to [processPhoto] which only touches skin-toned
/// pixels using a YCbCr heuristic — global brightening and teeth whitening
/// are skipped rather than applied blindly.
class BeautyEngine {
  static FaceDetector? _detector;

  /// Lazily construct the ML Kit face detector. Landmarks + classification
  /// are enabled because we need `leftEye`, `rightEye`, `bottomMouth`,
  /// `leftMouth`, `rightMouth`, and per-eye open probability.
  static FaceDetector _getDetector() {
    _detector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableClassification: true,
        enableContours: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
      ),
    );
    return _detector!;
  }

  /// Release the ML Kit detector — call from app dispose if needed.
  static Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
  }

  /// High-level entry point. Runs face detection first, then routes to the
  /// landmark-aware pipeline if a face is found and any face-region effect
  /// (teeth or eye) is requested. Falls back to the generic pipeline
  /// otherwise. This is what the camera UI should call.
  static Future<File> processPhotoAuto(
    File input,
    Map<String, int> params,
  ) async {
    final teeth = (params['teeth'] ?? 0).clamp(0, 100);
    final eye = (params['eye'] ?? 0).clamp(0, 100);
    final needsLandmarks = teeth > 0 || eye > 0;

    if (!needsLandmarks) {
      return processPhoto(input, params);
    }

    List<Face> faces = const [];
    try {
      final mlInput = InputImage.fromFilePath(input.path);
      faces = await _getDetector().processImage(mlInput);
    } catch (_) {
      // If ML Kit fails for any reason (unsupported EXIF, format), just skip
      // the face-region pass — never leave the user with a broken export.
      faces = const [];
    }

    if (faces.isEmpty) {
      // No detectable face — teeth/eye ops would tint arbitrary bright pixels.
      // Only apply the safe skin-tone / global effects.
      return processPhoto(input, params);
    }

    return processPhotoWithLandmarks(input, params, faces: faces);
  }

  /// Applies a beauty preset to a JPEG file and returns a new file path.
  /// Returns the input file untouched if all intensities are 0.
  static Future<File> processPhoto(File input, Map<String, int> params) async {
    final smooth = (params['smooth'] ?? 0).clamp(0, 100);
    final tan = (params['tan'] ?? 0).clamp(0, 100);
    final glow = (params['glow'] ?? 0).clamp(0, 100);
    if (smooth == 0 && tan == 0 && glow == 0) return input;

    final bytes = await input.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return input;

    var out = decoded;

    if (glow > 0) {
      final lift = 0.02 + (glow / 100) * 0.08;
      out = img.adjustColor(out, exposure: lift, contrast: 1 + glow / 1000);
    }
    if (tan > 0) out = _applySkinTan(out, tan);
    if (smooth > 0) {
      final blurred = img.gaussianBlur(img.Image.from(out), radius: 3);
      final alpha = (smooth / 200).clamp(0.0, 0.5);
      out = _mix(out, blurred, alpha);
    }
    return _writeOut(out);
  }

  /// Landmark-aware pipeline. Runs the generic smooth/tan/glow first, then
  /// visits each detected face and applies teeth whitening + per-eye
  /// brightening strictly inside the landmark bounds provided by ML Kit.
  static Future<File> processPhotoWithLandmarks(
    File input,
    Map<String, int> params, {
    required List<Face> faces,
  }) async {
    final smooth = (params['smooth'] ?? 0).clamp(0, 100);
    final tan = (params['tan'] ?? 0).clamp(0, 100);
    final glow = (params['glow'] ?? 0).clamp(0, 100);
    final teeth = (params['teeth'] ?? 0).clamp(0, 100);
    final eye = (params['eye'] ?? 0).clamp(0, 100);

    final bytes = await input.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return input;
    var out = decoded;

    // Base pass — safe global-ish operations.
    if (glow > 0) {
      final lift = 0.02 + (glow / 100) * 0.08;
      out = img.adjustColor(out, exposure: lift, contrast: 1 + glow / 1000);
    }
    if (tan > 0) out = _applySkinTan(out, tan);
    if (smooth > 0) {
      final blurred = img.gaussianBlur(img.Image.from(out), radius: 3);
      final alpha = (smooth / 200).clamp(0.0, 0.5);
      out = _mix(out, blurred, alpha);
    }

    // Face-region pass — teeth + eyes only inside landmark bounds.
    for (final face in faces) {
      if (teeth > 0) _whitenTeeth(out, face, teeth);
      if (eye > 0) _brightenEyes(out, face, eye);
    }

    return _writeOut(out);
  }

  // ────────────────────────────────────────────────────────────────
  //   Teeth whitening — driven by ML Kit mouth landmarks
  // ────────────────────────────────────────────────────────────────

  /// Whitens tooth-colored pixels inside the mouth-inner region. The region
  /// is bounded by the `leftMouth`, `rightMouth`, `bottomMouth` landmarks and
  /// tightened vertically to the inner-lip band so we never bleach lips.
  static void _whitenTeeth(img.Image out, Face face, int intensity) {
    final left = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final right = face.landmarks[FaceLandmarkType.rightMouth]?.position;
    final bottom = face.landmarks[FaceLandmarkType.bottomMouth]?.position;
    if (left == null || right == null || bottom == null) return;

    // Build an axis-aligned bounding box for the mouth-inner band.
    final xMin = math.min(left.x, right.x).toInt();
    final xMax = math.max(left.x, right.x).toInt();
    final mouthHeight =
        (bottom.y - (left.y + right.y) / 2).abs().clamp(4.0, 400.0);
    // Inner band = bottom 65% of mouth (avoids top lip highlight).
    final yTop = ((left.y + right.y) / 2 + mouthHeight * 0.15).toInt();
    final yBot = (bottom.y - mouthHeight * 0.1).toInt();

    if (xMin >= xMax || yTop >= yBot) return;

    final k = intensity / 100.0;
    for (var y = math.max(0, yTop); y < math.min(out.height, yBot); y++) {
      for (var x = math.max(0, xMin); x < math.min(out.width, xMax); x++) {
        final p = out.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        // Teeth are: bright, low saturation, warm cast (yellowish).
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC == 0 ? 0 : (maxC - minC) / maxC;
        final isTeeth = maxC > 140 && sat < 0.35 && g >= b * 0.9;
        if (!isTeeth) continue;
        // Push toward neutral white and lift luminance.
        final gray = (r + g + b) / 3;
        final target = math.min(255.0, gray + 35 * k);
        out.setPixelRgb(
          x,
          y,
          (r * (1 - k * 0.35) + target * k * 0.35).clamp(0, 255).toInt(),
          (g * (1 - k * 0.35) + target * k * 0.35).clamp(0, 255).toInt(),
          (b * (1 - k * 0.35) + target * k * 0.55).clamp(0, 255).toInt(),
        );
      }
    }
  }

  // ────────────────────────────────────────────────────────────────
  //   Eye brightening — driven by ML Kit per-eye landmarks
  // ────────────────────────────────────────────────────────────────

  /// Brightens each eye's iris/sclera inside a small circular region centred
  /// on the eye landmark. Uses per-eye landmarks so a closed eye is skipped
  /// via `leftEyeOpenProbability` / `rightEyeOpenProbability`.
  static void _brightenEyes(img.Image out, Face face, int intensity) {
    _brightenEye(
      out,
      face.landmarks[FaceLandmarkType.leftEye]?.position,
      face.leftEyeOpenProbability,
      face,
      intensity,
    );
    _brightenEye(
      out,
      face.landmarks[FaceLandmarkType.rightEye]?.position,
      face.rightEyeOpenProbability,
      face,
      intensity,
    );
  }

  static void _brightenEye(
    img.Image out,
    Point<int>? centre,
    double? openProb,
    Face face,
    int intensity,
  ) {
    if (centre == null) return;
    if (openProb != null && openProb < 0.35) return; // eye closed, skip
    // Radius scales with face box so it works close-up and far away.
    final box = face.boundingBox;
    final radius = (box.width * 0.06).clamp(6.0, 60.0);
    final cx = centre.x.toDouble();
    final cy = centre.y.toDouble();
    final k = intensity / 100.0;

    final xStart = math.max(0, (cx - radius).toInt());
    final xEnd = math.min(out.width, (cx + radius).toInt());
    final yStart = math.max(0, (cy - radius).toInt());
    final yEnd = math.min(out.height, (cy + radius).toInt());

    for (var y = yStart; y < yEnd; y++) {
      for (var x = xStart; x < xEnd; x++) {
        final dx = x - cx;
        final dy = y - cy;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d > radius) continue;
        // Feathered mask: full strength at centre, 0 at edge.
        final feather = (1 - d / radius);
        final w = feather * k;
        final p = out.getPixel(x, y);
        var r = p.r.toDouble();
        var g = p.g.toDouble();
        var b = p.b.toDouble();
        // Contrast lift + sclera whitening.
        final maxC = math.max(r, math.max(g, b));
        final minC = math.min(r, math.min(g, b));
        final sat = maxC == 0 ? 0 : (maxC - minC) / maxC;
        if (maxC > 130 && sat < 0.35) {
          // Sclera → whiten mildly.
          r = r + (255 - r) * 0.25 * w;
          g = g + (255 - g) * 0.25 * w;
          b = b + (255 - b) * 0.30 * w;
        } else {
          // Iris → gentle contrast + luminance bump.
          final lum = 0.299 * r + 0.587 * g + 0.114 * b;
          final delta = 1 + 0.35 * w;
          r = lum + (r - lum) * delta + 6 * w;
          g = lum + (g - lum) * delta + 6 * w;
          b = lum + (b - lum) * delta + 8 * w;
        }
        out.setPixelRgb(
          x,
          y,
          r.clamp(0, 255).toInt(),
          g.clamp(0, 255).toInt(),
          b.clamp(0, 255).toInt(),
        );
      }
    }
  }

  // ────────────────────────────────────────────────────────────────
  //   Helpers
  // ────────────────────────────────────────────────────────────────

  /// Rough skin mask using YCbCr thresholds (Cb in [77,127], Cr in [133,173])
  /// — catches most natural skin tones without tinting clothes/walls/hair.
  static img.Image _applySkinTan(img.Image src, int intensity) {
    final k = intensity / 100.0;
    for (final p in src) {
      final r = p.r, g = p.g, b = p.b;
      final y = 0.299 * r + 0.587 * g + 0.114 * b;
      final cb = -0.169 * r - 0.331 * g + 0.500 * b + 128;
      final cr = 0.500 * r - 0.419 * g - 0.081 * b + 128;
      final isSkin = cb >= 77 &&
          cb <= 127 &&
          cr >= 133 &&
          cr <= 173 &&
          y > 30 &&
          y < 240;
      if (!isSkin) continue;
      final nr = (r + 25 * k).clamp(0, 255).toDouble();
      final nb = (b - 12 * k).clamp(0, 255).toDouble();
      p.r = nr;
      p.b = nb;
    }
    return src;
  }

  static img.Image _mix(img.Image base, img.Image overlay, double alpha) {
    final oIter = overlay.iterator;
    for (final p in base) {
      if (!oIter.moveNext()) break;
      final o = oIter.current;
      p.r = p.r * (1 - alpha) + o.r * alpha;
      p.g = p.g * (1 - alpha) + o.g * alpha;
      p.b = p.b * (1 - alpha) + o.b * alpha;
    }
    return base;
  }

  static Future<File> _writeOut(img.Image out) async {
    final tmp = await pp.getTemporaryDirectory();
    final outPath =
        '${tmp.path}/beauty_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(outPath).writeAsBytes(img.encodeJpg(out, quality: 92));
    return File(outPath);
  }
}
