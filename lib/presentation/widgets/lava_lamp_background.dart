import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class LavaLampBackground extends StatefulWidget {
  final Widget child;

  const LavaLampBackground({super.key, required this.child});

  @override
  State<LavaLampBackground> createState() => _LavaLampBackgroundState();
}

class _LavaLampBackgroundState extends State<LavaLampBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark blue/black background gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF000F2E),
                Color(0xFF00040D),
              ],
            ),
          ),
        ),
        // Floating blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value * 2 * pi;
            return Stack(
              children: [
                // Blob 1: Glowing Cyan
                Positioned(
                  left: -50 + 100 * sin(t),
                  top: 100 + 150 * cos(t),
                  child: _buildBlob(
                    width: 300,
                    height: 300,
                    color: const Color(0xFF00F0FF).withOpacity(0.25),
                  ),
                ),
                // Blob 2: Royal Blue
                Positioned(
                  right: -80 + 120 * cos(t + pi / 2),
                  top: 250 + 120 * sin(t + pi / 2),
                  child: _buildBlob(
                    width: 320,
                    height: 320,
                    color: const Color(0xFF1E3A8A).withOpacity(0.55),
                  ),
                ),
                // Blob 3: Deep Indigo / Violet
                Positioned(
                  left: 20 + 80 * cos(t * 1.5),
                  bottom: 80 + 140 * sin(t * 1.5),
                  child: _buildBlob(
                    width: 280,
                    height: 280,
                    color: const Color(0xFF4F46E5).withOpacity(0.4),
                  ),
                ),
                // Blob 4: Soft Magenta / Electric Pink
                Positioned(
                  right: -40 + 90 * sin(t * 0.8 + pi),
                  bottom: -60 + 160 * cos(t * 0.8 + pi),
                  child: _buildBlob(
                    width: 340,
                    height: 340,
                    color: const Color(0xFFD946EF).withOpacity(0.25),
                  ),
                ),
              ],
            );
          },
        ),
        // Heavy blur to blend the bubbles organically
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 95, sigmaY: 95),
            child: Container(
              color: Colors.black.withOpacity(0.05), // Subtle darkening layer
            ),
          ),
        ),
        // Main content
        Positioned.fill(child: widget.child),
      ],
    );
  }

  Widget _buildBlob({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}
