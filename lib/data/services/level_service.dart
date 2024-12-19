import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/dialog_helper.dart';
import '../../models/level_model.dart';

final levelServiceProvider = Provider((ref) => LevelService());

class LevelService {
  final supabase = Supabase.instance.client;

  Future<List<LevelModel>> getAllLevels() async {
    List<LevelModel> list = [];
    try {
      final PostgrestList data = await supabase.from('Levels').select('*');
      data.forEach((element) {
        list.add(LevelModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
