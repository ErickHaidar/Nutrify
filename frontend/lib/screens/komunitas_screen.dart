import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';

class KomunitasScreen extends StatelessWidget {
  const KomunitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      appBar: AppBar(
        title: const Text('Komunitas'),
        backgroundColor: NutrifyTheme.darkCard,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Komunitas belum tersedia',
          style: TextStyle(color: NutrifyTheme.darkCard, fontSize: 16),
        ),
      ),
    );
  }
}
