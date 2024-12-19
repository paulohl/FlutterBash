import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/english_name_model.dart';

import '../../core/dialog_helper.dart';

final englishNameServiceProvider = Provider((ref) => EnglishNameService());

class EnglishNameService {
  final supabase = Supabase.instance.client;

  Future<bool> createName(String? audioLink, String name, bool isBoy) async {
    try {
      await supabase.from('EnglishName').insert({
        'name': name,
        'is_boy': isBoy,
        'audio_link': audioLink,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateName(
      String? audioLink, String name, bool isBoy, int id) async {
    final map = {
      'name': name,
      'is_boy': isBoy,
    };
    if (audioLink != null) {
      map["audio_link"] = audioLink;
    }
    try {
      await supabase.from('EnglishName').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteName(int id) async {
    try {
      await supabase.from('EnglishName').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<EnglishNameModel>> getBoyNames() async {
    List<EnglishNameModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('EnglishName').select('*').eq('is_boy', true);
      data.forEach((element) {
        list.add(EnglishNameModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<EnglishNameModel>> getGirlNames() async {
    List<EnglishNameModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('EnglishName').select('*').eq('is_boy', false);
      data.forEach((element) {
        list.add(EnglishNameModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
