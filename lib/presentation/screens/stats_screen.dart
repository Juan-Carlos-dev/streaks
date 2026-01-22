import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // 1. Streak Header
              Text(
                '52',
                style: GoogleFonts.outfit(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu racha diaria',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '¡Vas por buen camino, Juan Carlos!',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // 2. Streak Days Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStreakDay(true, '51'),
                  const SizedBox(width: 8),
                  _buildStreakDay(true, '52'),
                  const SizedBox(width: 8),
                  _buildStreakDay(true, '53'),
                  const SizedBox(width: 8),
                  _buildStreakDay(true, '54'),
                  const SizedBox(width: 8),
                  _buildStreakDay(false, '55', label: '53'), // Mocking future days
                  const SizedBox(width: 8),
                  _buildStreakDay(false, '56', label: '54'),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Stats Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tus estadísticas',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Días', '52'),
                        _buildStatItem('Tareas', '30'),
                        _buildStatItem('Seguidores', '112'),
                        _buildStatItem('Minutos', '1247', isHighlighted: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0099FF), Color(0xFF00C6FF)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Ver un desglose',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Heatmap (Mock Grid)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 28, // 4 weeks
                      itemBuilder: (context, index) {
                        // Mock active days pattern
                        bool isActive = [0, 1, 3, 4, 5, 8, 9, 10, 12, 15, 16, 17, 18, 20, 21, 22, 25, 26].contains(index);
                         return Container(
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF0099FF) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text("Marzo", style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold))
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Habits List
              Container(
                 padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Center(
                       child: Text(
                        'Tus habitos',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                                           ),
                     ),
                    const SizedBox(height: 16),
                    _buildHabitProgress('Meditar', 0.7),
                    const SizedBox(height: 12),
                    _buildHabitProgress('Hacer deporte', 0.4),
                    const SizedBox(height: 12),
                    _buildHabitProgress('Hacer la compra', 0.9),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakDay(bool isCompleted, String day, {String? label}) {
    if (isCompleted) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF0099FF),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Text(
          label ?? day,
          style: GoogleFonts.outfit(
            color: const Color(0xFF0099FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildStatItem(String label, String value, {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            decoration: isHighlighted ? TextDecoration.underline : null,
            decorationColor: const Color(0xFF0099FF),
            decorationThickness: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitProgress(String label, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator( // Requires percent_indicator package
          lineHeight: 24.0,
          percent: percent,
          backgroundColor: Colors.grey[200],
          progressColor: const Color(0xFF0099FF),
          barRadius: const Radius.circular(12),
          padding: EdgeInsets.zero,
          animation: true,
        ),
      ],
    );
  }
}
