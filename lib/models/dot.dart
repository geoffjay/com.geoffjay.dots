import 'dart:ui';

enum DotColor {
  yellow(Color(0xFFFFD700)),
  red(Color(0xFFE53935)),
  blue(Color(0xFF1E88E5));

  final Color color;
  const DotColor(this.color);

  DotColor get next {
    switch (this) {
      case DotColor.yellow:
        return DotColor.red;
      case DotColor.red:
        return DotColor.blue;
      case DotColor.blue:
        return DotColor.yellow;
    }
  }
}

class Dot {
  final String id;
  Offset position;
  double radius;
  DotColor dotColor;
  Offset velocity;

  Dot({
    required this.id,
    required this.position,
    this.radius = 40.0,
    this.dotColor = DotColor.yellow,
    this.velocity = Offset.zero,
  });

  Dot copyWith({
    String? id,
    Offset? position,
    double? radius,
    DotColor? dotColor,
    Offset? velocity,
  }) {
    return Dot(
      id: id ?? this.id,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      dotColor: dotColor ?? this.dotColor,
      velocity: velocity ?? this.velocity,
    );
  }
}
