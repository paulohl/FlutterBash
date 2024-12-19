class SessionModel {
  int id;
  int session;

  SessionModel({
    required this.id,
    required this.session,
  });

  factory SessionModel.fromMap(dynamic data) {
    return SessionModel(
      id: data["id"] ?? 0,
      session: data["session"] ?? 0,
    );
  }
}

class RoundModel {
  int id;
  int session_id;
  int round;

  RoundModel({
    required this.id,
    required this.session_id,
    required this.round,
  });

  factory RoundModel.fromMap(dynamic data) {
    return RoundModel(
      id: data["id"] ?? 0,
      session_id: data["session_id"] ?? 0,
      round: data["round"] ?? 0,
    );
  }

  factory RoundModel.empty(int round) {
    return RoundModel(
      id: 0,
      session_id: 0,
      round: round,
    );
  }
}

class RoundDataModel {
  int id;
  int session_id;
  int round_id;
  String group;
  String ctp_text;
  String ctp_ch_audio;
  String etp_pre_audio;
  String etp_suf_audio;
  String etp_en_audio;
  String etp_text;
  int etp_count;
  int etp_count_backwards;
  String eti_text;
  String eti_pre_audio;
  String eti_suf_audio;
  String eti_en_audio;
  String std_en_audio;
  String std_ch_audio;
  String std_ch_pre;
  String std_ch_suf;
  String std_en_pre;
  String std_en_suf;
  String std_text;

  RoundDataModel({
    required this.id,
    required this.session_id,
    required this.round_id,
    required this.group,
    required this.ctp_text,
    required this.ctp_ch_audio,
    required this.etp_pre_audio,
    required this.etp_suf_audio,
    required this.etp_en_audio,
    required this.etp_text,
    required this.etp_count,
    required this.etp_count_backwards,
    required this.eti_text,
    required this.eti_pre_audio,
    required this.eti_suf_audio,
    required this.eti_en_audio,
    required this.std_en_audio,
    required this.std_ch_audio,
    required this.std_text,
    required this.std_ch_pre,
    required this.std_ch_suf,
    required this.std_en_pre,
    required this.std_en_suf,
  });

  factory RoundDataModel.fromMap(dynamic data) {
    return RoundDataModel(
      id: data["id"] ?? 0,
      session_id: data["session_id"] ?? 0,
      round_id: data["round_id"] ?? 0,
      etp_count: data["etp_count"] ?? 0,
      etp_count_backwards: data["etp_count_backwards"] ?? 0,
      group: data["group"] ?? "",
      ctp_text: data["ctp_text"] ?? "",
      ctp_ch_audio: data["ctp_ch_audio"] ?? "",
      etp_pre_audio: data["etp_pre_audio"] ?? "",
      etp_suf_audio: data["etp_suf_audio"] ?? "",
      etp_en_audio: data["etp_en_audio"] ?? "",
      etp_text: data["etp_text"] ?? "",
      eti_text: data["eti_text"] ?? "",
      eti_pre_audio: data["eti_pre_audio"] ?? "",
      eti_suf_audio: data["eti_suf_audio"] ?? "",
      eti_en_audio: data["eti_en_audio"] ?? "",
      std_en_audio: data["std_en_audio"] ?? "",
      std_ch_audio: data["std_ch_audio"] ?? "",
      std_text: data["std_text"] ?? "",
      std_en_pre: data["std_en_pre"] ?? "",
      std_en_suf: data["std_en_suf"] ?? "",
      std_ch_suf: data["std_ch_suf"] ?? "",
      std_ch_pre: data["std_ch_pre"] ?? "",
    );
  }
}

class EightChineseTeacherModel {
  int id;
  int sequence;
  int round_group_id;
  String audio_link;

  EightChineseTeacherModel({
    required this.id,
    required this.sequence,
    required this.round_group_id,
    required this.audio_link,
  });

  factory EightChineseTeacherModel.fromMap(dynamic data) {
    return EightChineseTeacherModel(
      id: data["id"] ?? 0,
      sequence: data["sequence"] ?? 0,
      round_group_id: data["round_group_id"] ?? 0,
      audio_link: data["audio_link"] ?? "",
    );
  }
}

class EightGamePhraseModel {
  int id;
  String pre_audio;
  int round_data_id;
  String audio_link;
  String suf_audio;
  String text;
  bool isEnglish;

  EightGamePhraseModel({
    required this.id,
    required this.pre_audio,
    required this.round_data_id,
    required this.audio_link,
    required this.suf_audio,
    required this.text,
    required this.isEnglish,
  });

  factory EightGamePhraseModel.fromMap(dynamic data) {
    return EightGamePhraseModel(
      id: data["id"] ?? 0,
      pre_audio: data["pre_audio"] ?? "",
      round_data_id: data["round_data_id"] ?? 0,
      audio_link: data["audio_link"] ?? "",
      suf_audio: data["suf_audio"] ?? "",
      text: data["text"] ?? "",
      isEnglish: data["is_english"] ?? false,
    );
  }
}
