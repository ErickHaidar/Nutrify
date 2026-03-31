import 'package:flutter/material.dart';

class ActivitySelectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;

  const ActivitySelectionTile({
    super.key, 
    required this.title, 
    required this.subtitle, 
    required this.icon, 
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2A4A),
        borderRadius: BorderRadius.circular(30),
        border: isSelected ? Border.all(color: const Color(0xFFFFCC80), width: 1.5) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
          const Spacer(),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFFFCC80), size: 20),
        ],
      ),
    );
  }
}