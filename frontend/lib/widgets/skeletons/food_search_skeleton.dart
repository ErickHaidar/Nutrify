// lib/widgets/skeletons/food_search_skeleton.dart
// Skeleton preview for AddMealScreen search results list

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for AddMealScreen food search results.
/// Mimics the exact shape of _buildFoodTile() in add_meal_screen.dart.
/// Shown while _isSearching is true.
class FoodSearchSkeleton extends StatelessWidget {
  /// Number of skeleton items to display.
  final int itemCount;

  const FoodSearchSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
      itemCount: itemCount,
      itemBuilder: (_, i) => _SkeletonFoodTile(
        // Stagger the shimmer slightly for each item
        key: ValueKey(i),
      ),
    );
  }
}

class _SkeletonFoodTile extends StatelessWidget {
  const _SkeletonFoodTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Checkbox placeholder
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
