import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/box_card_model.dart';
import 'package:xueli/models/box_model.dart';
import 'package:xueli/models/session_model.dart';
import 'package:xueli/models/sound_effect_model.dart';

import '../../core/dialog_helper.dart';

final format8Service = Provider((ref) => Format8Service());

class Format8Service {
  final supabase = Supabase.instance.client;

  Future<bool> createCard(
      String chineseAudio,
      String englishAudio,
      String text,
      int playCount,
      int playCountBackward,
      int sequence,
      bool isWord,
      int boxId) async {
    try {
      await supabase.from('FormatEightBoxDetails').insert({
        'text': text,
        'en_audio': englishAudio,
        'ch_audio': chineseAudio,
        'sequence': sequence,
        'play_count': playCount,
        'play_count_backwards': playCountBackward,
        'box_id': boxId,
        'is_word': isWord,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateCard(
      String? chineseAudio,
      String? englishAudio,
      String text,
      int playCount,
      int playCountBackward,
      int sequence,
      int boxId,
      bool isWord,
      int id) async {
    try {
      final map = {
        'text': text,
        'sequence': sequence,
        'play_count': playCount,
        'play_count_backwards': playCountBackward,
        'box_id': boxId,
        'is_word': isWord,
      };
      if (chineseAudio != null) {
        map["ch_audio"] = chineseAudio;
      }
      if (englishAudio != null) {
        map["en_audio"] = englishAudio;
      }
      await supabase
          .from('FormatEightBoxDetails')
          .update(map)
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteCard(int id) async {
    try {
      await supabase.from('FormatEightBoxDetails').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<BoxCardModel>> getBoxCards(int boxId) async {
    List<BoxCardModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('FormatEightBoxDetails')
          .select('*')
          .eq('box_id', boxId);
      data.forEach((element) {
        list.add(BoxCardModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createBox(
      String group, String title, int sequence, int boxLevel) async {
    try {
      await supabase.from('FormatEightBox').upsert({
        'title': title,
        'group': group,
        'sequence': sequence,
        'box_level': boxLevel,
        'id': sequence,
      });
      // await supabase.from('FormatEightBox').insert({
      //   'title': title,
      //   'group': group,
      //   'sequence': sequence,
      //   'box_level': boxLevel,
      // });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateBox(
      String group, String title, int sequence, int boxLevel, int id) async {
    try {
      final map = {
        'title': title,
        'group': group,
        'sequence': sequence,
        'box_level': boxLevel,
      };
      await supabase.from('FormatEightBox').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteBox(int id) async {
    try {
      await supabase.from('FormatEightBox').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<BoxCardModel>> getLevelBoxes(int levelId) async {
    List<BoxCardModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('FormatEightBox')
          .select('*')
          .eq('level_id', levelId);
      data.forEach((element) {
        list.add(BoxCardModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createBoxExplodedAudio(
    String audio,
    int sequence,
    int boxId,
  ) async {
    try {
      await supabase.from('EightBoxExplodedAudio').insert({
        'sequence': sequence,
        "box_id": boxId,
        "audio_link": audio,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateBoxExplodedAudio(
      String? audio, int sequence, int boxId, int id) async {
    try {
      final Map<String, dynamic> map = {
        'sequence': sequence,
        "box_id": boxId,
      };
      if (audio != null) {
        map["audio_link"] = audio;
      }
      await supabase
          .from('EightBoxExplodedAudio')
          .update(map)
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteBoxExplodedAudio(int id) async {
    try {
      await supabase.from('EightBoxExplodedAudio').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<EightBoxExplodedAudioModel>> getBoxExplodedAudio(
      int boxId) async {
    List<EightBoxExplodedAudioModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('EightBoxExplodedAudio')
          .select('*')
          .eq('box_id', boxId);
      data.forEach((element) {
        list.add(EightBoxExplodedAudioModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createSoundEffect(
      String audioLink, int sequence, int sessionId, String group) async {
    try {
      await supabase.from('GameSoundEffect').insert({
        'audio_link': audioLink,
        'sequence': sequence,
        'session_id': sessionId,
        'group': group,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSoundEffect(String? audioLink, int sequence, int sessionId,
      String group, int id) async {
    try {
      final Map<String, dynamic> map = {
        'sequence': sequence,
        'session_id': sessionId,
        'group': group,
      };
      if (audioLink != null) {
        map["audio_link"] = audioLink;
      }
      await supabase.from('GameSoundEffect').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSoundEffect(int id) async {
    try {
      await supabase.from('GameSoundEffect').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<SoundEffectModel>> getSoundEffect(
      int sessionId, String group) async {
    List<SoundEffectModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('GameSoundEffect')
          .select('*')
          .match({'session_id': sessionId, "group": group});
      data.forEach((element) {
        list.add(SoundEffectModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createTeacherPhrase(String chAudio, String englishAudio,
      String text, int sequence, int updateFrequency, bool isStart) async {
    try {
      await supabase.from('TeacherPhares').insert({
        'ch_audio': chAudio,
        'en_audio': englishAudio,
        'text': text,
        'sequence': sequence,
        'update_frequency': updateFrequency,
        'is_start': isStart,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateTeacherPhrase(
      String? chAudio,
      String? englishAudio,
      String text,
      int sequence,
      int updateFrequency,
      bool isStart,
      int id) async {
    try {
      final Map<String, dynamic> map = {
        'text': text,
        'sequence': sequence,
        'update_frequency': updateFrequency,
        'is_start': isStart,
      };
      if (chAudio != null) {
        map["en_audio"] = chAudio;
      }
      if (englishAudio != null) {
        map["ch_audio"] = englishAudio;
      }
      await supabase.from('TeacherPhares').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteTeacherPhrase(int id) async {
    try {
      await supabase.from('TeacherPhares').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<TeacherPhraseModel>> getTeacherPhrases() async {
    List<TeacherPhraseModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('TeacherPhares').select('*');
      data.forEach((element) {
        list.add(TeacherPhraseModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createSession(int session) async {
    try {
      await supabase.from('EightSession').insert({'session': session});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSession(int session, int id) async {
    try {
      final Map<String, dynamic> map = {'session': session};
      await supabase.from('EightSession').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSession(int id) async {
    try {
      await supabase.from('EightSession').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<SessionModel?> getSession(int session) async {
    SessionModel? list;
    try {
      final PostgrestList data = await supabase
          .from('EightSession')
          .select('*')
          .match({'session': session});
      data.forEach((element) {
        list = (SessionModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SessionModel>> getSessions() async {
    List<SessionModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('EightSession').select('*');
      data.forEach((element) {
        list.add(SessionModel.fromMap(element));
      });
      list.sort((a, b) => a.session.compareTo(b.session));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createSessionRound(int sessionId, int round) async {
    try {
      await supabase.from('EightRound').insert({
        'round': round,
        "session_id": sessionId,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRound(int sessionId, int round, int id) async {
    try {
      final Map<String, dynamic> map = {
        'round': round,
        "session_id": sessionId
      };
      await supabase.from('EightRound').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSessionRound(int id) async {
    try {
      await supabase.from('EightRound').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<RoundModel>> getSessionRounds(int sessionId) async {
    List<RoundModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('EightRound')
          .select('*')
          .eq('session_id', sessionId);
      data.forEach((element) {
        list.add(RoundModel.fromMap(element));
      });
      list.sort((a, b) => a.round.compareTo(b.round));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createSessionRoundGroupData(
      int sessionId, int round, String group) async {
    try {
      await supabase.from('EightRoundData').insert({
        'round_id': round,
        "session_id": sessionId,
        "group": group,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRoundGroupData(
      int sessionId, int round, String group, int id) async {
    try {
      final Map<String, dynamic> map = {
        'round_id': round,
        "session_id": sessionId,
        "group": group,
      };
      await supabase.from('EightRoundData').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSessionRoundGroupData(int id) async {
    try {
      await supabase.from('EightRoundData').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<RoundDataModel>> getSessionRoundsGroupData(
      int sessionId, int roundId, String group) async {
    List<RoundDataModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('EightRoundData')
          .select('*')
          // .eq("round_id", roundId);
          .match(
              {'round_id': roundId, 'session_id': sessionId, 'group': group});
      data.forEach((element) {
        list.add(RoundDataModel.fromMap(element));
      });
      if (list.isEmpty) {
        await createSessionRoundGroupData(sessionId, roundId, group);
        final PostgrestList data = await supabase
            .from('EightRoundData')
            .select('*')
            // .eq("round_id", roundId);
            .match(
                {'round_id': roundId, 'session_id': sessionId, 'group': group});
        data.forEach((element) {
          list.add(RoundDataModel.fromMap(element));
        });
      }
      // list.sort((a, b) => a.round.compareTo(b.round));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> updateSessionRoundGroupDataCTP(int sessionId, int round,
      String group, String text, String? link, int id) async {
    try {
      final Map<String, dynamic> map = {
        'ctp_text': text,
      };
      if (link != null) {
        map["ctp_ch_audio"] = link;
      }
      await supabase.from('EightRoundData').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRoundGroupDataETP(
      int sessionId,
      int round,
      String group,
      String text,
      String? link,
      String? prefix,
      String? suffix,
      int count,
      int backwards,
      int id) async {
    try {
      final Map<String, dynamic> map = {
        'etp_text': text,
        'etp_count': count,
        'etp_count_backwards': backwards,
      };
      if (link != null) {
        map["etp_en_audio"] = link;
      }
      if (prefix != null) {
        map["etp_pre_audio"] = prefix;
      }
      if (suffix != null) {
        map["etp_suf_audio"] = suffix;
      }
      await supabase.from('EightRoundData').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRoundGroupDataETI(
      int sessionId,
      int round,
      String group,
      String text,
      String? link,
      String? prefix,
      String? suffix,
      int id) async {
    try {
      final Map<String, dynamic> map = {
        'eti_text': text,
      };
      if (link != null) {
        map["eti_en_audio"] = link;
      }
      if (prefix != null) {
        map["eti_pre_audio"] = prefix;
      }
      if (suffix != null) {
        map["eti_suf_audio"] = suffix;
      }
      await supabase.from('EightRoundData').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRoundGroupDataSL(
      int sessionId,
      int round,
      String group,
      String text,
      String? enLink,
      String? enPreLink,
      String? enSufLink,
      String? chLink,
      String? chPreLink,
      String? chSufLink,
      int id) async {
    try {
      final Map<String, dynamic> map = {
        'std_text': text,
      };
      if (chLink != null) {
        map["std_ch_audio"] = chLink;
      }
      if (enLink != null) {
        map["std_en_audio"] = enLink;
      }

      if (enPreLink != null) {
        map["std_en_pre"] = enPreLink;
      }
      if (enSufLink != null) {
        map["std_en_suf"] = enSufLink;
      }

      if (chPreLink != null) {
        map["std_ch_pre"] = chPreLink;
      }
      if (chSufLink != null) {
        map["std_ch_suf"] = chSufLink;
      }
      await supabase.from('EightRoundData').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> createSessionRoundGroupDataCTP(
    int sessionId,
    int round,
    String group,
    String audio,
    int sequence,
    int groupDataId,
  ) async {
    try {
      await supabase.from('EightChineseTeacherPhrase').insert({
        'sequence': sequence,
        "round_group_id": groupDataId,
        "audio_link": audio,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRoundGroupDataCTPAudio(
      int sessionId,
      int round,
      String group,
      String? audio,
      int sequence,
      int groupDataId,
      int id) async {
    try {
      final Map<String, dynamic> map = {
        'sequence': sequence,
        "round_group_id": groupDataId,
      };
      if (audio != null) {
        map["audio_link"] = audio;
      }
      await supabase
          .from('EightChineseTeacherPhrase')
          .update(map)
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSessionRoundGroupDataCTPAudio(int id) async {
    try {
      await supabase
          .from('EightChineseTeacherPhrase')
          .delete()
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<EightChineseTeacherModel>> getSessionRoundsGroupDataCTPAudio(
      int groupDataId) async {
    List<EightChineseTeacherModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('EightChineseTeacherPhrase')
          .select('*')
          .eq('round_group_id', groupDataId);
      data.forEach((element) {
        list.add(EightChineseTeacherModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createSessionRoundGroupDataGamePhrase(
    int sessionId,
    int round,
    String group,
    String audio,
    String preAudio,
    String sufAudio,
    String text,
    bool isEnglish,
    int groupDataId,
  ) async {
    try {
      await supabase.from('EightGamePhrase').insert({
        'audio_link': audio,
        "pre_audio": preAudio,
        "suf_audio": sufAudio,
        "text": text,
        "is_english": isEnglish,
        "round_data_id": groupDataId,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSessionRoundGroupDataGamePhrase(
      int sessionId,
      int round,
      String group,
      String? audio,
      String? preAudio,
      String? sufAudio,
      String text,
      bool isEnglish,
      int groupDataId,
      int id) async {
    try {
      final Map<String, dynamic> map = {
        "text": text,
        "is_english": isEnglish,
        "round_data_id": groupDataId,
      };
      if (audio != null) {
        map["audio_link"] = audio;
      }
      if (sufAudio != null) {
        map["suf_audio"] = sufAudio;
      }
      if (preAudio != null) {
        map["pre_audio"] = preAudio;
      }
      await supabase.from('EightGamePhrase').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSessionRoundGroupDataGamePhrase(int id) async {
    try {
      await supabase.from('EightGamePhrase').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<EightGamePhraseModel>> getSessionRoundsGroupDataGamePhrases(
      int groupDataId) async {
    List<EightGamePhraseModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('EightGamePhrase')
          .select('*')
          .eq('round_data_id', groupDataId);
      data.forEach((element) {
        list.add(EightGamePhraseModel.fromMap(element));
      });
      // list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  ///New
  Future<List<RoundModel>> getSessionRoundsWithSessionNumber(
      int session) async {
    List<RoundModel> list = [];
    try {
      SessionModel? res = await getSession(session);
      if (res == null) {
        return [];
      }
      final PostgrestList data = await supabase
          .from('EightRound')
          .select('*')
          .eq('session_id', res.id);
      data.forEach((element) {
        list.add(RoundModel.fromMap(element));
      });
      list.sort((a, b) => a.round.compareTo(b.round));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<RoundDataModel>> getSessionRoundsDataWithSessionNumber(
      int session) async {
    List<RoundDataModel> list = [];
    try {
      List<RoundModel> res = await getSessionRoundsWithSessionNumber(session);
      if (res.isEmpty) {
        return [];
      }
      List<int> list1 = [];
      res.forEach((element) {
        list1.add(element.id);
      });
      final PostgrestList data = await supabase
          .from('EightRoundData')
          .select('*')
          .inFilter('round_id', list1);
      data.forEach((element) {
        list.add(RoundDataModel.fromMap(element));
      });
      list.sort((a, b) => a.group.compareTo(b.group));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  /// A1-1,A1-2,A1-6
  Future<List<BoxModel>> getAllBoxes() async {
    List<BoxModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('FormatEightBox').select('*');
      data.forEach((element) {
        list.add(BoxModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<BoxModel>> getBoxesFromList(List<int> list1) async {
    List<BoxModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('FormatEightBox')
          .select('*')
          .inFilter('sequence', list1);
      ;
      data.forEach((element) {
        list.add(BoxModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<EightBoxExplodedAudioModel>> getBoxExplodedAudioFromList(
      List<int> list1) async {
    List<EightBoxExplodedAudioModel> list = [];
    try {
      final List<BoxModel> res = await getBoxesFromList(list1);
      List<int> boxId = [];
      res.forEach((element) {
        boxId.add(element.id);
      });
      final PostgrestList data = await supabase
          .from('EightBoxExplodedAudio')
          .select('*')
          .inFilter('box_id', boxId);
      data.forEach((element) {
        list.add(EightBoxExplodedAudioModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<BoxCardModel>> getBoxCardsFromList(List<int> list1) async {
    List<BoxCardModel> list = [];
    try {
      final List<BoxModel> res = await getBoxesFromList(list1);
      List<int> boxId = [];
      res.forEach((element) {
        boxId.add(element.id);
      });
      final PostgrestList data = await supabase
          .from('FormatEightBoxDetails')
          .select('*')
          .inFilter('box_id', boxId);
      data.forEach((element) {
        list.add(BoxCardModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<EightChineseTeacherModel>> getSessionCTPFromSession(
      int session) async {
    List<EightChineseTeacherModel> list = [];
    try {
      final rounds = await getSessionRoundsDataWithSessionNumber(session);
      if (rounds.isEmpty) {
        return [];
      }
      List<int> sessionDataId = [];
      rounds.forEach((element) {
        sessionDataId.add(element.id);
      });
      final PostgrestList data = await supabase
          .from('EightChineseTeacherPhrase')
          .select('*')
          .inFilter('round_group_id', sessionDataId);
      data.forEach((element) {
        list.add(EightChineseTeacherModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SoundEffectModel>> getAllSoundEffectsFromSession(
      int session) async {
    List<SoundEffectModel> list = [];
    try {
      SessionModel? res = await getSession(session);
      if (res == null) {
        return [];
      }
      final PostgrestList data = await supabase
          .from('GameSoundEffect')
          .select('*')
          .match({'session_id': res.id});
      data.forEach((element) {
        list.add(SoundEffectModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<EightGamePhraseModel>> getSessionAllRoundsGroupDataGamePhrases(
      int session) async {
    List<EightGamePhraseModel> list = [];
    try {
      final rounds = await getSessionRoundsDataWithSessionNumber(session);
      if (rounds.isEmpty) {
        return [];
      }
      List<int> sessionDataId = [];
      rounds.forEach((element) {
        sessionDataId.add(element.id);
      });
      final PostgrestList data = await supabase
          .from('EightGamePhrase')
          .select('*')
          .inFilter('round_data_id', sessionDataId);
      data.forEach((element) {
        list.add(EightGamePhraseModel.fromMap(element));
      });
      // list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<BoxModel?> getBox(int box) async {
    BoxModel? list;
    try {
      final PostgrestList data =
          await supabase.from('FormatEightBox').select('*').eq("id", box);
      data.forEach((element) {
        list = (BoxModel.fromMap(element));
      });
      // list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<BoxModel>> getBoxesWithRounds(int sequence) async {
    List<BoxModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('FormatEightBox')
          .select('*')
          .eq("sequence", sequence);
      data.forEach((element) {
        list.add(BoxModel.fromMap(element));
      });
      list.sort((a, b) => a.round.compareTo(b.round));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<SoundEffectModel>> getSessionSoundEffect(int session) async {
    List<SoundEffectModel> list = [];
    try {
      final res = await getSession(session);
      if (res == null) {
        return [];
      }
      final PostgrestList data = await supabase
          .from('GameSoundEffect')
          .select('*')
          .match({'session_id': res.id});
      data.forEach((element) {
        list.add(SoundEffectModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
