class EnglishNameModel {
  int id;
  String name;
  String audioLink;
  bool isBoy;

  EnglishNameModel({
    required this.id,
    required this.name,
    required this.audioLink,
    required this.isBoy,
  });

  factory EnglishNameModel.fromMap(dynamic data) {
    return EnglishNameModel(
      id: data["id"] ?? 0,
      name: data["name"] ?? "",
      audioLink: data["audio_link"] ?? "",
      isBoy: data["is_boy"] ?? false,
    );
  }
}
