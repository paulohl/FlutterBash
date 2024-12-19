import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/call_mode_model.dart';

import '../../core/dialog_helper.dart';

final callModeServiceProvider = Provider((ref) => CallModeService());

class CallModeService {
  final supabase = Supabase.instance.client;

  Future<bool> createCallMode(String audioLink, String updateFrequency,
      int sequence, bool isAudioBeforeName, int levelId) async {
    try {
      await supabase.from('CallMode').insert({
        "audio_link": audioLink,
        'update_frequency': updateFrequency,
        'level_id': levelId,
        'sequence': sequence,
        'audio_before_name': isAudioBeforeName,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateCallMode(String? audioLink, String updateFrequency,
      int sequence, bool isAudioBeforeName, int levelId, int id) async {
    final map = {
      'update_frequency': updateFrequency,
      'level_id': levelId,
      'sequence': sequence,
      'audio_before_name': isAudioBeforeName,
    };
    if (audioLink != null) {
      map["audio_link"] = audioLink;
    }
    try {
      await supabase.from('CallMode').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteCallMode(int id) async {
    try {
      await supabase.from('CallMode').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<CallModeModel>> getLevelCallMode(int levelId) async {
    List<CallModeModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('CallMode').select('*').eq('level_id', levelId);
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
