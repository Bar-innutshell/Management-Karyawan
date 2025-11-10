import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Button extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;

  const Button({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981), // Warna tombol hijau
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    ).animate().fadeIn(duration: 300.ms, delay: 120.ms);
  }
}
