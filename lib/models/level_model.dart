class LevelModel {
  int id;
  String name;

  LevelModel({
    required this.name,
    required this.id,
  });

  factory LevelModel.fromMap(dynamic data) {
    return LevelModel(
      name: data["name"] ?? "",
      id: data["id"] ?? 0,
    );
  }
}
