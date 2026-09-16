import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String gender;
  final String? photoUrl;
  final Uint8List? photoBytes;
  final VoidCallback onEditName;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.gender,
    this.photoUrl,
    this.photoBytes,
    required this.onEditName,
  });

  Widget _buildAvatarWidget(String userGif) {
    if (photoBytes != null && photoBytes!.isNotEmpty) {
      return Image.memory(
        photoBytes!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(userGif, width: 72, height: 72, fit: BoxFit.cover),
      );
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(userGif, width: 72, height: 72, fit: BoxFit.cover),
      );
    }
    return Image.asset(userGif, width: 72, height: 72, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final String userGif = (gender.toLowerCase() == 'mujer')
        ? 'assets/images/user_girl.gif'
        : 'assets/images/user_boy.gif';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
            child: ClipOval(child: _buildAvatarWidget(userGif)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onEditName,
                      child: const Icon(
                        CupertinoIcons.pencil_circle_fill,
                        size: 20,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
