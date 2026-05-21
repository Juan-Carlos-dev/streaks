import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/habit.dart';
import '../providers/user_providers.dart';
import '../providers/habit_providers.dart';
import '../widgets/add_habit_modal.dart';
import '../../core/utils/widget_utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // 1. Variables de estado y constantes
  late DateTime _selectedDate;
  late DateTime _today;
  late DateTime _visibleDate;
  late final ScrollController _dayScrollController;
  
  final int _initialIndex = 5000;
  final double _itemWidth = 64.0; // Definimos la constante que faltaba

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = _today;
    _visibleDate = _today;

    // Compute the initial scroll offset immediately from the platform window,
    // so the ListView starts at "today" on the very first frame — no flash.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final screenWidth = view.physicalSize.width / view.devicePixelRatio;
    final initialOffset = (10.0 +
            (_initialIndex * _itemWidth) -
            (screenWidth / 2) +
            (_itemWidth / 2))
        .clamp(0.0, double.infinity);

    _dayScrollController = ScrollController(initialScrollOffset: initialOffset);
    _dayScrollController.addListener(_onScroll);
  }

  void _scrollToToday() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculamos la posición exacta de "Hoy" (el índice inicial) con el offset de padding de 10px
    final double targetOffset = 10.0 + (_initialIndex * _itemWidth) - (screenWidth / 2) + (_itemWidth / 2);

    // Animamos el scroll hasta esa posición
    _dayScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );

    // Opcional: Si quieres que también se seleccione el día de hoy al hacer doble click
    setState(() {
      _selectedDate = _today;
      _visibleDate = _today;
    });
  }

  // 2. Métodos de ayuda (Los que faltaban según el error)
  
  void _onScroll() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculamos la posición del centro de la pantalla
    final centerX = _dayScrollController.offset + (screenWidth / 2);
    
    // Determinamos el índice del elemento que está en el centro restando el padding de 10px
    final index = ((centerX - 10.0) / _itemWidth).round();
    
    // Obtenemos la fecha correspondiente a ese índice
    final dateAtCenter = _getDateFromIndex(index);

    // Si el mes o el año de la fecha en el centro es distinto al actual...
    if (dateAtCenter.month != _visibleDate.month || dateAtCenter.year != _visibleDate.year) {
      setState(() {
        _visibleDate = dateAtCenter; // Actualizamos el título de arriba
      });
    }
  }

  DateTime _getDateFromIndex(int index) {
    return DateTime(_today.year, _today.month, _today.day + (index - _initialIndex));
  }

  String _dayAbbr(int weekday) {
    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    return days[weekday - 1];
  }

  @override
  void dispose() {
    _dayScrollController.removeListener(_onScroll);
    _dayScrollController.dispose();
    super.dispose();
  }


  String _monthName(int month) {
    const months = [
      '', 'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
    ];
    return months[month];
  }

  void _showAddHabit() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddHabitModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final habitsAsync = ref.watch(habitListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // ── Month name ────────────────────────────────────────────
                // ANTES: _monthName(_selectedDate.month)
                // AHORA:
                Center(
                  child: Text(
                    _monthName(_visibleDate.month), // <--- Usa _visibleDate aquí
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Day strip ─────────────────────────────────────────────
              GestureDetector(
                onDoubleTap: _scrollToToday, // <--- Al hacer doble click ejecuta la función
                child: SizedBox(
                  height: 82,
                  child: ListView.builder(
                    controller: _dayScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: 10000,
                    itemBuilder: (context, index) {
                      final day = _getDateFromIndex(index);
                      final isSelected =
                          day.year == _selectedDate.year &&
                          day.month == _selectedDate.month &&
                          day.day == _selectedDate.day;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = day),
                        child: _DayPill(
                          dayAbbr: _dayAbbr(day.weekday),
                          dayNumber: day.day,
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),
                ),
              ),

                // White underline below strip
                Center(
                  child: Container(
                    width: 56,
                    height: 3,
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ── Greeting ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: userAsync.when(
                    data: (user) {
                      final name = user?.username ?? 'Usuario';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenido,',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const SizedBox(height: 60),
                    error: (_, __) => const Text(
                      'Bienvenido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ── Habits list ───────────────────────────────────────────
                Expanded(
                  child: habitsAsync.hasValue
                      ? _buildHabitsList(habitsAsync.value ?? [])
                      : habitsAsync.when(
                          data: (habits) => _buildHabitsList(habits),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        ),
                ),
              ],
            ),

            // ── Floating "Añadir hábito" pill ─────────────────────────────
            Positioned(
              bottom: 102,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _showAddHabit,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppColors.blueGradient,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueGradient.colors.first.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Añadir habito',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> habits) {
    if (habits.isEmpty) {
      return const Center(
        child: Text(
          'No tienes hábitos aún\n¡Crea tu primer hábito!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, height: 1.6),
        ),
      );
    }

    final filtered = habits.where((h) {
      return h.frequency.daysOfWeek.contains(_selectedDate.weekday);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No hay hábitos para este día',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _HabitTile(
        key: ValueKey(filtered[index].id),
        habit: filtered[index],
        selectedDate: _selectedDate,
        onComplete: () async {
          await ref
              .read(habitControllerProvider.notifier)
              .toggleHabitCompletion(filtered[index].id, _selectedDate);

          // Update native iOS/Android home screen widget
          final user = ref.read(currentUserProvider).value;
          final habitsList = ref.read(habitListProvider).value;
          final globalStreak = ref.read(globalStreakProvider);
          if (user != null && habitsList != null) {
            await WidgetUtils.updateNativeWidget(
              user: user,
              habits: habitsList,
              globalStreak: globalStreak,
            );
          }
        },
        onDelete: () async {
          await ref
              .read(habitControllerProvider.notifier)
              .deleteHabit(filtered[index].id);

          // Update native iOS/Android home screen widget
          final user = ref.read(currentUserProvider).value;
          final habitsList = ref.read(habitListProvider).value;
          final globalStreak = ref.read(globalStreakProvider);
          if (user != null && habitsList != null) {
            await WidgetUtils.updateNativeWidget(
              user: user,
              habits: habitsList,
              globalStreak: globalStreak,
            );
          }
        },
      ),
    );
  }
}

// ── Day pill ─────────────────────────────────────────────────────────────────

class _DayPill extends StatelessWidget {
  final String dayAbbr;
  final int dayNumber;
  final bool isSelected;

  const _DayPill({
    required this.dayAbbr,
    required this.dayNumber,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(32),
        border: isSelected
            ? Border.all(color: Colors.white, width: 2.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayAbbr,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          // White circle with blue day number
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => AppColors.blueGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  '$dayNumber',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Habit tile ────────────────────────────────────────────────────────────────

class _HabitTile extends StatefulWidget {
  final Habit habit;
  final DateTime selectedDate;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _HabitTile({
    super.key,
    required this.habit,
    required this.selectedDate,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  State<_HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<_HabitTile> with TickerProviderStateMixin {
  bool _isDeleteMode = false;
  int _futureAttemptCount = 0;
  
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 60),
    ]).animate(_popController);
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _popController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleDelete() async {
    await _popController.forward();
    widget.onDelete();
  }

  void _handleComplete() {
    final today = DateTime.now();
    final selectedDateOnly = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (selectedDateOnly.isAfter(todayDateOnly)) {
      _futureAttemptCount++;
      
      if (_futureAttemptCount >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No puedes completar hábitos de un día futuro'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        _futureAttemptCount = 0; // Reset after showing
      }
      
      _shakeController.forward(from: 0.0);
      return;
    }
    
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
      onLongPress: () {
        setState(() {
          _isDeleteMode = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _isDeleteMode
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.95),
                    blurRadius: 24,
                    spreadRadius: 6,
                  )
                ]
              : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isDeleteMode ? _buildDeleteMode() : _buildNormalMode(),
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildDeleteMode() {
    return SizedBox(
      key: const ValueKey('delete_mode'),
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '¿Quieres eliminar este hábito?',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tu progreso se perderá.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDeleteMode = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _handleDelete,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Sí', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalMode() {
    final color = AppColors.habitColorFromHex(widget.habit.color);
    
    final dateKey = '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
    final isCompleted = widget.habit.completedDates.containsKey(dateKey);
    final completedAt = widget.habit.completedDates[dateKey];
    
    final timeStr = isCompleted && completedAt != null 
        ? DateFormat('HH:mm').format(completedAt) 
        : '--:--';
        
    final subtitleText = isCompleted ? 'Completado a las $timeStr' : 'Aún no completado';

    return Row(
      key: const ValueKey('normal_mode'),
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            AppColors.habitIconFromString(widget.habit.icon),
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.habit.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitleText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _handleComplete,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: isCompleted ? AppColors.blueGradient : null,
              color: isCompleted ? null : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: isCompleted ? Colors.white : Colors.grey[400], size: 22),
          ),
        ),
      ],
    );
  }
}
