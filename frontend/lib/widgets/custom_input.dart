import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomInputField({
    super.key,
    required this.label,
    required this.initialValue,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.navy)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.navy.withOpacity(0.1)),
            ),
            child: Text(
              initialValue,
              style: const TextStyle(color: AppColors.navy, fontSize: 16),
            ),
          ),
        ),
      ],
    );
}
