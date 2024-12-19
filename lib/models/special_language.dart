class SpecialLanguageModel {
  int id;
  String text;
  String en_audio;
  String ch_audio;
  String en_std_audio;
  String ch_std_audio;
  int play_count;
  int play_count_down;
  int sequence;
  String format;
  String group;
  int list_id;
  int session_id;
  String action_text;
  String action_ch_audio;
  String action_en_audio;
  String ad_text;
  String ad_ch_audio;
  String ad_en_audio;
  String ad_image;

  SpecialLanguageModel({
    required this.id,
    required this.text,
    required this.en_audio,
    required this.ch_audio,
    required this.en_std_audio,
    required this.ch_std_audio,
    required this.play_count,
    required this.play_count_down,
    required this.sequence,
    required this.format,
    required this.list_id,
    required this.session_id,
    required this.group,
    required this.action_ch_audio,
    required this.action_en_audio,
    required this.action_text,
    required this.ad_ch_audio,
    required this.ad_en_audio,
    required this.ad_image,
    required this.ad_text,
  });

  factory SpecialLanguageModel.fromMap(dynamic data) {
    return SpecialLanguageModel(
      id: data["id"] ?? 0,
      text: data["text"] ?? "",
      en_audio: data["en_audio"] ?? "",
      ch_audio: data["ch_audio"] ?? "",
      en_std_audio: data["en_std_audio"] ?? "",
      ch_std_audio: data["ch_std_audio"] ?? "",
      play_count: data["play_count"] ?? 0,
      play_count_down: data["play_count_counter"] ?? 0,
      sequence: data["sequence"] ?? 0,
      format: data["format"] ?? "",
      group: data["group"] ?? "",
      list_id: data["list_id"] ?? 0,
      session_id: data["session_id"] ?? 0,
      ad_text: data["ad_text"] ?? "",
      ad_image: data["ad_image"] ?? "",
      ad_en_audio: data["ad_en_audio"] ?? "",
      ad_ch_audio: data["ad_ch_audio"] ?? "",
      action_text: data["action_text"] ?? "",
      action_en_audio: data["action_en_audio"] ?? "",
      action_ch_audio: data["action_ch_audio"] ?? "",
    );
  }
}

class SpecialLanguageListModel {
  int id;
  String format;
  int sequence;
  int updateFrequency;

  SpecialLanguageListModel({
    required this.id,
    required this.format,
    required this.sequence,
    required this.updateFrequency,
  });

  factory SpecialLanguageListModel.fromMap(dynamic data) {
    return SpecialLanguageListModel(
      id: data["id"] ?? 0,
      format: data["format"] ?? "",
      sequence: data["sequence"] ?? 0,
      updateFrequency: data["update_frequency"] ?? 0,
    );
  }
}
