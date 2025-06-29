import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Vous pouvez utiliser le package shimmer

class SkeletonLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
        ],
      ),
    );
  }
}
