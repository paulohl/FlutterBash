import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/models/call_mode_model.dart';

import '../services/call_mode_service.dart';

final callModeProvider =
    FutureProvider.family<List<CallModeModel>, int>((ref, levelId) {
  final levelService = ref.watch(callModeServiceProvider);
  return levelService.getLevelCallMode(levelId);
});

final getCurrentCallModeProvider = Provider.autoDispose
    .family<AsyncValue<CallModeModel?>, int>((ref, levelId) {
  final usersList = ref.watch(callModeProvider(levelId));
  final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
  return usersList.when(data: (items) {
    CallModeModel? newList;
    if (items.isNotEmpty) {
      if (teacher != null) {
        var total = 0;
        items.forEach((element) {
          total += int.tryParse(element.update_frequency) ?? 0;
        });
        final res = (teacher.format_s_call_mode % total);

        int prev = 0;
        items.forEach((element) {
          if (newList == null) {
            final up = int.tryParse(element.update_frequency) ?? 0;
            if (res < (up + prev)) {
              newList = element;
            } else {
              prev += up;
            }
          }
        });
        // debugPrint("res callmode $res, $total, ${newList?.id}");
      } else {
        newList = (items.first);
      }
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});
