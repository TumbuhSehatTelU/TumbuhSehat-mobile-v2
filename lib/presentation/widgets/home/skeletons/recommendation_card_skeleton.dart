import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecommendationCardSkeleton extends StatelessWidget {
  const RecommendationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 100, height: 20, color: Colors.white),
                Container(width: 60, height: 20, color: Colors.white),
              ],
            ),
            const Divider(height: 24),
            _buildItemSkeleton(),
            _buildItemSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120, height: 16, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 80, height: 14, color: Colors.white),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
