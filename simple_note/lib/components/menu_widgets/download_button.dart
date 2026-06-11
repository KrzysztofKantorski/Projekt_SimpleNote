import 'package:flutter/material.dart';

/// Przycisk "Download" — zaokrąglony, z ikoną
/// Widoczny na ekranie podglądu notatki (prawy dół)
class SnDownloadButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SnDownloadButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.black),
            )
          : const Icon(Icons.download_outlined, size: 18),
      label: const Text(
        'Download',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
