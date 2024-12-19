import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/models/teacher_model.dart';

import '../services/teacher_service.dart';

final schoolTeacherProvider =
    FutureProvider.family<List<TeacherModel>, int>((ref, schoolId) {
  final levelService = ref.watch(teacherServiceProvider);
  return levelService.getSchoolTeachers(schoolId);
});
