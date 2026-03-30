import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flame/components.dart';

class SkyBackground extends Component with HasGameRef {
  @override
  void render(Canvas canvas) {
    final rect = gameRef.size.toRect();
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(rect.width / 2, 0), // Top of screen
        Offset(rect.width / 2, rect.height), // Bottom of screen
        [
          const Color(0xFF005F73), // Lighter blue at top
          const Color(0xFF001219), // Darker blue at bottom
        ],
      );
    canvas.drawRect(rect, paint);
  }
}
