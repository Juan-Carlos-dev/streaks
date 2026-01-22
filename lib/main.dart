import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. AÑADE ESTA IMPORTACIÓN
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. DESCOMENTA Y USA ESTA LÍNEA (SIN OPCIONES)
  // Al no pasarle 'options', Flutter buscará automáticamente tu google-services.json
  await Firebase.initializeApp(); 

  runApp(
    const ProviderScope(
      child: SocialHabitTrackerApp(),
    ),
  );
}

class SocialHabitTrackerApp extends ConsumerWidget {
  const SocialHabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Social Habit Tracker',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}