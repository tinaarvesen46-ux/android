import 'package:avatar_builder/src/svg/svg_cache.dart';
import 'package:avatar_builder/src/widgets/flutter_avatar_color_mapper.dart';
import 'package:avatar_builder_core/avatar_builder_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an [Avataaar] using SVG.
///
/// Loads the required SVG asset fragments asynchronously via [FutureBuilder],
/// showing [placeholder] while loading and [errorBuilder] on failure.
class AvatarWidget extends StatefulWidget {
  /// Creates an [AvatarWidget] that renders the given [avatar].
  const AvatarWidget({
    required this.avatar,
    super.key,
    this.cache,
    this.size = 264,
    this.placeholder,
    this.errorBuilder,
  });

  /// The avatar model to render.
  final Avataaar avatar;

  /// Optional cache override. Defaults to [SvgCache.instance].
  final SvgCache? cache;

  /// The width of the rendered avatar in logical pixels.
  final double size;

  /// Widget shown while SVG assets are loading.
  final Widget? placeholder;

  /// Builder for error states. Receives the error and stack trace.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  Future<String>? _future;

  @override
  void initState() {
    super.initState();
    _future = widget.avatar.toSvg(
      loadAsset: (widget.cache ?? SvgCache.instance).load,
      colorMapped: false,
    );
  }

  @override
  void didUpdateWidget(AvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.avatar != oldWidget.avatar || widget.cache != oldWidget.cache) {
      _future = widget.avatar.toSvg(
        loadAsset: (widget.cache ?? SvgCache.instance).load,
        colorMapped: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(widget.size, widget.size * (280 / 264));
    return FutureBuilder<String>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final errorBuilder = widget.errorBuilder;
          return SizedBox.fromSize(
            size: size,
            child: errorBuilder != null
                ? errorBuilder(context, snapshot.error!)
                : null,
          );
        }
        final svg = snapshot.data;
        if (svg == null) {
          return SizedBox.fromSize(
            size: size,
            child: widget.placeholder,
          );
        }
        final colorMapper = FlutterAvatarColorMapper(
          skinColor: widget.avatar.skinColor,
          hairColor: widget.avatar.hairColor,
          hatColor: widget.avatar.hatColor,
          clotheColor: widget.avatar.clotheColor,
          facialHairColor: widget.avatar.facialHairColor,
        );
        return SizedBox.fromSize(
          size: size,
          child: SvgPicture(
            SvgStringLoader(svg, colorMapper: colorMapper),
          ),
        );
      },
    );
  }
}
