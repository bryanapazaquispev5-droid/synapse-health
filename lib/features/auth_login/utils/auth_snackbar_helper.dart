import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthSnackbarHelper {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? CupertinoIcons.exclamationmark_circle_fill : CupertinoIcons.checkmark_seal_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white, letterSpacing: -0.2),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE11D48) : const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
