import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MarqueeRow extends StatefulWidget {
  final List<String> words;
  final double speed; // Pixels per second
  final bool reverse;
  final double fontSize;
  final double baseAngle;
  final double floatAmplitude;
  final double swayAmplitude;
  final double phaseOffset;

  const MarqueeRow({
    super.key,
    required this.words,
    required this.speed,
    required this.fontSize,
    required this.baseAngle,
    this.reverse = false,
    this.floatAmplitude = 6.0,
    this.swayAmplitude = 0.012,
    this.phaseOffset = 0.0,
  });

  @override
  State<MarqueeRow> createState() => _MarqueeRowState();
}

class _MarqueeRowState extends State<MarqueeRow> with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Ticker _ticker;
  double _offset = 0.0;
  Duration _lastElapsed = Duration.zero;
  final GlobalKey _rowKey = GlobalKey();
  double? _singleWidth;

  late double _currentAngle;
  double _currentTranslationY = 0.0;

  @override
  void initState() {
    super.initState();
    _currentAngle = widget.baseAngle;
    _scrollController = ScrollController();
    _ticker = createTicker((elapsed) {
      if (!mounted || !_scrollController.hasClients) return;

      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final double delta = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
      _lastElapsed = elapsed;

      // Capping delta if there is a massive jump (e.g., app paused/resumed or debugging break)
      if (delta > 0.1) return;

      if (_singleWidth == null) {
        final renderBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null && renderBox.hasSize) {
          _singleWidth = renderBox.size.width;
        }
      }

      final singleWidth = _singleWidth;
      if (singleWidth == null || singleWidth <= 0) return;

      final double totalSeconds = elapsed.inMilliseconds / 1000.0;

      // Slow organic rotation sway
      const double swayFreq = 0.4;
      _currentAngle = widget.baseAngle +
          math.sin(totalSeconds * swayFreq + widget.phaseOffset) * widget.swayAmplitude;

      // Slow organic vertical floating
      const double floatFreq = 0.6;
      _currentTranslationY =
          math.sin(totalSeconds * floatFreq + widget.phaseOffset) * widget.floatAmplitude;

      // Gentle speed fluctuations (+/- 15%)
      const double speedFreq = 0.3;
      final double speedFactor =
          1.0 + math.cos(totalSeconds * speedFreq + widget.phaseOffset) * 0.15;

      final double step = widget.speed * speedFactor * delta;
      if (widget.reverse) {
        _offset -= step;
        if (_offset <= 0) {
          _offset += singleWidth;
        }
      } else {
        _offset += step;
        if (_offset >= singleWidth) {
          _offset -= singleWidth;
        }
      }

      setState(() {});
      _scrollController.jumpTo(_offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildWordWidgets() {
    return widget.words.map((word) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
        child: Text(
          word,
          style: TextStyle(
            color: Colors.white.withOpacity(0.15),
            fontWeight: FontWeight.w300,
            fontSize: widget.fontSize,
            letterSpacing: 1.5,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _currentTranslationY),
      child: Transform.rotate(
        angle: _currentAngle,
        child: SizedBox(
          height: widget.fontSize + 16,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                Row(
                  key: _rowKey,
                  children: _buildWordWidgets(),
                ),
                Row(
                  children: _buildWordWidgets(),
                ),
                Row(
                  children: _buildWordWidgets(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
