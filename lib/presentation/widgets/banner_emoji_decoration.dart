import 'package:flutter/material.dart';
import 'dart:math';

class BannerEmojiDecoration extends StatelessWidget {
  final String emojiString;
  final String style;
  final String seed;
  final double size;
  final double rotation;
  final double opacity;
  final double spacingFactor;

  const BannerEmojiDecoration({
    super.key,
    required this.emojiString,
    required this.style,
    required this.seed,
    required this.size,
    required this.rotation,
    required this.opacity,
    required this.spacingFactor,
  });

  @override
  Widget build(BuildContext context) {
    if (style == 'none' || emojiString.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<String> emojis = emojiString.characters.map((c) => c).toList();
    if (emojis.isEmpty) return const SizedBox.shrink();

    final double rad = rotation * 3.14159265358979323846 / 180.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        if (style == 'grid') {
          final double stepX = (size * 3.0 * spacingFactor).clamp(10.0, 500.0);
          final double stepY = (size * 2.5 * spacingFactor).clamp(10.0, 400.0);
          final List<Widget> children = [];
          int emojiIndex = 0;

          for (double y = 10; y < height; y += stepY) {
            for (double x = 15; x < width; x += stepX) {
              final emoji = emojis[emojiIndex % emojis.length];
              emojiIndex++;
              children.add(
                Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: rad,
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: size),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return Stack(children: children);
        }

        if (style == 'diagonal') {
          final double step = (size * 2.2 * spacingFactor).clamp(10.0, 300.0);
          final double stepY = (size * 1.25 * spacingFactor).clamp(10.0, 200.0);
          final List<Widget> children = [];
          int emojiIndex = 0;

          for (double offset = -height; offset < width + height; offset += step) {
            for (double t = 0; t < height; t += stepY) {
              final x = offset + t;
              final y = t;
              if (x >= 0 && x < width && y >= 0 && y < height) {
                final emoji = emojis[emojiIndex % emojis.length];
                emojiIndex++;
                children.add(
                  Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: rad,
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: size * 0.88),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
          }
          return Stack(children: children);
        }

        if (style == 'scattered') {
          final List<Widget> children = [];
          int hash = seed.hashCode;
          double nextRandom() {
            hash = (1103515245 * hash + 12345) & 0x7fffffff;
            return hash / 2147483647.0;
          }

          final densityFactor = (size * size * spacingFactor).clamp(50.0, 5000.0);
          final count = (width * height / (densityFactor * 1.5)).clamp(4, 50).toInt();
          
          for (int i = 0; i < count; i++) {
            final x = nextRandom() * (width - size - 8);
            final y = nextRandom() * (height - size - 8);
            final scale = 0.8 + nextRandom() * 0.6;
            final randomRot = nextRandom() * 0.6 - 0.3;
            final emoji = emojis[i % emojis.length];

            children.add(
              Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: rad + randomRot,
                  child: Opacity(
                    opacity: opacity,
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: size * scale),
                    ),
                  ),
                ),
              ),
            );
          }
          return Stack(children: children);
        }

        if (style == 'radial') {
          final List<Widget> children = [];
          final centerX = width / 2;
          final centerY = height / 2;
          int emojiIndex = 0;

          final double stepR = (size * 1.6 * spacingFactor).clamp(10.0, 300.0);
          final double maxRadius = (width > height ? width : height) * 0.8;

          for (double r = stepR; r < maxRadius; r += stepR) {
            final circumference = 2 * pi * r;
            final int count = (circumference / (size * 1.8 * spacingFactor)).clamp(2, 100).toInt();
            for (int i = 0; i < count; i++) {
              final double angle = (2 * pi * i) / count;
              final double x = centerX + r * cos(angle) - (size / 2);
              final double y = centerY + r * sin(angle) - (size / 2);

              if (x >= -size && x < width && y >= -size && y < height) {
                final emoji = emojis[emojiIndex % emojis.length];
                emojiIndex++;
                children.add(
                  Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: rad + angle,
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: size),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }
          }
          return Stack(children: children);
        }

        if (style == 'spiral') {
          final List<Widget> children = [];
          final centerX = width / 2;
          final centerY = height / 2;
          int emojiIndex = 0;

          double theta = 0.5;
          final double spacing = size * 1.5 * spacingFactor;
          final double b = size * 0.4 * spacingFactor;
          final double maxRadius = (width > height ? width : height) * 0.9;

          while (true) {
            final double r = b * theta;
            if (r > maxRadius) break;

            final double x = centerX + r * cos(theta) - (size / 2);
            final double y = centerY + r * sin(theta) - (size / 2);

            if (x >= -size && x < width && y >= -size && y < height) {
              final emoji = emojis[emojiIndex % emojis.length];
              emojiIndex++;
              children.add(
                Positioned(
                  left: x,
                  top: y,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: rad + theta,
                      child: Text(
                        emoji,
                        style: TextStyle(fontSize: size),
                      ),
                    ),
                  ),
                ),
              );
            }
            theta += spacing / r;
          }
          return Stack(children: children);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
