import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/common_language_service.dart';
import 'package:xueli/models/common_language_category_model.dart';
import 'package:xueli/models/common_language_repeat_model.dart';
import 'package:xueli/models/evaluation_model.dart';
import 'package:xueli/models/teacher_common_language_model.dart';

import '../../models/common_language_model.dart';

class CommonFilterClass extends Equatable {
  int levelId;
  List<int> ids;
  int? categoryID;

  CommonFilterClass(
      {required this.levelId, required this.ids, this.categoryID});

  @override
  List<Object?> get props => [levelId, ids, categoryID];
}

final commonLanguageCategoriesProvider =
    FutureProvider.family<List<CommonLanguageCategoryModel>, int>(
        (ref, levelId) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getLevelCategories(levelId);
});

final commonLanguage5RandomCategoriesProvider = Provider.autoDispose
    .family<AsyncValue<List<CommonLanguageCategoryModel>>, int>((ref, levelId) {
  final usersList = ref.watch(commonLanguageCategoriesProvider(levelId));
  return usersList.when(data: (items) {
    List<CommonLanguageCategoryModel> newList = [];
    if (items.length > 5) {
      while (newList.length < 5) {
        var element = items[Random().nextInt(items.length)];
        if (!newList.contains(element)) {
          newList.add(element);
        }
      }
    } else {
      newList = items;
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final commonLanguageSentenceCategoriesProvider = Provider.autoDispose
    .family<AsyncValue<List<CommonLanguageCategoryModel>>, CommonFilterClass>(
        (ref, item) {
  final usersList = ref.watch(commonLanguageCategoriesProvider(item.levelId));
  return usersList.when(data: (items) {
    List<CommonLanguageCategoryModel> newList = [];
    newList.add(CommonLanguageCategoryModel(
        id: 0, name: "All", level_id: item.levelId));
    items.forEach((element) {
      if (item.ids.contains(element.id)) {
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

final commonLanguageSentenceProvider =
    FutureProvider.family<List<CommonLanguageModel>, FilterClass>((ref, item) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getLevelCategorySentences(item.schoolId, item.classId);
});

final commonLanguage2SentenceProvider = Provider.autoDispose
    .family<AsyncValue<List<CommonLanguageModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(commonLanguageSentenceProvider(item));

  return usersList.when(data: (items) {
    List<CommonLanguageModel> newList = [];
    if (items.length > 2) {
      while (newList.length < 2) {
        var element = items[Random().nextInt(items.length)];
        if (!newList.contains(element)) {
          newList.add(element);
        }
      }
    } else {
      newList = items;
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final commonLanguageLevelSentencesProvider =
    FutureProvider.family<List<CommonLanguageModel>, int>((ref, levelId) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getLevelSentences(levelId);
});

final commonLanguageLevelNonRepeatedSentencesProvider =
    FutureProvider.family<List<CommonLanguageModel>, FilterClass>((ref, item) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getLevelNonRepeatedSentences(
      item.classId, item.teacherId!);
});

final commonLanguage10RandomLevelSentenceProvider = Provider.autoDispose
    .family<AsyncValue<List<CommonLanguageModel>>, FilterClass>((ref, item) {
  final usersList =
      ref.watch(commonLanguageLevelNonRepeatedSentencesProvider(item));
  return usersList.when(data: (items) {
    List<CommonLanguageModel> newList = [];
    if (items.length > 10) {
      while (newList.length < 10) {
        var element = items[Random().nextInt(items.length)];
        if (!newList.contains(element)) {
          newList.add(element);
        }
      }
    } else {
      newList = items;
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final commonLanguageTeacherUncompletedListProvider =
    FutureProvider.family<List<TeacherCommonLanguageModel>, int>(
        (ref, teacherId) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getTeacherCommonLanguageUnCompletedList(teacherId);
});

final commonLanguageTodayProvider =
    FutureProvider.family<List<CommonLanguageModel>, int>((ref, teacherId) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getTodayCommonLanguage(teacherId);
});

final commonLanguageRepeatTodayProvider =
    FutureProvider.family<List<CommonLanguageRepeatModel>, int>(
        (ref, teacherId) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getRepeatTodayCommonLanguage(teacherId);
});

final commonLanguageTeacherEvaluationListProvider = Provider.autoDispose
    .family<AsyncValue<List<TeacherCommonLanguageModel>>, int>(
        (ref, teacherId) {
  final usersList =
      ref.watch(commonLanguageTeacherUncompletedListProvider(teacherId));
  return usersList.when(data: (items) {
    final f = DateFormat('yyyy-MM-dd');
    List<TeacherCommonLanguageModel> newList = [];
    items.forEach((element) {
      // && !element.is_evaluated
      if (element.repeat_date.length == 4) {
        if (element.repeat_date.last == f.format(DateTime.now())) {
          newList.add(element);
        }
      }
    });
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final commonLanguageSentenceListProvider = FutureProvider.family<
    List<CommonLanguageModel>, List<TeacherCommonLanguageModel>>((ref, item) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getCommonLanguageFromList(item);
});

final commonLanguageTeacherLearnedSentencesProvider =
    FutureProvider.family<List<CommonLanguageModel>, FilterClass>((ref, item) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getLevelLearnedSentences(item.classId, item.teacherId!);
});

final getEvaluationResult =
    FutureProvider.family<EvaluationModel?, int>((ref, commonId) {
  final levelService = ref.watch(commonLanguageServiceProvider);
  return levelService.getEvaluation(commonId);
});

final commonLanguageTodayWithCategoryProvider = Provider.autoDispose
    .family<AsyncValue<List<CommonLanguageModel>>, CommonFilterClass>(
        (ref, item) {
  final usersList = ref.watch(commonLanguageTodayProvider(item.levelId));
  return usersList.when(data: (items) {
    final f = DateFormat('yyyy-MM-dd');
    List<CommonLanguageModel> newList = [];
    if (item.categoryID != null && item.categoryID != 0) {
      items.forEach((element) {
        if (element.category_id == item.categoryID) {
          newList.add(element);
        }
      });
    } else {
      newList.addAll(items);
    }
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});
