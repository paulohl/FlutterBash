import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/data/services/school_service.dart';
import 'package:xueli/models/school_model.dart';

final allSchoolsProvider = FutureProvider<List<SchoolModel>>((ref) {
  final levelService = ref.watch(schoolServiceProvider);
  return levelService.getAllSchools();
});
