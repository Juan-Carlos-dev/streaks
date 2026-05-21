import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/user_providers.dart';
import '../providers/habit_providers.dart';
import '../providers/feed_providers.dart';
import '../providers/preloading_provider.dart';
import '../widgets/lava_lamp_background.dart';
import '../widgets/logo_animation.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isMinTimeElapsed = false;

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

    final username = userAsync.value?.username ?? '';

    return Scaffold(
      body: LavaLampBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        'CREA HÁBITOS • CONSTRUYE TU RITMO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.0,
                          color: Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Bienvenido a tu nueva vida',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 1),
                // Glassmorphism Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: -10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedCrossFade(
                            firstChild: const Text(
                              '¡Te damos la bienvenida!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            secondChild: Text(
                              '¡Hola, $username!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            crossFadeState: username.isNotEmpty
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 400),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Preparando tu espacio de crecimiento personal...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Loading Checklist
                          _buildStatusRow(
                            'Personalizando tu perfil',
                            userLoaded,
                          ),
                          const SizedBox(height: 16),
                          _buildStatusRow(
                            'Sincronizando tus hábitos',
                            habitsLoaded,
                          ),
                          const SizedBox(height: 16),
                          _buildStatusRow(
                            'Conectando con la comunidad',
                            followingLoaded && suggestedLoaded,
                          ),
                          const SizedBox(height: 32),
                          // Circular glowing loader
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.85),
                                  ),
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isCompleted) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.green.withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withOpacity(0.6)
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.greenAccent,
                  )
                : SizedBox(
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
              color: isCompleted
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
