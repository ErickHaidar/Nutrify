import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String initialValue;

  const CustomInputField({super.key, required this.label, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFFFCC80))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2A4A),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(initialValue, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
