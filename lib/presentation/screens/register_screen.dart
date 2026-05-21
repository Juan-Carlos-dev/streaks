import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';
import '../widgets/lava_lamp_background.dart';
import '../widgets/marquee_row.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() {
      ref.read(usernameCheckProvider.notifier).checkUsername(_usernameController.text);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final usernameState = ref.read(usernameCheckProvider);
    if (usernameState.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, espera a que se compruebe el nombre de usuario')),
      );
      return;
    }
    if (usernameState.isAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de usuario no está disponible o es inválido')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      ref.read(registerControllerProvider.notifier).signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _usernameController.text.trim(),
          );
    }
  }

  Widget? _buildUsernameSuffix(UsernameCheckState state) {
    if (state.username.trim().length < 3) return null;
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        ),
      );
    }
    if (state.isAvailable == true) {
      return const Icon(Icons.check_circle, color: Colors.greenAccent);
    }
    if (state.isAvailable == false) {
      return const Icon(Icons.cancel, color: Colors.redAccent);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(registerControllerProvider, (_, state) {
      if (state.hasError) {
        final errorMsg = state.error.toString();
        if (errorMsg.contains('Ya existe una cuenta con este correo')) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Correo ya registrado',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Ya existe una cuenta vinculada a este correo electrónico. ¿Quieres iniciar sesión en su lugar?',
                style: TextStyle(color: Colors.black54),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/login');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    });

    final registerState = ref.watch(registerControllerProvider);
    final usernameState = ref.watch(usernameCheckProvider);

    return Scaffold(
      body: LavaLampBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Empieza tu camino hacia mejores hábitos',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nombre de usuario',
                      prefixIcon: const Icon(Icons.person_outline),
                      suffixIcon: _buildUsernameSuffix(usernameState),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Introduce un nombre';
                      }
                      if (v.trim().length < 3) {
                        return 'Mínimo 3 caracteres';
                      }
                      if (usernameState.isAvailable == false) {
                        return 'El nombre de usuario ya está cogido';
                      }
                      return null;
                    },
                  ),
                  if (usernameState.isAvailable == false &&
                      usernameState.suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Sugerencias:',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: usernameState.suggestions.map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              label: Text(
                                suggestion,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onPressed: () {
                                ref
                                    .read(usernameCheckProvider.notifier)
                                    .selectSuggestion(suggestion);
                                _usernameController.text = suggestion;
                                _usernameController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: suggestion.length),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Introduce tu correo' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Introduce una contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: registerState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: registerState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 48),
                  ExcludeSemantics(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                          child: OverflowBox(
                            maxWidth: MediaQuery.of(context).size.width * 1.4,
                            child: const MarqueeRow(
                              words: ['MOTIVACIÓN', 'ESFUERZO', 'CONSTANCIA', 'DISCIPLINA', 'ENFOQUE'],
                              speed: 30.0,
                              fontSize: 14.0,
                              baseAngle: -0.03, // Mild slant
                              phaseOffset: 0.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 38,
                          child: OverflowBox(
                            maxWidth: MediaQuery.of(context).size.width * 1.4,
                            child: const MarqueeRow(
                              words: ['SUPERACIÓN', 'VOLUNTAD', 'HÁBITO', 'DEDICACIÓN', 'RUTINA'],
                              speed: 45.0,
                              fontSize: 22.0,
                              baseAngle: -0.08, // Steeper slant
                              reverse: true,
                              phaseOffset: 1.5, // Out of phase for organic desync
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 32,
                          child: OverflowBox(
                            maxWidth: MediaQuery.of(context).size.width * 1.4,
                            child: const MarqueeRow(
                              words: ['RESILIENCIA', 'CRECIMIENTO', 'PROPÓSITO', 'FOCO', 'ACTITUD'],
                              speed: 25.0,
                              fontSize: 16.0,
                              baseAngle: -0.05, // Medium slant
                              phaseOffset: 3.1, // Out of phase
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 36,
                          child: OverflowBox(
                            maxWidth: MediaQuery.of(context).size.width * 1.4,
                            child: const MarqueeRow(
                              words: ['ÉXITO', 'FUERZA', 'PROGRESO', 'VOLUNTAD', 'CONSTANCIA'],
                              speed: 35.0,
                              fontSize: 20.0,
                              baseAngle: -0.10, // Deepest slant
                              reverse: true,
                              phaseOffset: 4.6, // Out of phase
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
