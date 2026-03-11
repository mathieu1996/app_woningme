import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final phase = (_controller.value - delay + 1.0) % 1.0;
        final y = -10.0 * max(0.0, sin(phase * pi));
        final opacity = 0.4 + 0.6 * max(0.0, sin(phase * pi));
        return Transform.translate(
          offset: Offset(0, y),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/woningme_logo.png',
              height: 100,
            ),
            const SizedBox(height: 52),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0.0),
                const SizedBox(width: 12),
                _dot(0.15),
                const SizedBox(width: 12),
                _dot(0.30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
