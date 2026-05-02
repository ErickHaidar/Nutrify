import 'dart:math' as math;
// lib/widgets/skeletons/tracking_skeleton.dart
// Skeleton preview for TrackingKaloriScreen

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/utils/nutrition_tips.dart';

/// Skeleton for TrackingKaloriScreen.
/// Mimics: circular progress ring, 2 stat cards, 3 macro bars, 4 meal rows.
class TrackingScreenSkeleton extends StatelessWidget {
  const TrackingScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular progress ring placeholder
          Center(
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFE8E8E8),
              highlightColor: const Color(0xFFF5F5F5),
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E8E8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2 stat cards side by side
          Row(
            children: [
              Expanded(child: _SkeletonStatCard()),
              const SizedBox(width: 12),
              Expanded(child: _SkeletonStatCard()),
            ],
          ),
          const SizedBox(height: 24),

          // Section title
          _SkeletonBox(width: 120, height: 16, radius: 4),
          const SizedBox(height: 12),

          // 3 macro bars
          _SkeletonMacroBar(),
          const SizedBox(height: 10),
          _SkeletonMacroBar(),
          const SizedBox(height: 10),
          _SkeletonMacroBar(),
          const SizedBox(height: 24),

          // Section title
          _SkeletonBox(width: 140, height: 16, radius: 4),
          const SizedBox(height: 12),

          // 4 meal rows
          ..._buildMealRowSkeletons(),
          const SizedBox(height: 16),

          // Tip
          _SkeletonTip(tip: NutritionTips.getRandomTip()),
        ],
      ),
    );
  }

  List<Widget> _buildMealRowSkeletons() {
    return List.generate(4, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE8E8E8),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              const Spacer(),
              Container(width: 60, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
      ),
    ));
  }
}

class _SkeletonStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(width: 38, height: 38, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 60, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 4),
                Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonMacroBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Container(width: 80, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const Spacer(),
                Container(width: 80, height: 13, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonBox({required this.width, required this.height, required this.radius});

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

class _SkeletonTip extends StatelessWidget {
  final String tip;
  const _SkeletonTip({required this.tip});

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

/// Animated circular painter that animates progress from 0 → target.
class AnimatedCircularProgress extends StatefulWidget {
  final double progress;
  final SweepGradient gradient;
  final Color backgroundColor;
  final double strokeWidth;
  final Duration duration;

  const AnimatedCircularProgress({
    super.key,
    required this.progress,
    required this.gradient,
    required this.backgroundColor,
    this.strokeWidth = 14,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedCircularProgress> createState() => _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _previousProgress = old.progress;
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
        final current = _previousProgress +
            (_animation.value * (widget.progress - _previousProgress));
        return CustomPaint(
          size: const Size(200, 200),
          painter: _AnimatedGradientPainter(
            progress: current.clamp(0.0, 1.0),
            gradient: widget.gradient,
            backgroundColor: widget.backgroundColor,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _AnimatedGradientPainter extends CustomPainter {
  final double progress;
  final SweepGradient gradient;
  final Color backgroundColor;
  final double strokeWidth;

  _AnimatedGradientPainter({
    required this.progress,
    required this.gradient,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress <= 0) return;

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnimatedGradientPainter old) =>
      old.progress != progress;
}
