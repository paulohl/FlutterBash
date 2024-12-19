class BoxModel {
  int id;
  String title;
  String group;
  int sequence;
  int box_level;
  int round;

  BoxModel({
    required this.title,
    required this.group,
    required this.sequence,
    required this.id,
    required this.box_level,
    required this.round,
  });

  factory BoxModel.fromMap(dynamic data) {
    return BoxModel(
      title: data["title"] ?? "",
      group: data["group"] ?? "",
      sequence: data["sequence"] ?? 0,
      id: data["id"] ?? 0,
      box_level: data["box_level"] ?? 0,
      round: data["round"] ?? 0,
    );
  }
}

class EightBoxExplodedAudioModel {
  int id;
  int sequence;
  int box_id;
  String audio_link;

  EightBoxExplodedAudioModel({
    required this.id,
    required this.sequence,
    required this.box_id,
    required this.audio_link,
  });

  factory EightBoxExplodedAudioModel.fromMap(dynamic data) {
    return EightBoxExplodedAudioModel(
      id: data["id"] ?? 0,
      sequence: data["sequence"] ?? 0,
      box_id: data["box_id"] ?? 0,
      audio_link: data["audio_link"] ?? "",
    );
  }
}
