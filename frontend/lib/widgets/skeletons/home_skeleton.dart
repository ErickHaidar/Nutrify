// lib/widgets/skeletons/home_skeleton.dart
// Skeleton preview for HomeScreen - mimics exact layout of real widgets

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/nutrition_tips.dart';

/// A shimmer-based skeleton for the entire HomeScreen content area.
/// Mimics: header, calorie tracking card, target card, 2x2 meal grid.
class HomeScreenSkeleton extends StatefulWidget {
  final bool showTip;
  const HomeScreenSkeleton({super.key, this.showTip = false});

  @override
  State<HomeScreenSkeleton> createState() => _HomeScreenSkeletonState();
}

class _HomeScreenSkeletonState extends State<HomeScreenSkeleton> {
  final String _tip = NutritionTips.getRandomTip();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Header shimmer (logo + date placeholder)
          const _ShimmerBox(width: 180, height: 40, radius: 8),
          const SizedBox(height: 6),
          const _ShimmerBox(width: 120, height: 14, radius: 4),
          const SizedBox(height: 25),

          // Big Calorie Tracking Card
          // Big Calorie Tracking Card
          _ShimmerContainer(height: 200, radius: 30),
          const SizedBox(height: 20),

          // Target Kalori Card
          // Target Kalori Card
          _ShimmerContainer(height: 72, radius: 25),
          const SizedBox(height: 10),
          const SizedBox(height: 40), // Divider space

          // 2x2 Meal Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: List.generate(4, (_) => _SkeletonMealTile()),
          ),
          const SizedBox(height: 20),

          // Nutrition tip displayed after 1s
          _TipWidget(tip: _tip),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SkeletonMealTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Container(width: 60, height: 13, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const Spacer(),
            Center(child: Container(width: 50, height: 50, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(width: 50, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer-animated container box.
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Shimmer-animated full-width container.
/// Shimmer-animated full-width container.
class _ShimmerContainer extends StatelessWidget {
  final double height;
  final double radius;

  const _ShimmerContainer({
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Nutrition tip widget for psychological progress illusion.
class _TipWidget extends StatelessWidget {
  final String tip;
  const _TipWidget({required this.tip});

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

/// Animated progress bar that animates from 0 to [value] on first build.
class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double minHeight;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.backgroundColor = const Color(0x1A1A237E),
    this.valueColor = AppColors.navy,
    this.minHeight = 10,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _previousValue = old.value;
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final current = _previousValue + (_animation.value * (widget.value - _previousValue));
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: current.clamp(0.0, 1.0),
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.valueColor),
            minHeight: widget.minHeight,
          ),
        );
      },
    );
  }
}
