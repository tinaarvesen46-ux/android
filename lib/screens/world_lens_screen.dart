import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as v64;

import 'package:ar_flutter_plugin_plus/widgets/ar_view.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_plus/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_plus/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_plus/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_plus/models/ar_node.dart';

/// WorldLensScreen — real AR (ARCore/ARKit) rendering of imported World lenses.
///
/// Two big improvements over v7:
///   1. Uses `ar_flutter_plugin_plus` — the actively-maintained fork that
///      still resolves on pub.dev (the *_updated fork was yanked).
///   2. **AR Sticker Baking** — each `type=sticker` object with a PNG
///      `asset_url` is baked into a runtime-generated GLB flat billboard
///      via [_bakeStickerGlb] and cached to app storage.  ARCore/ARKit
///      renders the actual sticker instead of the placeholder Duck.
class WorldLensScreen extends StatefulWidget {
  const WorldLensScreen({super.key, required this.sceneJson, required this.lensName});
  final Map<String, dynamic> sceneJson;
  final String lensName;

  @override
  State<WorldLensScreen> createState() => _WorldLensScreenState();
}

class _WorldLensScreenState extends State<WorldLensScreen> {
  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARAnchorManager? _anchors;
  final List<ARAnchor> _placed = [];
  final Map<String, String> _bakedCache = {}; // pngUrl -> local GLB path
  int _spawnCursor = 0;
  bool _arReady = false;
  bool _baking = false;
  String? _arError;

  List<Map<String, dynamic>> get _worldObjects {
    final scene = widget.sceneJson['scene'] as Map? ?? const {};
    final objs = (scene['objects'] as List?) ?? const [];
    return objs.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  Future<void> _onArViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _session = sessionManager;
    _objects = objectManager;
    _anchors = anchorManager;
    try {
      await _session!.onInitialize(
        showFeaturePoints: false,
        showPlanes: true,
        showWorldOrigin: false,
        handleTaps: true,
        handlePans: false,
        handleRotation: false,
      );
      await _objects!.onInitialize();
      _session!.onPlaneOrPointTap = _onPlaneTap;
      // Pre-bake stickers so the first tap doesn't stall.
      unawaited(_preBakeAll());
      if (mounted) setState(() => _arReady = true);
    } catch (e) {
      if (mounted) setState(() => _arError = e.toString());
    }
  }

  Future<void> _preBakeAll() async {
    if (_baking) return;
    if (mounted) setState(() => _baking = true);
    for (final o in _worldObjects) {
      final url = _stickerUrl(o);
      if (url != null && !_bakedCache.containsKey(url)) {
        try {
          final path = await _bakeStickerGlb(url);
          _bakedCache[url] = path;
        } catch (_) { /* fall back to placeholder on tap */ }
      }
    }
    if (mounted) setState(() => _baking = false);
  }

  String? _stickerUrl(Map<String, dynamic> o) {
    final t = (o['type'] ?? '').toString();
    if (t != 'sticker') return null;
    final u = (o['asset_url'] ?? o['external_url'] ?? '').toString();
    return u.isEmpty ? null : u;
  }

  Future<void> _onPlaneTap(List<ARHitTestResult> hits) async {
    if (hits.isEmpty || _objects == null || _anchors == null) return;
    final planeHits = hits.where((h) => h.type == ARHitTestResultType.plane).toList();
    if (planeHits.isEmpty) return;
    final tap = planeHits.first;
    final objs = _worldObjects;
    if (objs.isEmpty) return;
    // Cycle through the imported objects so repeated taps place different
    // stickers.  Matches Snap's "place multiple" UX.
    final spec = objs[_spawnCursor % objs.length];
    _spawnCursor++;

    final anchor = ARPlaneAnchor(transformation: tap.worldTransform);
    final anchored = await _anchors!.addAnchor(anchor);
    if (anchored != true) return;
    _placed.add(anchor);

    final url = _stickerUrl(spec);
    if (url == null) return;

    // Prefer the runtime-baked GLB.  If baking failed (offline, corrupt PNG)
    // fall back to a shipped 1×1 white billboard so the object at least
    // renders as a placeholder square at the tap location.
    String? bakedPath = _bakedCache[url];
    if (bakedPath == null) {
      try {
        bakedPath = await _bakeStickerGlb(url);
        _bakedCache[url] = bakedPath;
      } catch (_) { bakedPath = null; }
    }

    final s = (spec['scale'] as num? ?? 0.25).toDouble();
    final rot = ((spec['rotation'] as num? ?? 0).toDouble()) * math.pi / 180;
    final node = ARNode(
      type: NodeType.localGLTF2,
      uri: bakedPath ?? (await _fallbackPlaceholderPath()),
      scale: v64.Vector3(s, s, s),
      position: v64.Vector3(0, 0, 0),
      rotation: v64.Vector4(0, 1, 0, rot),
    );
    await _objects!.addNode(node, planeAnchor: anchor);
  }

