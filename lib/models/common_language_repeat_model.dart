class CommonLanguageRepeatModel {
  int id;
  int teacher_id;
  int common_id;
  int played;

  CommonLanguageRepeatModel({
    required this.id,
    required this.played,
    required this.common_id,
    required this.teacher_id,
  });

  factory CommonLanguageRepeatModel.fromMap(dynamic data) {
    return CommonLanguageRepeatModel(
      id: data["id"] ?? 0,
      common_id: data["common_id"] ?? 0,
      teacher_id: data["teacher_id"] ?? 0,
      played: data["played"] ?? 0,
    );
  }
}
