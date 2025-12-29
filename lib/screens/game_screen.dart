import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dot.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  static const _multiTapWindow = Duration(milliseconds: 300);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      context.read<GameProvider>().initialize(size);
    });
  }

  void _handleTap(Offset position, GameProvider gameProvider) {
    final now = DateTime.now();

    if (_lastTapTime != null &&
        _lastTapPosition != null &&
        now.difference(_lastTapTime!) < _multiTapWindow &&
        (position - _lastTapPosition!).distance < 50) {
      _tapCount++;
    } else {
      if (_tapCount > 1 && _lastTapPosition != null) {
        gameProvider.onMultipleTaps(_lastTapPosition!, _tapCount);
      } else if (_lastTapPosition != null) {
        gameProvider.onTap(_lastTapPosition!);
      }
      _tapCount = 1;
    }

    _lastTapTime = now;
    _lastTapPosition = position;

    Future.delayed(_multiTapWindow, () {
      if (_lastTapTime == now) {
        if (_tapCount > 1) {
          gameProvider.onMultipleTaps(position, _tapCount);
        } else {
          gameProvider.onTap(position);
        }
        _tapCount = 0;
        _lastTapPosition = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Stack(
            children: [
              // Game area with gesture detection
              GestureDetector(
                onTapUp: (details) {
                  _handleTap(details.localPosition, gameProvider);
                },
                onLongPressStart: (details) {
                  gameProvider.onLongPress(details.localPosition);
                },
                onHorizontalDragEnd: (details) {
                  if (_lastTapPosition != null) {
                    gameProvider.onSwipe(_lastTapPosition!);
                  }
                },
                onPanStart: (details) {
                  _lastTapPosition = details.localPosition;
                },
                onPanEnd: (details) {
                  if (_lastTapPosition != null &&
                      details.velocity.pixelsPerSecond.distance > 100) {
                    gameProvider.onSwipe(_lastTapPosition!);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: _DotsPainter(dots: gameProvider.dots),
                  ),
                ),
              ),

              // Top bar with menu
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dot count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${gameProvider.dots.length} dots',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Menu button
                      PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.more_vert),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'reset':
                              gameProvider.reset();
                              break;
                            case 'logout':
                              context.read<AuthProvider>().logout();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                Icon(Icons.refresh),
                                SizedBox(width: 8),
                                Text('Start Over'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout),
                                SizedBox(width: 8),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Instructions overlay (shown briefly)
              if (gameProvider.dots.length == 1)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Tap the dot!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final List<Dot> dots;

  _DotsPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    for (final dot in dots) {
      final paint = Paint()
        ..color = dot.dotColor.color
        ..style = PaintingStyle.fill;

      // Draw shadow
      final shadowPaint = Paint()
        ..color = dot.dotColor.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(
        dot.position + const Offset(0, 4),
        dot.radius,
        shadowPaint,
      );

      // Draw dot
      canvas.drawCircle(dot.position, dot.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) {
    return true;
  }
}
