import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/format_8_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/models/box_card_model.dart';
import 'package:xueli/models/box_model.dart';
import 'package:xueli/models/session_model.dart';
import 'package:xueli/models/sound_effect_model.dart';
import 'package:collection/collection.dart';

class Format8FilterClass extends Equatable {
  int sessionId;
  int roundId;
  String group;

  Format8FilterClass(
      {required this.sessionId, required this.roundId, required this.group});

  @override
  List<Object?> get props => [sessionId, roundId, group];
}

final boxCardsProvider =
    FutureProvider.family<List<BoxCardModel>, int>((ref, boxId) {
  final levelService = ref.watch(format8Service);
  return levelService.getBoxCards(boxId);
});

final sessionBoxExplodedAudioProvider =
    FutureProvider.family<List<EightBoxExplodedAudioModel>, int>((ref, boxId) {
  final levelService = ref.watch(format8Service);
  return levelService.getBoxExplodedAudio(boxId);
});

final soundEffectsProvider =
    FutureProvider.family<List<SoundEffectModel>, Format8FilterClass>(
        (ref, item) {
  final levelService = ref.watch(format8Service);
  return levelService.getSoundEffect(item.sessionId, item.group);
});

final teacherPhrasesProvider = FutureProvider<List<TeacherPhraseModel>>((ref) {
  final levelService = ref.watch(format8Service);
  return levelService.getTeacherPhrases();
});

final allSessionsProvider = FutureProvider<List<SessionModel>>((ref) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessions();
});

final sessionRoundsProvider =
    FutureProvider.family<List<RoundModel>, int>((ref, sessionId) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionRounds(sessionId);
});

final sessionRoundsGroupDataProvider =
    FutureProvider.family<List<RoundDataModel>, Format8FilterClass>(
        (ref, item) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionRoundsGroupData(
      item.sessionId, item.roundId, item.group);
});

final sessionRoundsGroupDataCTPProvider =
    FutureProvider.family<List<EightChineseTeacherModel>, int>(
        (ref, roundGroupId) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionRoundsGroupDataCTPAudio(roundGroupId);
});

final sessionRoundsGroupDataGamePhraseProvider =
    FutureProvider.family<List<EightGamePhraseModel>, int>((ref, roundGroupId) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionRoundsGroupDataGamePhrases(roundGroupId);
});

///New
final sessionDetailsProvider =
    FutureProvider.family<SessionModel?, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getSession(session);
});

final sessionRoundsWithSessionNumberProvider =
    FutureProvider.family<List<RoundModel>, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionRoundsWithSessionNumber(session);
});

final sessionRoundsDataWithSessionNumberProvider =
    FutureProvider.family<List<RoundDataModel>, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionRoundsDataWithSessionNumber(session);
});

