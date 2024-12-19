import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/data/services/special_language_service.dart';
import 'package:xueli/models/special_language.dart';

import 'format_8_providers.dart';
import 'student_providers.dart';

final specialFormatLanguageProvider =
    FutureProvider.family<List<SpecialLanguageModel>, String>((ref, format) {
  final levelService = ref.watch(specialLanguageServiceProvider);
  return levelService.getFormatSentences(format);
});

final specialFormat7LanguageProvider =
    FutureProvider.family<List<SpecialLanguageModel>, int>((ref, session) {
  final levelService = ref.watch(specialLanguageServiceProvider);
  return levelService.getFormat7SessionSentences(session);
});

final specialListFormatLanguageProvider =
    FutureProvider.family<List<SpecialLanguageModel>, FilterClass>((ref, item) {
  final levelService = ref.watch(specialLanguageServiceProvider);
  return levelService.getListFormatSentences(item.format ?? "", item.schoolId);
});

final specialListLanguageProvider = FutureProvider.family
    .autoDispose<List<SpecialLanguageListModel>, String>((ref, format) {
  final levelService = ref.watch(specialLanguageServiceProvider);
  return levelService.getFormatLists(format);
});

final specialSessionGroupFormatLanguageProvider =
    FutureProvider.family<List<SpecialLanguageModel>, Format8FilterClass>(
        (ref, item) {
  final levelService = ref.watch(specialLanguageServiceProvider);
  return levelService.getSessionGroupFormatSentences(
      item.roundId.toString(), item.sessionId, item.group);
});

final format8SessionSpecialLanguageProvider =
    FutureProvider.family<List<SpecialLanguageModel>, int>((ref, session) {
  final levelService = ref.watch(specialLanguageServiceProvider);
  return levelService.getFormat8SessionSentences(session);
});

final format8SessionGroupSpecialLanguageProvider = Provider.autoDispose
    .family<AsyncValue<List<SpecialLanguageModel>>, Format8FilterClass>(
        (ref, item) {
  final usersList =
      ref.watch(format8SessionSpecialLanguageProvider(item.sessionId));
  return usersList.when(data: (items) {
    List<SpecialLanguageModel> newList = [];
    items.forEach((element) {
      if (element.group == item.group) {
        newList.add(element);
      }
    });
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});
