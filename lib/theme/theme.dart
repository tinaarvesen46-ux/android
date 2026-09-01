import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color success;
  final Color warning;
  final Color danger;
  final Color subtleText;
  final Color cardSurface;
  final Color navBar;
  final Color snapYellow;
  final Color onlineGreen;
  final Color storyRing;
  final Color storyRingSeen;
  final Color chatBubbleSelf;
  final Color chatBubbleOther;
  final Color shimmer;

  /// Foreground colour for content drawn directly on top of media
  /// (camera preview, reels, story viewer, map overlays, chat bubbles).
  final Color onMedia;

  /// Scrim colour used to keep [onMedia] legible above bright media.
  final Color mediaScrim;

  const AppColorsExtension({
    required this.success,
    required this.warning,
    required this.danger,
    required this.subtleText,
    required this.cardSurface,
    required this.navBar,
    required this.snapYellow,
    required this.onlineGreen,
    required this.storyRing,
    required this.storyRingSeen,
    required this.chatBubbleSelf,
    required this.chatBubbleOther,
    required this.shimmer,
    required this.onMedia,
    required this.mediaScrim,
  });

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? subtleText,
    Color? cardSurface,
    Color? navBar,
    Color? snapYellow,
    Color? onlineGreen,
    Color? storyRing,
    Color? storyRingSeen,
    Color? chatBubbleSelf,
    Color? chatBubbleOther,
    Color? shimmer,
    Color? onMedia,
    Color? mediaScrim,
  }) =>
      AppColorsExtension(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        subtleText: subtleText ?? this.subtleText,
        cardSurface: cardSurface ?? this.cardSurface,
        navBar: navBar ?? this.navBar,
        snapYellow: snapYellow ?? this.snapYellow,
        onlineGreen: onlineGreen ?? this.onlineGreen,
        storyRing: storyRing ?? this.storyRing,
        storyRingSeen: storyRingSeen ?? this.storyRingSeen,
        chatBubbleSelf: chatBubbleSelf ?? this.chatBubbleSelf,
        chatBubbleOther: chatBubbleOther ?? this.chatBubbleOther,
        shimmer: shimmer ?? this.shimmer,
        onMedia: onMedia ?? this.onMedia,
        mediaScrim: mediaScrim ?? this.mediaScrim,
      );

  @override
  AppColorsExtension lerp(
      covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      snapYellow: Color.lerp(snapYellow, other.snapYellow, t)!,
      onlineGreen: Color.lerp(onlineGreen, other.onlineGreen, t)!,
      storyRing: Color.lerp(storyRing, other.storyRing, t)!,
      storyRingSeen: Color.lerp(storyRingSeen, other.storyRingSeen, t)!,
      chatBubbleSelf: Color.lerp(chatBubbleSelf, other.chatBubbleSelf, t)!,
      chatBubbleOther: Color.lerp(chatBubbleOther, other.chatBubbleOther, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
      onMedia: Color.lerp(onMedia, other.onMedia, t)!,
      mediaScrim: Color.lerp(mediaScrim, other.mediaScrim, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  // Spacing
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacingHuge = 32.0;

  // Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // Icon sizes
  static const double iconSm = 18.0;
  static const double iconMd = 22.0;
  static const double iconLg = 26.0;
  static const double iconXl = 32.0;
  static const double iconHuge = 48.0;

  // Component dimensions
  static const double navBarHeight = 58.0;
  static const double cameraButtonSize = 52.0;
  static const double captureButtonSize = 74.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 44.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 84.0;
  static const double chatRowHeight = 68.0;
  static const double storyAvatarSize = 56.0;
  static const double storyRowHeight = 88.0;
  static const double storyRingWidth = 2.5;
  static const double buttonHeight = 44.0;
  static const double rowHeight = 52.0;
  static const double mapMarkerSize = 44.0;
  static const double controlSize = 38.0;
  static const double discoverTileExtent = 220.0;
  static const double memoryTileExtent = 160.0;

  // Opacities
  static const double opacityDisabled = 0.38;
  static const double opacityHint = 0.5;
  static const double opacityOverlay = 0.7;
  static const double opacitySubtle = 0.12;
  static const double opacityScrim = 0.35;
  static const double opacityNone = 0.0;

  // Borders
  static const double borderThin = 0.5;
  static const double borderDefault = 1.0;
  static const double borderThick = 2.0;
  static const double borderCapture = 4.0;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);

  static final ThemeData darkTheme = _buildTheme(
    colorScheme: ColorScheme.fromSeed(
      // Purple-first seed for Snapchat-like purple theme
      seedColor: const Color(0xFF7C3AED),
      brightness: Brightness.dark,
      surface: const Color(0xFF0A0A0F),
      onSurface: Colors.white,
      primary: const Color(0xFF7C3AED),
      onPrimary: Colors.white,
      secondary: const Color(0xFF9F7AEA),
      onSecondary: Colors.white,
      tertiary: const Color(0xFFFF6B6B),
      onTertiary: Colors.white,
      error: const Color(0xFFFF4757),
      onError: Colors.white,
      surfaceContainerHighest: const Color(0xFF1A1A1A),
      surfaceContainerHigh: const Color(0xFF141414),
      surfaceContainer: const Color(0xFF0D0D0D),
      surfaceContainerLow: const Color(0xFF0A0A0A),
      outline: const Color(0xFF2A2A2A),
      outlineVariant: const Color(0xFF1E1E1E),
    ),
    appColors: const AppColorsExtension(
      success: Color(0xFF2ED573),
      warning: Color(0xFFFFA502),
      danger: Color(0xFFFF4757),
      subtleText: Color(0xFFBDB7C9),
      cardSurface: Color(0xFF121014),
      navBar: Color(0xFF0A0A0F),
      snapYellow: Color(0xFF7C3AED),
      onlineGreen: Color(0xFF2ED573),
      storyRing: Color(0xFF9F7AEA),
      storyRingSeen: Color(0xFF3A3A3C),
      chatBubbleSelf: Color(0xFF7C3AED),
      chatBubbleOther: Color(0xFF2C2C2E),
      shimmer: Color(0xFF2C2C2E),
      onMedia: Color(0xFFFFFFFF),
      mediaScrim: Color(0xFF000000),
    ),
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorsExtension appColors,
  }) {
    final textTheme = _buildTextTheme(colorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: appColors.cardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: appColors.cardSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
        dragHandleColor: appColors.subtleText,
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: appColors.subtleText,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.onSurface,
        unselectedLabelColor: appColors.subtleText,
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.outlineVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: appColors.subtleText,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: appColors.subtleText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.cardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: textTheme.bodyMedium?.copyWith(color: appColors.subtleText),
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: iconMd,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: borderThin,
        space: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : colorScheme.onSurface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.all(colorScheme.outline),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appColors.cardSurface,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [appColors],
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: colorScheme.onSurface,
        letterSpacing: -0.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: colorScheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: colorScheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: colorScheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: colorScheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        color: colorScheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        color: colorScheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 11,
        color: colorScheme.onSurface,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: colorScheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: colorScheme.onSurface,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 10,
        color: colorScheme.onSurface,
      ),
    );
  }
}
