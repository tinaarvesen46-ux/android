import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/map_friend.dart';
import '../providers/map_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/theme.dart';
import '../widgets/camera/camera_controls.dart';
import '../widgets/common/async_state_view.dart';
import '../widgets/common/snap_avatar.dart';

/// Friend map built on OpenStreetMap tiles so it works without any API key.
/// Ghost Mode stops the device position from being sent to the backend.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _fallbackCenter = LatLng(20, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final ghostMode =
        context.read<SettingsProvider>().boolFor(SettingsProvider.ghostModeKey);
    final map = context.read<MapProvider>();
    await map.requestLocation(shareWithBackend: !ghostMode);
    if (!mounted) return;
    await map.loadFriends();
    if (!mounted) return;
    final position = map.position;
    if (position != null) {
      _mapController.move(LatLng(position.latitude, position.longitude), 14);
    }
  }

  Future<void> _toggleGhostMode(bool enabled) async {
    final settings = context.read<SettingsProvider>();
    await settings.setBool(SettingsProvider.ghostModeKey, enabled);
    if (!mounted) return;
    final error = await context.read<MapProvider>().setGhostMode(enabled);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
          error ??
              (enabled
                  ? 'Ghost Mode is on.'
                  : 'Your location is shared again.'),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final map = context.watch<MapProvider>();
    final ghostMode =
        context.watch<SettingsProvider>().boolFor(SettingsProvider.ghostModeKey);
    final position = map.position;
    final insets = MediaQuery.paddingOf(context);

    if (map.access != LocationAccess.granted &&
        map.access != LocationAccess.unknown) {
      return _LocationBlockedView(
        access: map.access,
        onRetry: _refresh,
        onOpenSettings: map.openSystemSettings,
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: position == null
                ? _fallbackCenter
                : LatLng(position.latitude, position.longitude),
            initialZoom: position == null ? 2 : 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.primio.swiftsnap.pkvtsv',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                if (position != null && !ghostMode)
                  Marker(
                    point: LatLng(position.latitude, position.longitude),
                    width: AppTheme.mapMarkerSize,
                    height: AppTheme.mapMarkerSize,
                    child: const _SelfMarker(),
                  ),
                ...(map.friends.data ?? const <MapFriend>[]).map(
                  (friend) => Marker(
                    point: LatLng(friend.latitude, friend.longitude),
                    width: AppTheme.mapMarkerSize,
                    height: AppTheme.mapMarkerSize,
                    child: GestureDetector(
                      onTap: () => context.push('/user/${friend.user.id}'),
                      child: SnapAvatar(
                        imageUrl: friend.user.avatarUrl,
                        fallbackText: friend.user.displayName,
                        size: AppTheme.mapMarkerSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (map.isLocating)
          Positioned(
            top: insets.top + AppTheme.spacingHuge + AppTheme.spacingXxl,
            left: 0,
            right: 0,
            child: const Center(
              child: SizedBox(
                width: AppTheme.iconMd,
                height: AppTheme.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: AppTheme.borderThick,
                ),
              ),
            ),
          ),
        Positioned(
          top: insets.top + AppTheme.spacingSm,
          left: AppTheme.spacingLg,
          right: AppTheme.spacingLg,
          child: Row(
            children: [
              CameraOverlayButton(
                icon: Icons.search_rounded,
                semanticLabel: 'Search people',
                onTap: () => context.push('/search'),
              ),
              const Spacer(),
              _GhostModeChip(
                enabled: ghostMode,
                onTap: () => _toggleGhostMode(!ghostMode),
              ),
              const Spacer(),
              CameraOverlayButton(
                icon: Icons.person_outline_rounded,
                semanticLabel: 'Open profile',
                onTap: () => context.push('/profile'),
              ),
            ],
          ),
        ),
        Positioned(
          right: AppTheme.spacingLg,
          bottom: AppTheme.spacingXxl,
          child: Column(
            children: [
              CameraOverlayButton(
                icon: Icons.my_location_rounded,
                semanticLabel: 'Centre on my location',
                onTap: _refresh,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              CameraOverlayButton(
                icon: Icons.group_outlined,
                semanticLabel: 'Open friends',
                onTap: () => context.push('/friends'),
              ),
            ],
          ),
        ),
        if (map.friends.hasError)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: InlineErrorBar(
              message: map.friends.message,
              onRetry: map.loadFriends,
            ),
          )
        else if (map.friends.isEmpty)
          Positioned(
            left: AppTheme.spacingLg,
            right: AppTheme.spacingLg,
            bottom: AppTheme.spacingLg,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: appColors.cardSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                'No friends are sharing their location right now.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: appColors.subtleText),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _SelfMarker extends StatelessWidget {
  const _SelfMarker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary,
        border:
            Border.all(color: appColors.onMedia, width: AppTheme.borderThick),
      ),
      child: Icon(
        Icons.person_rounded,
        size: AppTheme.iconSm,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}

class _GhostModeChip extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _GhostModeChip({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final foreground = enabled
        ? theme.colorScheme.onPrimaryContainer
        : appColors.onMedia;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLg,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? theme.colorScheme.primaryContainer
              : appColors.mediaScrim
                  .withValues(alpha: AppTheme.opacityOverlay),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: AppTheme.iconSm,
              color: foreground,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              enabled ? 'Ghost Mode on' : 'Ghost Mode off',
              style: theme.textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationBlockedView extends StatelessWidget {
  final LocationAccess access;
  final Future<void> Function() onRetry;
  final Future<void> Function() onOpenSettings;

  const _LocationBlockedView({
    required this.access,
    required this.onRetry,
    required this.onOpenSettings,
  });

  String get _message {
    switch (access) {
      case LocationAccess.serviceDisabled:
        return 'Location services are turned off on this device. Turn them on to see the map.';
      case LocationAccess.deniedForever:
        return 'Location access is blocked for SwiftSnap. Enable it in your device settings to see the map.';
      default:
        return 'SwiftSnap needs your location to show you and your friends on the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>()!;
    final needsSettings = access == LocationAccess.deniedForever ||
        access == LocationAccess.serviceDisabled;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingHuge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: AppTheme.iconHuge,
              color: appColors.subtleText,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Map unavailable',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              _message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: appColors.subtleText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXl),
            ElevatedButton(
              onPressed:
                  needsSettings ? () => onOpenSettings() : () => onRetry(),
              child: Text(needsSettings ? 'Open settings' : 'Allow location'),
            ),
          ],
        ),
      ),
    );
  }
}
