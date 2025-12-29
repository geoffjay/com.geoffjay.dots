import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/dot.dart';

class GameProvider extends ChangeNotifier {
  final List<Dot> _dots = [];
  final Random _random = Random();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;

  Size _screenSize = Size.zero;
  bool _isShaking = false;
  DateTime? _lastShakeTime;
  Timer? _physicsTimer;

  static const double _shakeThreshold = 15.0;
  static const double _friction = 0.98;
  static const double _bounceEnergy = 0.8;
  static const double _tiltSensitivity = 50.0;
  static const double _maxRadius = 100.0;
  static const double _growthAmount = 10.0;

  List<Dot> get dots => List.unmodifiable(_dots);

  void initialize(Size screenSize) {
    _screenSize = screenSize;

    if (_dots.isEmpty) {
      _addDot(
        position: Offset(screenSize.width / 2, screenSize.height / 2),
        color: DotColor.yellow,
      );
    }

    _startSensorListening();
    _startPhysicsLoop();
  }

  void _startSensorListening() {
    _accelerometerSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();

    _userAccelerometerSubscription =
        userAccelerometerEventStream().listen((event) {
      final magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!).inMilliseconds > 500) {
          _lastShakeTime = now;
          _onShake();
        }
      }
    });

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _onTilt(event.x, event.y);
    });
  }

  void _startPhysicsLoop() {
    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _updatePhysics();
    });
  }

  void _onShake() {
    _isShaking = true;
    for (final dot in _dots) {
      dot.velocity = Offset(
        (_random.nextDouble() - 0.5) * 800,
        (_random.nextDouble() - 0.5) * 800,
      );
    }
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _isShaking = false;
    });
  }

  void _onTilt(double x, double y) {
    if (_isShaking) return;

    for (final dot in _dots) {
      dot.velocity = Offset(
        dot.velocity.dx - x * _tiltSensitivity * 0.016,
        dot.velocity.dy + y * _tiltSensitivity * 0.016,
      );
    }
  }

  void _updatePhysics() {
    if (_screenSize == Size.zero) return;

    bool needsUpdate = false;

    for (final dot in _dots) {
      if (dot.velocity.distance < 0.1) continue;

      needsUpdate = true;

      dot.position = Offset(
        dot.position.dx + dot.velocity.dx * 0.016,
        dot.position.dy + dot.velocity.dy * 0.016,
      );

      dot.velocity = dot.velocity * _friction;

      if (dot.position.dx - dot.radius < 0) {
        dot.position = Offset(dot.radius, dot.position.dy);
        dot.velocity = Offset(-dot.velocity.dx * _bounceEnergy, dot.velocity.dy);
      } else if (dot.position.dx + dot.radius > _screenSize.width) {
        dot.position = Offset(_screenSize.width - dot.radius, dot.position.dy);
        dot.velocity = Offset(-dot.velocity.dx * _bounceEnergy, dot.velocity.dy);
      }

      if (dot.position.dy - dot.radius < 0) {
        dot.position = Offset(dot.position.dx, dot.radius);
        dot.velocity = Offset(dot.velocity.dx, -dot.velocity.dy * _bounceEnergy);
      } else if (dot.position.dy + dot.radius > _screenSize.height) {
        dot.position = Offset(dot.position.dx, _screenSize.height - dot.radius);
        dot.velocity = Offset(dot.velocity.dx, -dot.velocity.dy * _bounceEnergy);
      }
    }

    if (needsUpdate) {
      notifyListeners();
    }
  }

  void _addDot({required Offset position, required DotColor color}) {
    _dots.add(Dot(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      position: position,
      dotColor: color,
    ));
    notifyListeners();
  }

  Dot? findDotAtPosition(Offset position) {
    for (final dot in _dots.reversed) {
      final distance = (dot.position - position).distance;
      if (distance <= dot.radius) {
        return dot;
      }
    }
    return null;
  }

  void onTap(Offset position) {
    final dot = findDotAtPosition(position);
    if (dot != null) {
      final offset = Offset(
        (_random.nextDouble() - 0.5) * dot.radius * 2,
        (_random.nextDouble() - 0.5) * dot.radius * 2,
      );
      _addDot(
        position: dot.position + offset,
        color: dot.dotColor,
      );
    }
  }

  void onMultipleTaps(Offset position, int count) {
    final dot = findDotAtPosition(position);
    if (dot != null) {
      for (int i = 0; i < count; i++) {
        final angle = (2 * pi * i) / count;
        final offset = Offset(
          cos(angle) * dot.radius * 1.5,
          sin(angle) * dot.radius * 1.5,
        );
        _addDot(
          position: dot.position + offset,
          color: dot.dotColor,
        );
      }
    }
  }

  void onLongPress(Offset position) {
    final dot = findDotAtPosition(position);
    if (dot != null && dot.radius < _maxRadius) {
      dot.radius = min(dot.radius + _growthAmount, _maxRadius);
      notifyListeners();
    }
  }

  void onSwipe(Offset position) {
    final dot = findDotAtPosition(position);
    if (dot != null) {
      dot.dotColor = dot.dotColor.next;
      notifyListeners();
    }
  }

  void reset() {
    _dots.clear();
    if (_screenSize != Size.zero) {
      _addDot(
        position: Offset(_screenSize.width / 2, _screenSize.height / 2),
        color: DotColor.yellow,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _physicsTimer?.cancel();
    super.dispose();
  }
}
