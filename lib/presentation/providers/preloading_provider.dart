import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

class PreloadingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Listen to authentication state changes.
    // If the user logs out (authState becomes null/empty), reset preloading completed state to false.
    ref.listen<AsyncValue<String?>>(authStateProvider, (previous, next) {
      if (next.value == null) {
        state = false;
      }
    });
    return false;
  }

  void setCompleted(bool completed) {
    state = completed;
  }
}

final preloadingCompletedProvider = NotifierProvider<PreloadingCompletedNotifier, bool>(() {
  return PreloadingCompletedNotifier();
});
