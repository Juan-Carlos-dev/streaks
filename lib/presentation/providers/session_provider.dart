import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_providers.dart';

class AppSessionTracker extends ConsumerStatefulWidget {
  final Widget child;
  const AppSessionTracker({super.key, required this.child});

  @override
  ConsumerState<AppSessionTracker> createState() => _AppSessionTrackerState();
}

class _AppSessionTrackerState extends ConsumerState<AppSessionTracker> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final uid = ref.read(authStateProvider).value;
      if (uid == null) return;

      _seconds += 10;
      if (_seconds >= 60) {
        _seconds = 0;
        _incrementMinute(uid);
      }
    });
  }

  Future<void> _incrementMinute(String uid) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final stats = Map<String, dynamic>.from(data['stats'] ?? {});
        final currentMinutes = stats['totalMinutes'] ?? 0;

        final widgetConfig = Map<String, dynamic>.from(data['widgetConfig'] ?? {});
        final minutesLog = Map<String, dynamic>.from(widgetConfig['minutesLog'] ?? {});
        final todayMinutes = minutesLog[dateKey] ?? 0;

        minutesLog[dateKey] = todayMinutes + 1;
        widgetConfig['minutesLog'] = minutesLog;

        stats['totalMinutes'] = currentMinutes + 1;

        transaction.update(userDoc, {
          'stats': stats,
          'widgetConfig': widgetConfig,
        });
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
