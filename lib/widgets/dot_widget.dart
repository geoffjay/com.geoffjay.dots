import 'package:flutter/material.dart';

import '../models/dot.dart';

class DotWidget extends StatelessWidget {
  final Dot dot;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const DotWidget({
    super.key,
    required this.dot,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: dot.position.dx - dot.radius,
      top: dot.position.dy - dot.radius,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: dot.radius * 2,
          height: dot.radius * 2,
          decoration: BoxDecoration(
            color: dot.dotColor.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dot.dotColor.color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
