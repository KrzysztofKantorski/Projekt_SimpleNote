import 'package:flutter/material.dart';

/// Przycisk serca z licznikiem lajków
class SnLikeButton extends StatelessWidget {
  final int count;
  final bool isLiked;
  final VoidCallback? onTap;

  const SnLikeButton({
    super.key,
    required this.count,
    this.isLiked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: isLiked ? Colors.redAccent : Colors.black,
          ),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
