import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// final rxSharedPreferencesProvider = Provider<RxSharedPreferences>((ref) {
//   final prefs = ref.watch(sharedPreferencesProvider);
//   return RxSharedPreferences(prefs);
// });
