class CommonLanguageCategoryModel {
  int id;
  String name;
  int level_id;

  CommonLanguageCategoryModel({
    required this.id,
    required this.name,
    required this.level_id,
  });

  factory CommonLanguageCategoryModel.fromMap(dynamic data) {
    return CommonLanguageCategoryModel(
      id: data["id"] ?? 0,
      name: data["name"] ?? "",
      level_id: data["level_id"] ?? 0,
    );
  }
}