  Future<void> _clearAll() async {
    for (final a in _placed) {
      await _anchors?.removeAnchor(a);
    }
    _placed.clear();
    if (mounted) setState(() {});
  }

  // ────────────────────────────────────────────────────────────────
  //   GLB baker
  //
  //   Builds a minimal glTF-Binary (`.glb`) file at runtime that draws a
  //   1 × 1 quad textured with the sticker PNG.  This lets ARCore/ARKit
  //   render the actual imported artwork as a flat billboard on the
  //   detected plane — no placeholder duck required.
  //
  //   glTF spec: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html
  //   GLB       : https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#binary-gltf-layout
  //
  //   We keep everything CPU-side (no shaders, no meshes to serialise on
  //   disk), just a fixed vertex/index/UV buffer stored in-line + the PNG.
  // ────────────────────────────────────────────────────────────────

  Future<String> _bakeStickerGlb(String pngUrl) async {
    final tmp = await getTemporaryDirectory();
    // Fetch PNG.
    final Uint8List pngBytes;
    if (pngUrl.startsWith('http')) {
      final r = await http.get(Uri.parse(pngUrl));
      if (r.statusCode != 200) throw Exception('sticker fetch ${r.statusCode}');
      pngBytes = r.bodyBytes;
    } else if (pngUrl.startsWith('/api/')) {
      // Auth-scoped raw asset endpoint — not reachable without token; caller
      // should have provided a signed external_url.  Fail loudly.
      throw Exception('cannot bake private asset URL: $pngUrl');
    } else {
      pngBytes = await File(pngUrl).readAsBytes();
    }

    // Vertex data — a 1×1 quad on the XZ plane so it lays flat on tables.
    //   3 floats/pos × 4 verts + 2 floats/uv × 4 verts = (12+8)×4 = 80 bytes
    final positions = <double>[
      -0.5, 0.0,  0.5,   0.5, 0.0,  0.5,
      -0.5, 0.0, -0.5,   0.5, 0.0, -0.5,
    ];
    final uvs = <double>[
      0.0, 1.0,   1.0, 1.0,
      0.0, 0.0,   1.0, 0.0,
    ];
    final indices = <int>[0, 1, 2, 2, 1, 3];

    final vertBuf = _floatsToBytes(positions);
    final uvBuf   = _floatsToBytes(uvs);
    final idxBuf  = _ushortsToBytes(indices);

    // GLB binary buffer = verts || uvs || indices || pngBytes (each 4-byte aligned).
    final bin = BytesBuilder();
    bin.add(vertBuf);       final vertLen = vertBuf.length;
    bin.add(uvBuf);         final uvLen = uvBuf.length;
    bin.add(idxBuf);        final idxLen = idxBuf.length;
    // Pad to 4 bytes before PNG (glTF spec).
    while (bin.length % 4 != 0) bin.addByte(0);
    final imgOffset = bin.length;
    bin.add(pngBytes);
    while (bin.length % 4 != 0) bin.addByte(0);
    final binBytes = bin.toBytes();

    final gltf = <String, dynamic>{
      'asset': {'version': '2.0', 'generator': 'SwiftSnap AR Sticker Baker'},
      'scene': 0,
      'scenes': [{'nodes': [0]}],
      'nodes': [{'mesh': 0}],
      'meshes': [{
        'primitives': [{
          'attributes': {'POSITION': 0, 'TEXCOORD_0': 1},
          'indices': 2,
          'material': 0,
        }],
      }],
      'materials': [{
        'pbrMetallicRoughness': {
          'baseColorTexture': {'index': 0},
          'metallicFactor': 0.0,
          'roughnessFactor': 1.0,
        },
        'alphaMode': 'BLEND',
        'doubleSided': true,
      }],
      'textures': [{'source': 0, 'sampler': 0}],
      'samplers': [{'magFilter': 9729, 'minFilter': 9987, 'wrapS': 33071, 'wrapT': 33071}],
      'images': [{'mimeType': 'image/png', 'bufferView': 3}],
      'accessors': [
        {'bufferView': 0, 'componentType': 5126, 'count': 4, 'type': 'VEC3',
         'min': [-0.5, 0, -0.5], 'max': [0.5, 0, 0.5]},
        {'bufferView': 1, 'componentType': 5126, 'count': 4, 'type': 'VEC2'},
        {'bufferView': 2, 'componentType': 5123, 'count': indices.length, 'type': 'SCALAR'},
      ],
      'bufferViews': [
        {'buffer': 0, 'byteOffset': 0, 'byteLength': vertLen, 'target': 34962},
        {'buffer': 0, 'byteOffset': vertLen, 'byteLength': uvLen, 'target': 34962},
        {'buffer': 0, 'byteOffset': vertLen + uvLen, 'byteLength': idxLen, 'target': 34963},
        {'buffer': 0, 'byteOffset': imgOffset, 'byteLength': pngBytes.length},
      ],
      'buffers': [{'byteLength': binBytes.length}],
    };
    final jsonBytes = utf8.encode(json.encode(gltf));
    // Pad JSON chunk to 4 bytes with spaces.
    final jsonPadded = BytesBuilder()..add(jsonBytes);
    while (jsonPadded.length % 4 != 0) jsonPadded.addByte(0x20);
    final jsonChunk = jsonPadded.toBytes();

    // Assemble GLB.
    final total = 12 /* header */ + 8 /* json chunk hdr */ + jsonChunk.length + 8 /* bin chunk hdr */ + binBytes.length;
    final out = ByteData(total);
    out.setUint32(0,  0x46546C67, Endian.little); // magic 'glTF'
    out.setUint32(4,  2,          Endian.little); // version
    out.setUint32(8,  total,      Endian.little);
    out.setUint32(12, jsonChunk.length, Endian.little);
    out.setUint32(16, 0x4E4F534A,       Endian.little); // 'JSON'
    for (var i = 0; i < jsonChunk.length; i++) out.setUint8(20 + i, jsonChunk[i]);
    final binHdrPos = 20 + jsonChunk.length;
    out.setUint32(binHdrPos,     binBytes.length, Endian.little);
    out.setUint32(binHdrPos + 4, 0x004E4942,      Endian.little); // 'BIN\0'
    for (var i = 0; i < binBytes.length; i++) out.setUint8(binHdrPos + 8 + i, binBytes[i]);

    // Cache-key the file by URL hash so a re-open reuses it.
    final safe = pngUrl.hashCode.toRadixString(16);
    final path = '${tmp.path}/sticker-$safe.glb';
    await File(path).writeAsBytes(out.buffer.asUint8List());
    return path;
  }