final sessionCurrentRoundsDataWithSessionNumberProvider = Provider.autoDispose
    .family<AsyncValue<RoundDataModel?>, Format8FilterClass>((ref, item) {
  final usersList =
      ref.watch(sessionRoundsDataWithSessionNumberProvider(item.sessionId));
  return usersList.when(data: (items) {
    RoundDataModel? newList;
    if (items.isNotEmpty) {
      newList = items.firstWhereOrNull((element) =>
          element.round_id == item.roundId && element.group == item.group);
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final allBoxesProvider = FutureProvider<List<BoxModel>>((ref) {
  final levelService = ref.watch(format8Service);
  return levelService.getAllBoxes();
});

final allBoxRoundsProvider =
    FutureProvider.family<List<BoxModel>, int>((ref, boxSequence) {
  final levelService = ref.watch(format8Service);
  return levelService.getBoxesWithRounds(boxSequence);
});

final boxProvider = FutureProvider.family<BoxModel?, int>((ref, box) {
  final levelService = ref.watch(format8Service);
  return levelService.getBox(box);
});

final boxRoundProvider = Provider.autoDispose
    .family<AsyncValue<BoxModel?>, FilterClass>((ref, item) {
  final usersList = ref.watch(classStudentsFormat8SortedProvider(item));
  final allBoxes = ref.watch(allBoxRoundsProvider(item.schoolId));
  return allBoxes.when(data: (items) {
    final res =
        items.firstWhereOrNull((element) => element.round == item.classId);
    return AsyncData(res);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final sessionBoxesSessionNumberProvider = Provider.autoDispose
    .family<AsyncValue<List<BoxModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(classStudentsFormat8SortedProvider(item));
  final allBoxes = ref.watch(allBoxesProvider);
  return allBoxes.when(data: (items) {
    List<BoxModel> newList = [];
    final session = item.session!;
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final sessionSoundEffectsProvider =
    FutureProvider.family<List<SoundEffectModel>, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionSoundEffect(session);
});

final sessionGroupSoundProvider = Provider.autoDispose
    .family<AsyncValue<List<SoundEffectModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(sessionSoundEffectsProvider(item.session!));
  return usersList.when(data: (items) {
    List<SoundEffectModel> newList = [];
    final group = item.format!;
    newList = items.where((element) => element.group == group).toList();
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

///For downloading data
final allBoxRoundsWithListProvider =
    FutureProvider.family<List<BoxModel>, List<int>>((ref, boxSequence) {
  final levelService = ref.watch(format8Service);
  return levelService.getBoxesFromList(boxSequence);
});

final allBoxRoundsExplodedAudioWithListProvider =
    FutureProvider.family<List<EightBoxExplodedAudioModel>, List<int>>(
        (ref, boxSequence) {
  final levelService = ref.watch(format8Service);
  return levelService.getBoxExplodedAudioFromList(boxSequence);
});

final allBoxRoundsBoxCardsWithListProvider =
    FutureProvider.family<List<BoxCardModel>, List<int>>((ref, boxSequence) {
  final levelService = ref.watch(format8Service);
  return levelService.getBoxCardsFromList(boxSequence);
});

final sessionAllRoundsGroupDataCTPProvider =
    FutureProvider.family<List<EightChineseTeacherModel>, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionCTPFromSession(session);
});

final sessionAllSoundEffectsProvider =
    FutureProvider.family<List<SoundEffectModel>, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getAllSoundEffectsFromSession(session);
});

final sessionAllRoundsGroupDataGamePhraseProvider =
    FutureProvider.family<List<EightGamePhraseModel>, int>((ref, session) {
  final levelService = ref.watch(format8Service);
  return levelService.getSessionAllRoundsGroupDataGamePhrases(session);
});

final getCurrentTeacherPhraseProvider =
    Provider.autoDispose<AsyncValue<List<TeacherPhraseModel>>>((ref) {
  final usersList = ref.watch(teacherPhrasesProvider);
  final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
  return usersList.when(data: (items) {
    List<TeacherPhraseModel> newList = [];

    if (items.isNotEmpty) {
      // items.sort((a, b) {
      //   if (b.is_start) {
      //     return 1;
      //   }
      //   return -1;
      // });
      List<TeacherPhraseModel> beginList = [];
      List<TeacherPhraseModel> endList = [];
      var beginTotal = 0;
      var endTotal = 0;
      items.forEach((element) {
        // print("element ${element.is_start} ${element.id}");
        if (element.is_start) {
          beginList.add(element);
          beginTotal += element.update_frequency;
        } else {
          endList.add(element);
          endTotal += element.update_frequency;
        }
      });
      if (teacher != null) {
        beginList.sort((a, b) => a.sequence.compareTo(b.sequence));
        endList.sort((a, b) => a.sequence.compareTo(b.sequence));
        final beginRes = (teacher.eight_tp_begin_frequency % beginTotal);
        final endRes = (teacher.eight_tp_end_frequency % endTotal);

        int beginPrev = 0;
        int endPrev = 0;
        beginList.forEach((element) {
          if (newList.length < 1) {
            final up = element.update_frequency;
            if (beginRes < (up + beginPrev)) {
              newList.add(element);
            } else {
              beginPrev += up;
            }
          }
        });
        endList.forEach((element) {
          if (newList.length < (beginList.isEmpty ? 1 : 2)) {
            final up = element.update_frequency;
            if (endRes < (up + endPrev)) {
              newList.add(element);
            } else {
              endPrev += up;
            }
          }
        });
        // debugPrint("res callmode ${newList.first.id} ${newList.last.id}");
      } else {
        //first begin and end
        if (beginList.isNotEmpty) {
          newList.add(beginList.first);
        }
        if (endList.isNotEmpty) {
          newList.add(endList.first);
        }
      }
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});
// final boxRoundProvider =
//     Provider.autoDispose.family<AsyncValue<BoxModel?>, List<int>>((ref, item) {
//   // final usersList = ref.watch(classStudentsFormat8SortedProvider(item));
//   final allBoxes = ref.watch(allBoxRoundsWithListProvider(item));
//   return allBoxes.when(data: (items) {
//     final res =
//         items.firstWhereOrNull((element) => element.round == item.classId);
//     return AsyncData(res);
//   }, error: (Object error, StackTrace stackTrace) {
//     return AsyncError(error, stackTrace);
//   }, loading: () {
//     return const AsyncLoading();
//   });
// });
