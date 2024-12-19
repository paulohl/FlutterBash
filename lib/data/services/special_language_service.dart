import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/data/services/format_8_service.dart';
import 'package:xueli/models/special_language.dart';

import '../../core/dialog_helper.dart';

final specialLanguageServiceProvider =
    Provider((ref) => SpecialLanguageService());

class SpecialLanguageService {
  final supabase = Supabase.instance.client;

  Future<bool> createSentence(
    String text,
    String chAudio,
    String enAudio,
    String chStdAudio,
    String enStdAudio,
    int playCount,
    int playCountDown,
    int sequence,
    String format,
    int? listId,
    int? sessionId,
    String? group,
  ) async {
    final map = {
      "text": text,
      "ch_audio": chAudio,
      "en_audio": enAudio,
      "ch_std_audio": chStdAudio,
      "en_std_audio": enStdAudio,
      "play_count": playCount,
      "play_count_counter": playCountDown,
      "sequence": sequence,
      "format": format,
    };
    if (listId != null) {
      map["list_id"] = listId;
    }
    if (sessionId != null) {
      map["session_id"] = sessionId;
    }
    if (group != null) {
      map["group"] = group;
    }
    try {
      await supabase.from('SpecialLanguage').insert(map);
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSentence(
      String text,
      String? chAudio,
      String? enAudio,
      String? chStdAudio,
      String? enStdAudio,
      int playCount,
      int playCountDown,
      int sequence,
      String format,
      int id) async {
    final map = {
      "text": text,
      "play_count": playCount,
      "play_count_counter": playCountDown,
      "sequence": sequence,
      "format": format,
    };
    if (chAudio != null) {
      map["ch_audio"] = chAudio;
    }
    if (enAudio != null) {
      map["en_audio"] = enAudio;
    }
    if (chStdAudio != null) {
      map["ch_std_audio"] = chStdAudio;
    }
    if (enStdAudio != null) {
      map["en_std_audio"] = enStdAudio;
    }
    try {
      await supabase.from('SpecialLanguage').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteCommonLanguage(int id) async {
    try {
      await supabase.from('SpecialLanguage').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<SpecialLanguageModel>> getFormatSentences(String format) async {
    List<SpecialLanguageModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('SpecialLanguage')
          .select('*')
          .eq('format', format);
      data.forEach((element) {
        list.add(SpecialLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SpecialLanguageModel>> getListFormatSentences(
      String format, int listId) async {
    List<SpecialLanguageModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('SpecialLanguage')
          .select('*')
          .match({'format': format, "list_id": listId});
      data.forEach((element) {
        list.add(SpecialLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SpecialLanguageModel>> getFormat8SessionSentences(
      int session) async {
    List<SpecialLanguageModel> list = [];
    try {
      final sessionModel = await Format8Service().getSession(session);
      if (sessionModel == null) {
        return [];
      }
      final PostgrestList data = await supabase
          .from('SpecialLanguage')
          .select('*')
          .match({'format': 8, "session_id": sessionModel.id});
      data.forEach((element) {
        list.add(SpecialLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SpecialLanguageModel>> getFormat7SessionSentences(
      int session) async {
    List<SpecialLanguageModel> list = [];
    try {
      final specialList = await getFormatLists(Formats.format7);
      if (specialList.isEmpty) {
        return [];
      }
      SpecialLanguageListModel? newList;
      int prev = 0;
      final res = session - 1;
      specialList.forEach((element) {
        if (newList == null) {
          final up = element.updateFrequency;
          if (res < (up + prev)) {
            newList = element;
          } else {
            prev += up;
          }
        }
      });
      if (newList == null) {
        return [];
      }
      list = await getListFormatSentences(Formats.format7, newList!.id);
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SpecialLanguageModel>> getSessionGroupFormatSentences(
      String format, int sessionId, String group) async {
    List<SpecialLanguageModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('SpecialLanguage')
          .select('*')
          .match({'format': format, "session_id": sessionId, "group": group});
      data.forEach((element) {
        list.add(SpecialLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createList(
      int sequence, String format, int updateFrequency) async {
    final map = {
      "sequence": sequence,
      "format": format,
      "update_frequency": updateFrequency,
    };
    try {
      await supabase.from('SpecialLanguageList').insert(map);
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateList(
      int sequence, String format, int updateFrequency, int id) async {
    final map = {
      "sequence": sequence,
      "format": format,
      "update_frequency": updateFrequency,
    };
    try {
      await supabase.from('SpecialLanguageList').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteList(int id) async {
    try {
      await supabase.from('SpecialLanguageList').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<SpecialLanguageListModel>> getFormatLists(String format) async {
    List<SpecialLanguageListModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('SpecialLanguageList')
          .select('*')
          .eq('format', format);
      data.forEach((element) {
        list.add(SpecialLanguageListModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
