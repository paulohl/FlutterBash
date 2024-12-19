import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/class_model.dart';
import '../services/class_service.dart';

final schoolClassProvider =
    FutureProvider.family<List<ClassModel>, int>((ref, schoolId) {
  final levelService = ref.watch(classServiceProvider);
  return levelService.getSchoolClasses(schoolId);
});

final classProvider = FutureProvider.family<ClassModel?, int>((ref, classId) {
  final levelService = ref.watch(classServiceProvider);
  return levelService.getClass(classId);
});
