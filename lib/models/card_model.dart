class CardModel {
  int id;
  String name;
  String englishAudioLink;
  String chineseAudioLink;
  int levelID;
  int sequence;
  String action_text;
  String action_ch_audio;
  String action_en_audio;
  String ad_text;
  String ad_ch_audio;
  String ad_en_audio;
  String ad_image;

  CardModel({
    required this.id,
    required this.levelID,
    required this.name,
    required this.chineseAudioLink,
    required this.englishAudioLink,
    required this.sequence,
    required this.action_ch_audio,
    required this.action_en_audio,
    required this.action_text,
    required this.ad_ch_audio,
    required this.ad_en_audio,
    required this.ad_image,
    required this.ad_text,
  });

  factory CardModel.fromMap(dynamic data) {
    return CardModel(
      id: data["id"] ?? 0,
      levelID: data["level_id"] ?? 0,
      sequence: data["sequence"] ?? 0,
      name: data["name"] ?? "",
      chineseAudioLink: data["ch_audio"] ?? "",
      englishAudioLink: data["en_audio"] ?? "",
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
