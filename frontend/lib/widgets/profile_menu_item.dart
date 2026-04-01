import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isHighlighted;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.label,
    required this.icon,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2A4A),
          borderRadius: BorderRadius.circular(30),
          border: isHighlighted ? Border.all(color: const Color(0xFFFFCC80), width: 1.5) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
