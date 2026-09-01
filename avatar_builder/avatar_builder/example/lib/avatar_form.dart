import 'package:avatar_builder/avatar_builder.dart';
import 'package:flutter/material.dart';

/// A form that lets users pick each avatar attribute via dropdowns.
class AvatarForm extends StatelessWidget {
  /// Creates an [AvatarForm].
  const AvatarForm({
    required this.avatar,
    required this.onChanged,
    super.key,
  });

  /// The current avatar state.
  final Avataaar avatar;

  /// Called when the user changes any attribute.
  final ValueChanged<Avataaar> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -- Background style --
          _buildDropdown<AvatarStyle>(
            label: 'Style',
            value: avatar.style,
            items: AvatarStyle.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(style: v)),
          ),

          // -- Skin --
          _buildColorDropdown<SkinColor?>(
            label: 'Skin',
            value: avatar.skinColorEnum,
            items: SkinColor.values,
            labelOf: (v) => v?.label ?? 'Custom',
            colorOf: (v) => Color(v!.color),
            onChanged: (v) => onChanged(avatar.copyWith(skinColor: v?.color)),
          ),

          // -- Top (hair / hat) --
          _buildDropdown<TopType>(
            label: 'Top',
            value: avatar.topType,
            items: TopType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(topType: v)),
          ),
          _buildColorDropdown<HairColor?>(
            label: 'Hair Color',
            value: avatar.hairColorEnum,
            items: HairColor.values,
            labelOf: (v) => v?.label ?? 'Custom',
            colorOf: (v) => Color(v!.color),
            onChanged: (v) => onChanged(avatar.copyWith(hairColor: v?.color)),
            enabled: avatar.topType.hasHair,
          ),
          _buildColorDropdown<HatColor?>(
            label: 'Hat Color',
            value: avatar.hatColorEnum,
            items: HatColor.values,
            labelOf: (v) => v?.label ?? 'Custom',
            colorOf: (v) => Color(v!.color),
            onChanged: (v) => onChanged(avatar.copyWith(hatColor: v?.color)),
            enabled: avatar.topType.hasHat,
          ),

          // -- Accessories (glasses) --
          _buildDropdown<AccessoriesType>(
            label: 'Accessories',
            value: avatar.accessoriesType,
            items: AccessoriesType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(accessoriesType: v)),
          ),

          // -- Face --
          _buildDropdown<EyeType>(
            label: 'Eyes',
            value: avatar.eyeType,
            items: EyeType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(eyeType: v)),
          ),
          _buildDropdown<EyebrowType>(
            label: 'Eyebrow',
            value: avatar.eyebrowType,
            items: EyebrowType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(eyebrowType: v)),
          ),
          _buildDropdown<MouthType>(
            label: 'Mouth',
            value: avatar.mouthType,
            items: MouthType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(mouthType: v)),
          ),

          // -- Facial hair --
          _buildDropdown<FacialHairType>(
            label: 'Facial Hair',
            value: avatar.facialHairType,
            items: FacialHairType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(facialHairType: v)),
          ),
          _buildColorDropdown<FacialHairColor?>(
            label: 'Facial Hair Color',
            value: avatar.facialHairColorEnum,
            items: FacialHairColor.values,
            labelOf: (v) => v?.label ?? 'Custom',
            colorOf: (v) => Color(v!.color),
            onChanged: (v) =>
                onChanged(avatar.copyWith(facialHairColor: v?.color)),
            enabled: avatar.facialHairType.hasFacialHair,
          ),

          // -- Clothing --
          _buildDropdown<ClotheType>(
            label: 'Clothes',
            value: avatar.clotheType,
            items: ClotheType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(clotheType: v)),
          ),
          _buildColorDropdown<ClotheColor?>(
            label: 'Clothes Color',
            value: avatar.clotheColorEnum,
            items: ClotheColor.values,
            labelOf: (v) => v?.label ?? 'Custom',
            colorOf: (v) => Color(v!.color),
            onChanged: (v) => onChanged(avatar.copyWith(clotheColor: v?.color)),
            enabled: avatar.clotheType.hasClotheColor,
          ),
          _buildDropdown<GraphicType>(
            label: 'Graphic',
            value: avatar.graphicType,
            items: GraphicType.values,
            labelOf: (v) => v.label,
            onChanged: (v) => onChanged(avatar.copyWith(graphicType: v)),
            enabled: avatar.clotheType.hasGraphic,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: IgnorePointer(
              ignoring: !enabled,
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                items: items
                    .map(
                      (v) =>
                          DropdownMenuItem(value: v, child: Text(labelOf(v))),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelOf,
    required Color Function(T) colorOf,
    required ValueChanged<T> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: IgnorePointer(
              ignoring: !enabled,
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                items: items
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: colorOf(v),
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(labelOf(v)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
