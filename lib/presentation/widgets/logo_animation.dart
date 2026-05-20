import 'package:flutter/material.dart';

class LogoAnimation extends StatefulWidget {
  const LogoAnimation({super.key});

  @override
  State<LogoAnimation> createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rightY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // The bounce animation: goes from initialCy (32.5) to dropCy (87.5) and back to initialCy (32.5)
    // ease: [0.25, 0.46, 0.45, 0.94]
    // times: [0, 0.6, 1]
    _rightY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 32.5, end: 87.5).chain(
          CurveTween(curve: const Cubic(0.25, 0.46, 0.45, 0.94)),
        ),
        weight: 60.0, // 60% of the time (0% -> 60%)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 87.5, end: 32.5).chain(
          CurveTween(curve: const Cubic(0.25, 0.46, 0.45, 0.94)),
        ),
        weight: 40.0, // 40% of the time (60% -> 100%)
      ),
    ]).animate(_controller);

    // Run the animation infinitely in a loop
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 267,
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Esfera grande: cx=60, cy=60, r=60
              // Left: cx - r = 0, Top: cy - r = 0
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Esfera mediana: cx=158.5, cy=87.5, r=32.5
              // Left: cx - r = 126, Top: cy - r = 55
              Positioned(
                left: 126,
                top: 55,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Esfera bote: cx=234.5, cy=animated, r=32.5
              // Left: cx - r = 202, Top: cy - r = _rightY.value - 32.5
              Positioned(
                left: 202,
                top: _rightY.value - 32.5,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
