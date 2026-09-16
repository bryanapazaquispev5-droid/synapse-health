import 'package:flutter/material.dart';

class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://developers.google.com/identity/images/g-logo.png',
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.g_mobiledata_rounded,
        size: size * 1.5,
        color: const Color(0xFF4285F4),
      ),
    );
  }
}
