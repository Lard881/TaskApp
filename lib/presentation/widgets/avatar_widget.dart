import 'dart:io';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_colors.dart';

/// Circular avatar with image fallback to initials (Req 2.6, 16.1, 16.2).
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.initials,
    this.imagePath,
    this.diameter = 40,
    this.onTap,
    this.semanticLabel,
  });

  final String initials;
  final String? imagePath;
  final double diameter;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();
    if (onTap == null) return avatar;
    return Semantics(
      label: semanticLabel ?? 'Avatar',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: avatar,
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CircleAvatar(
        radius: diameter / 2,
        backgroundColor: _placeholderColor(),
        backgroundImage: _resolveImage(),
        child: _resolveImage() == null
            ? Text(
                initials.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: diameter * 0.35,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }

  ImageProvider? _resolveImage() {
    if (imagePath == null || imagePath!.isEmpty) return null;
    try {
      if (imagePath!.startsWith('http')) {
        return NetworkImage(imagePath!);
      }
      return FileImage(File(imagePath!));
    } catch (_) {
      return null;
    }
  }

  /// Picks a stable background color based on the initials string.
  Color _placeholderColor() {
    final index = initials.isNotEmpty
        ? initials.codeUnitAt(0) % AppColors.avatarBackgrounds.length
        : 0;
    return AppColors.avatarBackgrounds[index];
  }
}
