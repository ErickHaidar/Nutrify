// lib/widgets/skeletons/history_skeleton.dart
// Skeleton preview for HistoryScreen

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/nutrition_tips.dart';

/// Skeleton for HistoryScreen.
/// Mimics: 2 summary cards, 4 meal section cards (peach-themed).
class HistoryScreenSkeleton extends StatelessWidget {
  const HistoryScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 2 Summary Cards
          Row(
            children: [
              Expanded(child: _SkeletonSummaryCard()),
              const SizedBox(width: 15),
              Expanded(child: _SkeletonSummaryCard()),
            ],
          ),
          const SizedBox(height: 25),

          // 4 Meal Section Cards
          _SkeletonMealSection(),
          const SizedBox(height: 15),
          _SkeletonMealSection(),
          const SizedBox(height: 15),
          _SkeletonMealSection(),
          const SizedBox(height: 15),
          _SkeletonMealSection(),
          const SizedBox(height: 20),

          // Nutrition tip
          _HistoryTip(tip: NutritionTips.getRandomTip()),
        ],
      ),
    );
  }
}

class _SkeletonSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEFD9C4), // peach-toned shimmer
      highlightColor: const Color(0xFFF7EBE0),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFD9C4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 24,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 12,
              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonMealSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEFD9C4),
      highlightColor: const Color(0xFFF7EBE0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFD9C4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 90,
                  height: 18,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
                const Spacer(),
                Container(
                  width: 70,
                  height: 16,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 2 food item rows
            ..._buildFoodItemSkeletons(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFoodItemSkeletons() {
    return List.generate(2, (i) => Padding(
      padding: EdgeInsets.only(top: i == 0 ? 0 : 8, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 130,
            height: 14,
            decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(4)),
          ),
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    ));
  }
}

class _HistoryTip extends StatelessWidget {
  final String tip;
  const _HistoryTip({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.navy, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: AppColors.navy.withOpacity(0.7),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
