import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/data/services/student_service.dart';
import 'package:xueli/models/student_model.dart';

class FilterClass extends Equatable {
  int classId;
  int schoolId;
  int? teacherId;
  String? format;
  int? session;
  Color? groupColor;

  FilterClass(
      {required this.classId,
      required this.schoolId,
      this.format,
      this.session,
      this.groupColor,
      this.teacherId});

  @override
  List<Object?> get props =>
      [classId, schoolId, format, teacherId, session, groupColor];
}

final classStudentsProvider =
    FutureProvider.family<List<StudentModel>, FilterClass>((ref, item) {
  final levelService = ref.watch(studentServiceProvider);
  return levelService.getClassStudents(
      item.schoolId, item.classId, item.teacherId!);
});

// final classStudentsFormat7SortedProvider =
//     FutureProvider.family<List<StudentModel>, FilterClass>((ref, item) {
//   final levelService = ref.watch(studentServiceProvider);
//   return levelService.getClassStudents(
//       item.schoolId, item.classId, item.teacherId!);
// });

final classStudentsFormat7SortedProvider = Provider.autoDispose
    .family<AsyncValue<List<StudentModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(classStudentsProvider(FilterClass(
      classId: item.classId,
      schoolId: item.schoolId,
      teacherId: item.teacherId)));
  return usersList.when(data: (items) {
    items.sort((a, b) => a.format_seven_sort.compareTo(b.format_seven_sort));
    return AsyncData(items);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final classStudentsFormat8SortedProvider = Provider.autoDispose
    .family<AsyncValue<List<StudentModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(classStudentsProvider(FilterClass(
      classId: item.classId,
      schoolId: item.schoolId,
      teacherId: item.teacherId)));
  return usersList.when(data: (items) {
    List<StudentModel> redList = [];
    List<StudentModel> orange = [];
    List<StudentModel> yellow = [];
    List<StudentModel> green = [];
    List<StudentModel> blue = [];
    List<StudentModel> purple = [];
    items.forEach((element) {
      if (element.eight_group == GroupNames.red) {
        redList.add(element);
      } else if (element.eight_group == GroupNames.orange) {
        orange.add(element);
      } else if (element.eight_group == GroupNames.yellow) {
        yellow.add(element);
      } else if (element.eight_group == GroupNames.green) {
        green.add(element);
      } else if (element.eight_group == GroupNames.blue) {
        blue.add(element);
      } else if (element.eight_group == GroupNames.purple) {
        purple.add(element);
      }
    });
    redList.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    orange.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    yellow.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    green.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    blue.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    purple.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    List<StudentModel> newList = [];
    if (item.groupColor == AppColors.groupRed) {
      newList.addAll(redList);
    } else if (item.groupColor == AppColors.groupOrange) {
      newList.addAll(orange);
    } else if (item.groupColor == AppColors.groupYellow) {
      newList.addAll(yellow);
    } else if (item.groupColor == AppColors.groupGreen) {
      newList.addAll(green);
    } else if (item.groupColor == AppColors.groupBlue) {
      newList.addAll(blue);
    } else if (item.groupColor == AppColors.groupPurple) {
      newList.addAll(purple);
    }
    // newList.addAll(redList);
    // newList.addAll(orange);
    // newList.addAll(yellow);
    // newList.addAll(green);
    // newList.addAll(blue);
    // newList.addAll(purple);
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});

final classStudentsFormat8SortedAllStudentsProvider = Provider.autoDispose
    .family<AsyncValue<List<StudentModel>>, FilterClass>((ref, item) {
  final usersList = ref.watch(classStudentsProvider(FilterClass(
      classId: item.classId,
      schoolId: item.schoolId,
      teacherId: item.teacherId)));
  return usersList.when(data: (items) {
    List<StudentModel> redList = [];
    List<StudentModel> orange = [];
    List<StudentModel> yellow = [];
    List<StudentModel> green = [];
    List<StudentModel> blue = [];
    List<StudentModel> purple = [];
    items.forEach((element) {
      if (element.eight_group == GroupNames.red) {
        redList.add(element);
      } else if (element.eight_group == GroupNames.orange) {
        orange.add(element);
      } else if (element.eight_group == GroupNames.yellow) {
        yellow.add(element);
      } else if (element.eight_group == GroupNames.green) {
        green.add(element);
      } else if (element.eight_group == GroupNames.blue) {
        blue.add(element);
      } else if (element.eight_group == GroupNames.purple) {
        purple.add(element);
      }
    });
    redList.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    orange.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    yellow.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    green.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    blue.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    purple.sort((a, b) => a.eight_sort.compareTo(b.eight_sort));
    List<StudentModel> newList = [];
    newList.addAll(redList);
    newList.addAll(orange);
    newList.addAll(yellow);
    newList.addAll(green);
    newList.addAll(blue);
    newList.addAll(purple);
    return AsyncData(newList);
  }, error: (Object error, StackTrace stackTrace) {
    return AsyncError(error, stackTrace);
  }, loading: () {
    return const AsyncLoading();
  });
});
