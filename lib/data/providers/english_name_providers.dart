import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/english_name_model.dart';
import '../services/english_name_service.dart';

final englishGirlNameProvider = FutureProvider<List<EnglishNameModel>>((ref) {
  final levelService = ref.watch(englishNameServiceProvider);
  return levelService.getGirlNames();
});

final englishBoyNameProvider = FutureProvider<List<EnglishNameModel>>((ref) {
  final levelService = ref.watch(englishNameServiceProvider);
  return levelService.getBoyNames();
});
