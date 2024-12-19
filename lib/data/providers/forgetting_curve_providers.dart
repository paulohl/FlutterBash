import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/data/services/forgetting_curve_service.dart';
import 'package:xueli/models/forgetting_curve_model.dart';

final allForgettingCurveProvider =
    FutureProvider<List<ForgettingCurveModel>>((ref) {
  final levelService = ref.watch(forgettingCurveServiceProvider);
  return levelService.getForgettingCurve();
});
