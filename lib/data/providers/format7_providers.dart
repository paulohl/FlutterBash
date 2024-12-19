import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/card_model.dart';
import '../services/format_7_service.dart';
import 'student_providers.dart';

final levelCardProvider =
    FutureProvider.family<List<CardModel>, int>((ref, levelID) {
  final levelService = ref.watch(format7ServiceProvider);
  return levelService.getLevelCards(levelID);
});

final levelCardSessionSortedProvider = Provider.autoDispose
    .family<AsyncValue<List<CardModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(levelCardProvider(item.schoolId));
  return usersList.when(data: (items) {
    var list = items;
    list.sort((a, b) => a.sequence.compareTo(b.sequence));
    if (list.isNotEmpty) {
      var index = 1;
      //session = item.classId
      while (index < item.classId) {
        final model = list.removeAt(0);
        list.add(model);
        index += 1;
      }
    }
    return AsyncData(list);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});
