import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders one catalog asset using the decoder required by its stored file
/// type. SwiftMoji contains both raster files and SVG/SVGF artwork.
class AvatarAssetImage extends StatelessWidget {
  final String url;
  final String? filename;
  final BoxFit fit;
  final Widget? fallback;

  const AvatarAssetImage({
    super.key,
    required this.url,
    this.filename,
    this.fit = BoxFit.contain,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final isVector = (filename ?? '').toLowerCase().endsWith('.svg') ||
        (filename ?? '').toLowerCase().endsWith('.svgf');
    final error = fallback ??
        Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );

    if (isVector) {
      return SvgPicture.network(
        url,
        fit: fit,
        placeholderBuilder: (_) => error,
        errorBuilder: (_, __, ___) => error,
      );
    }
    return Image.network(url, fit: fit, errorBuilder: (_, __, ___) => error);
  }
}
