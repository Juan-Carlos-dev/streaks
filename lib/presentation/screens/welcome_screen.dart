import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00C6FF), // Cyan-ish Blue
              Color(0xFF0072FF), // Primary Blue
              Colors.black,      // Fade into black at the bottom
              Colors.black,
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Text(
                  'Encuentra tu ritmo,\nCrea tu equilibrio.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Alcanza tus metas y construye la vida que siempre has querido.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: () => context.go('/login'), // Assuming login is next
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text('Comenzar'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    '¿Ya tienes una cuenta? Iniciar sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
