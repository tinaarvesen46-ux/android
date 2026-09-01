/// Signature for a function that loads an SVG fragment by its asset key.
///
/// Asset keys are bare relative paths within the assets directory,
/// e.g. `eyes/close.svgf` or `shared_defs.svgf`.
///
/// The loader is responsible for resolving the key to a concrete location
/// (filesystem path, Flutter asset bundle key, etc.) and returning the
/// string content.
///
/// Return an empty string for empty keys (used by "blank" variants that
/// have no SVG fragment).
typedef AssetLoader = Future<String> Function(String assetKey);
