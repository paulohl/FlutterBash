import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/dialog_helper.dart';
import '../../models/card_model.dart';

final format7ServiceProvider = Provider((ref) => Format7Service());

class Format7Service {
  final supabase = Supabase.instance.client;

  Future<bool> createCard(String chineseAudio, String englishAudio, String text,
      int levelID) async {
    try {
      await supabase.from('Cards').insert({
        'name': text,
        'level_id': levelID,
        'en_audio': englishAudio,
        'ch_audio': chineseAudio
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateCard(String? chineseAudio, String? englishAudio,
      String text, int levelID, int id) async {
    try {
      final map = {
        'name': text,
        'level_id': levelID,
      };
      if (chineseAudio != null) {
        map["ch_audio"] = chineseAudio;
      }
      if (englishAudio != null) {
        map["en_audio"] = englishAudio;
      }
      await supabase.from('Cards').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteCard(int id) async {
    try {
      await supabase.from('Cards').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<CardModel>> getLevelCards(int levelID) async {
    List<CardModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('Cards').select('*').eq('level_id', levelID);
      data.forEach((element) {
        list.add(CardModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
