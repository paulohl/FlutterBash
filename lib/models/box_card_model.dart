class BoxCardModel {
  int id;
  String text;
  String englishAudioLink;
  String chineseAudioLink;
  int sequence;
  int play_count;
  int play_count_backwards;
  int box_id;
  bool is_word;

  BoxCardModel({
    required this.id,
    required this.play_count,
    required this.play_count_backwards,
    required this.text,
    required this.chineseAudioLink,
    required this.englishAudioLink,
    required this.sequence,
    required this.box_id,
    required this.is_word,
  });

  factory BoxCardModel.fromMap(dynamic data) {
    return BoxCardModel(
      id: data["id"] ?? 0,
      play_count: data["play_count"] ?? 0,
      play_count_backwards: data["play_count_backwards"] ?? 0,
      sequence: data["sequence"] ?? 0,
      box_id: data["box_id"] ?? 0,
      text: data["text"] ?? "",
      chineseAudioLink: data["ch_audio"] ?? "",
      englishAudioLink: data["en_audio"] ?? "",
      is_word: data["is_word"] ?? false,
    );
  }
}
