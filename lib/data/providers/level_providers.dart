import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/data/services/level_service.dart';
import 'package:xueli/models/level_model.dart';

final allLevelsProvider = FutureProvider<List<LevelModel>>((ref) {
  final levelService = ref.watch(levelServiceProvider);
  return levelService.getAllLevels();
});
