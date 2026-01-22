import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0099FF), // Top background color
      body: Stack(
        children: [
          // Background Gradient or Color
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Bar (Empty or Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                       // Settings icon?
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Avatar
                Container(
                  padding: const EdgeInsets.all(4), // White border
                  decoration: const BoxDecoration(
                    color: Colors.transparent, 
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Content Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40), // Optional symmetry
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // User Name & Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Andrea Rustov',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  _buildStat('10.5k', 'Seguidores'),
                                  const SizedBox(width: 20),
                                  _buildStat('347', 'Siguiendo'),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Menu List Card
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(Icons.email_outlined, 'Email', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
                                _buildDivider(),
                                _buildMenuItem(
                                  Icons.person_outline, 
                                  'Nombre de usuario', 
                                  trailing: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.purple),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.purple),
                                  ),
                                ),
                                _buildDivider(),
                                _buildMenuItem(Icons.grid_view, 'Personalizar widget', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
                                _buildDivider(),
                                _buildMenuItem(Icons.password, 'Cambiar contraseña', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
                                _buildDivider(),
                                _buildMenuItem(Icons.notifications_outlined, 'Notificaciones y recordatorios', trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)),
                                _buildDivider(),
                                _buildMenuItem(
                                  Icons.cancel_outlined, 
                                  'Cerrar sesion', 
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                  onTap: () => authRepository.signOut(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Delete Account Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                              label: Text(
                                'Eliminar cuenta',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Or transparent with border
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey);
  }
}
