class CallModeModel {
  int id;
  String audio_link;
  String update_frequency;
  int sequence;
  String en_audio;
  bool isAudioBeforeName;

  CallModeModel({
    required this.id,
    required this.audio_link,
    required this.update_frequency,
    required this.sequence,
    required this.en_audio,
    required this.isAudioBeforeName,
  });

  factory CallModeModel.fromMap(dynamic data) {
    return CallModeModel(
      id: data["id"] ?? 0,
      audio_link: data["audio_link"] ?? "",
      en_audio: data["en_audio"] ?? "",
      update_frequency: data["update_frequency"] ?? "",
      sequence: data["sequence"] ?? 0,
      isAudioBeforeName: data["audio_before_name"] ?? false,
    );
  }
}
