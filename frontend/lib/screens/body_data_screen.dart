import 'package:flutter/material.dart';
import '../widgets/custom_input.dart';
import '../widgets/activity_tile.dart';

class BodyDataScreen extends StatelessWidget {
  const BodyDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF433D67),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {}),
        title: const Text('Body Data & Goals', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Grid Input Section
            const Row(
              children: [
                Expanded(child: CustomInputField(label: 'Height (cm)', initialValue: '175')),
                SizedBox(width: 16),
                Expanded(child: CustomInputField(label: 'Age', initialValue: '25')),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: CustomInputField(label: 'Current Weight (kg)', initialValue: '70')),
                SizedBox(width: 16),
                Expanded(child: CustomInputField(label: 'Target Weight (kg)', initialValue: '65')),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text('Daily Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const ActivitySelectionTile(
              title: 'Moderately Active', 
              subtitle: '3-5 days of exercise/week', 
              icon: Icons.fitness_center,
              isSelected: true,
            ),
            const ActivitySelectionTile(
              title: 'Highly Active', 
              subtitle: '6-7 days of intense exercise', 
              icon: Icons.bolt,
            ),

            const SizedBox(height: 40),
            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2A4A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {},
                child: const Text('Confirm Profile', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
