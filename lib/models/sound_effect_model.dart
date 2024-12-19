class SoundEffectModel {
  int id;
  String audio_link;
  int sequence;
  int session_id;
  String group;

  SoundEffectModel({
    required this.sequence,
    required this.id,
    required this.audio_link,
    required this.session_id,
    required this.group,
  });

  factory SoundEffectModel.fromMap(dynamic data) {
    return SoundEffectModel(
      sequence: data["sequence"] ?? 0,
      id: data["id"] ?? 0,
      audio_link: data["audio_link"] ?? "",
      session_id: data["session_id"] ?? 0,
      group: data["group"] ?? "",
    );
  }
}

class TeacherPhraseModel {
  int id;
  String en_audio;
  String ch_audio;
  String text;
  int sequence;
  int update_frequency;
  bool is_start;

  TeacherPhraseModel({
    required this.sequence,
    required this.id,
    required this.en_audio,
    required this.ch_audio,
    required this.text,
    required this.update_frequency,
    required this.is_start,
  });

  factory TeacherPhraseModel.fromMap(dynamic data) {
    return TeacherPhraseModel(
      sequence: data["sequence"] ?? 0,
      id: data["id"] ?? 0,
      en_audio: data["en_audio"] ?? "",
      ch_audio: data["ch_audio"] ?? "",
      text: data["text"] ?? "",
      update_frequency: data["update_frequency"] ?? 0,
      is_start: data["is_start"] ?? false,
    );
  }
}
