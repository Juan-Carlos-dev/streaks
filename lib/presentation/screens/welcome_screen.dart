import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/feed_providers.dart';
import '../providers/preloading_provider.dart';
import '../widgets/lava_lamp_background.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isMinTimeElapsed = false;
  bool _isTypingCompleted = false;

  @override
  void initState() {
    super.initState();
    // Enforce a minimum display duration of 2.5 seconds for visual flow.
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isMinTimeElapsed = true;
        });
      }
    });
  }

  void _checkPreloadingStatus(
    bool userLoaded,
    bool habitsLoaded,
    bool followingLoaded,
    bool suggestedLoaded,
  ) {
    if (_isMinTimeElapsed &&
        _isTypingCompleted &&
        userLoaded &&
        habitsLoaded &&
        followingLoaded &&
        suggestedLoaded) {
      // Use post-frame callback to avoid updating providers during build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(preloadingCompletedProvider.notifier).setCompleted(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final habitsAsync = ref.watch(habitListProvider);
    final followingAsync = ref.watch(followingUidsProvider);
    final suggestedAsync = ref.watch(suggestedUsersProvider);

    final userLoaded = userAsync.hasValue;
    final habitsLoaded = habitsAsync.hasValue;
    final followingLoaded = followingAsync.hasValue;
    final suggestedLoaded = suggestedAsync.hasValue;

    // Check status reactively on every build
    _checkPreloadingStatus(
      userLoaded,
      habitsLoaded,
      followingLoaded,
      suggestedLoaded,
    );

    return Scaffold(
      body: LavaLampBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular glowing loader
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.08),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.9),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Typing text
              TypingText(
                text: 'Crea hábitos • Construye tu ritmo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
                onComplete: () {
                  if (mounted) {
                    setState(() {
                      _isTypingCompleted = true;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  final VoidCallback? onComplete;

  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.speed = const Duration(milliseconds: 80),
    this.onComplete,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayedText = '';
  int _charIndex = 0;
  Timer? _typingTimer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorFlashing();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.speed, (timer) {
      if (_charIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_charIndex];
          _charIndex++;
        });
      } else {
        _typingTimer?.cancel();
        if (widget.onComplete != null) {
          widget.onComplete!();
        }
      }
    });
  }

  void _startCursorFlashing() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_displayedText${_showCursor ? "|" : " "}',
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
