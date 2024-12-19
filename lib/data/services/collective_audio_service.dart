import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/call_mode_model.dart';

import '../../core/dialog_helper.dart';

final collectiveAudioServiceProvider =
    Provider((ref) => CollectiveAudioService());

class CollectiveAudioService {
  final supabase = Supabase.instance.client;

  Future<bool> createCollectiveAudio(String audioLink, String englishLink,
      String updateFrequency, int sequence, int levelId) async {
    try {
      await supabase.from('CollectiveAudio').insert({
        "audio_link": audioLink,
        "en_audio": englishLink,
        'update_frequency': updateFrequency,
        'level_id': levelId,
        'sequence': sequence,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateCollectiveAudio(String? audioLink, String? englishLink,
      String updateFrequency, int sequence, int levelId, int id) async {
    final map = {
      'update_frequency': updateFrequency,
      'level_id': levelId,
      'sequence': sequence,
    };
    if (audioLink != null) {
      map["audio_link"] = audioLink;
    }
    if (englishLink != null) {
      map["en_audio"] = englishLink;
    }
    try {
      await supabase.from('CollectiveAudio').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteCollectiveAudio(int id) async {
    try {
      await supabase.from('CollectiveAudio').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<CallModeModel>> getLevelCollectiveAudio(int levelId) async {
    List<CallModeModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('CollectiveAudio')
          .select('*')
          .eq('level_id', levelId);
      data.forEach((element) {
        list.add(CallModeModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
