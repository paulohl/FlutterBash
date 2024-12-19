import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/models/forgetting_curve_model.dart';

final forgettingCurveServiceProvider =
    Provider((ref) => ForgettingCurveService());

class ForgettingCurveService {
  final supabase = Supabase.instance.client;

  Future<bool> createForgettingCurve(int day) async {
    try {
      await supabase.from('ForgettingCurve').insert({
        "day": day,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateForgettingCurve(int day, int id) async {
    final map = {
      'day': day,
    };
    try {
      await supabase.from('ForgettingCurve').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteForgettingCurve(int id) async {
    try {
      await supabase.from('ForgettingCurve').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<ForgettingCurveModel>> getForgettingCurve() async {
    List<ForgettingCurveModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('ForgettingCurve').select('*');
      data.forEach((element) {
        list.add(ForgettingCurveModel.fromMap(element));
      });
      list.sort((a, b) => a.day.compareTo(b.day));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