  Future<String> _fallbackPlaceholderPath() async {
    // Simple 1×1 white PNG so at least a square anchors.
    final tmp = await getTemporaryDirectory();
    final path = '${tmp.path}/sticker-placeholder.glb';
    if (await File(path).exists()) return path;
    // Ship a bundled placeholder — 1x1 white PNG bytes.
    const white1x1Png = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xFC, 0xFF, 0xFF, 0x3F,
      0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC, 0x59, 0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
      0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    final tmpPng = File('${tmp.path}/sticker-placeholder.png');
    await tmpPng.writeAsBytes(white1x1Png);
    return _bakeStickerGlb(tmpPng.path);
  }

  static Uint8List _floatsToBytes(List<double> xs) {
    final b = ByteData(xs.length * 4);
    for (var i = 0; i < xs.length; i++) b.setFloat32(i * 4, xs[i], Endian.little);
    return b.buffer.asUint8List();
  }

  static Uint8List _ushortsToBytes(List<int> xs) {
    final b = ByteData(xs.length * 2);
    for (var i = 0; i < xs.length; i++) b.setUint16(i * 2, xs[i], Endian.little);
    return b.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    if (_arError != null) return _fallback(_arError!);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lensName),
        actions: [
          if (_baking)
            const Padding(padding: EdgeInsets.all(14),
                child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
          IconButton(
            key: const Key('world-clear'),
            onPressed: _placed.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear placed objects',
          ),
        ],
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onArViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          if (!_arReady) const Center(child: CircularProgressIndicator()),
          Positioned(
            left: 12, right: 12, bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.touch_app, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _placed.isEmpty
                        ? 'Tap a detected surface to place the lens'
                        : '${_placed.length} placed · Tap again to add more',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(String reason) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lensName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.view_in_ar, size: 48, color: Colors.orangeAccent),
          const SizedBox(height: 12),
          const Text('World AR unavailable on this device',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Requires ARCore (Android) or ARKit (iOS).  Fall back to the face camera to still use the lens.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
          const SizedBox(height: 8),
          Text(reason, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 10), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
