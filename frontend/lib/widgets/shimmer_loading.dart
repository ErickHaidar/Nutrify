import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/colors.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.navy.withOpacity(0.06),
      highlightColor: AppColors.navy.withOpacity(0.15),
      child: child,
    );
  }
}

class ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const ShimmerBlock({super.key, this.width = double.infinity, this.height = 14, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(6),
      ),
    );
  }
}

// Pre-built shimmer layouts for each screen

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(children: [
              ShimmerBlock(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(10))),
              SizedBox(width: 10),
              ShimmerBlock(width: 80, height: 24),
            ]),
            SizedBox(height: 24),
            ShimmerBlock(height: 180, borderRadius: BorderRadius.all(Radius.circular(20))),
            SizedBox(height: 20),
            ShimmerBlock(width: 120, height: 16),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: ShimmerBlock(height: 80, borderRadius: BorderRadius.all(Radius.circular(16)))),
              SizedBox(width: 10),
              Expanded(child: ShimmerBlock(height: 80, borderRadius: BorderRadius.all(Radius.circular(16)))),
            ]),
            SizedBox(height: 10),
            Row(children: [
              Expanded(child: ShimmerBlock(height: 80, borderRadius: BorderRadius.all(Radius.circular(16)))),
              SizedBox(width: 10),
              Expanded(child: ShimmerBlock(height: 80, borderRadius: BorderRadius.all(Radius.circular(16)))),
            ]),
          ],
        ),
      ),
    );
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(children: [
              ShimmerBlock(width: 40, height: 40, borderRadius: BorderRadius.circular(10)),
              const SizedBox(width: 10),
              const ShimmerBlock(width: 80, height: 24),
            ]),
            const SizedBox(height: 24),
            Center(child: Column(children: [
              ShimmerBlock(width: 100, height: 100, borderRadius: BorderRadius.circular(25)),
              const SizedBox(height: 12),
              const ShimmerBlock(width: 140, height: 20),
              const SizedBox(height: 6),
              const ShimmerBlock(width: 180, height: 14),
            ])),
            const SizedBox(height: 30),
            Row(children: [
              Expanded(child: ShimmerBlock(height: 65, borderRadius: BorderRadius.circular(15))),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBlock(height: 65, borderRadius: BorderRadius.circular(15))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ShimmerBlock(height: 65, borderRadius: BorderRadius.circular(15))),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBlock(height: 65, borderRadius: BorderRadius.circular(15))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ShimmerBlock(height: 65, borderRadius: BorderRadius.circular(15))),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBlock(height: 65, borderRadius: BorderRadius.circular(15))),
            ]),
          ],
        ),
      ),
    );
  }
}

class KomunitasShimmer extends StatelessWidget {
  const KomunitasShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                ShimmerBlock(width: 40, height: 40, borderRadius: BorderRadius.circular(20)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const ShimmerBlock(width: 120, height: 14),
                  const SizedBox(height: 4),
                  const ShimmerBlock(width: 60, height: 10),
                ]),
              ]),
              const SizedBox(height: 12),
              const ShimmerBlock(height: 14),
              const SizedBox(height: 4),
              const ShimmerBlock(width: 250, height: 14),
              const SizedBox(height: 4),
              const ShimmerBlock(width: 180, height: 14),
              const SizedBox(height: 12),
              ShimmerBlock(height: 200, borderRadius: BorderRadius.circular(16)),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              ShimmerBlock(width: 56, height: 56, borderRadius: BorderRadius.circular(28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBlock(width: 140, height: 14),
                    const SizedBox(height: 6),
                    const ShimmerBlock(width: 200, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackingShimmer extends StatelessWidget {
  const TrackingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          children: [
            ShimmerBlock(width: 200, height: 200, borderRadius: BorderRadius.all(Radius.circular(100))),
            SizedBox(height: 20),
            Row(children: [
              Expanded(child: ShimmerBlock(height: 70, borderRadius: BorderRadius.all(Radius.circular(16)))),
              SizedBox(width: 12),
              Expanded(child: ShimmerBlock(height: 70, borderRadius: BorderRadius.all(Radius.circular(16)))),
            ]),
            SizedBox(height: 24),
            ShimmerBlock(width: 120, height: 16),
            SizedBox(height: 12),
            ShimmerBlock(height: 60, borderRadius: BorderRadius.all(Radius.circular(16))),
            SizedBox(height: 10),
            ShimmerBlock(height: 60, borderRadius: BorderRadius.all(Radius.circular(16))),
            SizedBox(height: 10),
            ShimmerBlock(height: 60, borderRadius: BorderRadius.all(Radius.circular(16))),
          ],
        ),
      ),
    );
  }
}
