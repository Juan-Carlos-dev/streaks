import 'package:home_widget/home_widget.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/user.dart';

class WidgetUtils {
  static const String appGroupId = 'group.com.example.streaks';
  static const String iOSWidgetName = 'RunnerWidget';

  /// Updates the native iOS home screen widget using the user's config and current stats.
  static Future<void> updateNativeWidget({
    required User user,
    required List<Habit> habits,
    required int globalStreak,
  }) async {
    try {
      final config = user.widgetConfig;
      final String widgetType = config['widgetType'] ?? 'streak';
      final String widgetBg = config['widgetBg'] ?? 'dark';
      final String widgetColor = config['widgetColor'] ?? '#0052FF';
      final String selectedHabitId = config['selectedHabitId'] ?? 'all';

      // 1. Calculate today's progress
      final today = DateTime.now();
      final weekday = today.weekday; // 1 = Mon ... 7 = Sun
      final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final scheduledToday = habits.where((h) => h.frequency.daysOfWeek.contains(weekday)).toList();
      final int completedCount = scheduledToday.where((h) => h.completedDates.containsKey(dateKey)).length;
      final int totalCount = scheduledToday.length;

      // 2. Fetch star habit details
      final starHabit = habits.firstWhere(
        (h) => h.id == selectedHabitId,
        orElse: () => habits.isNotEmpty
            ? habits.first
            : Habit(
                id: 'mock',
                userId: 'mock',
                title: 'Hacer Ejercicio',
                color: '#0052FF',
                icon: 'fitness_center',
                frequency: const HabitFrequency(daysOfWeek: [1, 2, 3]),
                startDate: DateTime.now(),
                completedDates: const {},
              ),
      );

      // 3. Configure App Group inside home_widget
      await HomeWidget.setAppGroupId(appGroupId);

      // 4. Save data fields for WidgetKit
      await HomeWidget.saveWidgetData<String>('widgetType', widgetType);
      await HomeWidget.saveWidgetData<String>('widgetBg', widgetBg);
      await HomeWidget.saveWidgetData<String>('widgetColor', widgetColor);
      await HomeWidget.saveWidgetData<String>('gradientStart', user.customGradient.isNotEmpty ? user.customGradient[0] : '#3D8EF0');
      await HomeWidget.saveWidgetData<String>('gradientEnd', user.customGradient.length > 1 ? user.customGradient[1] : '#64B5F6');
      await HomeWidget.saveWidgetData<int>('streakCount', globalStreak);
      await HomeWidget.saveWidgetData<int>('progressCompleted', completedCount);
      await HomeWidget.saveWidgetData<int>('progressTotal', totalCount);
      await HomeWidget.saveWidgetData<String>('starHabitTitle', starHabit.title);
      await HomeWidget.saveWidgetData<String>('starHabitIcon', starHabit.icon);
      await HomeWidget.saveWidgetData<int>('starHabitCount', starHabit.completedDates.length);

      // 5. Signal native system to reload the widget timeline
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
      );
      
      print('WidgetUtils: Native Home Screen Widget successfully updated in the background!');
    } catch (e) {
      print('WidgetUtils: Error updating native home screen widget: $e');
    }
  }
}
