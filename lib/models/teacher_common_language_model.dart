class TeacherCommonLanguageModel {
  int id;
  int teacher_id;
  String date;
  String created_at;
  bool is_completed;
  bool is_evaluated;
  List<dynamic> list;
  List<dynamic> repeat_date;

  TeacherCommonLanguageModel({
    required this.id,
    required this.date,
    required this.is_completed,
    required this.list,
    required this.teacher_id,
    required this.created_at,
    required this.repeat_date,
    required this.is_evaluated,
  });

  factory TeacherCommonLanguageModel.fromMap(dynamic data) {
    return TeacherCommonLanguageModel(
      id: data["id"] ?? 0,
      date: data["date"] ?? "",
      is_completed: data["is_completed"] ?? false,
      is_evaluated: data["is_evaluated"] ?? false,
      list: data["list"] ?? [],
      repeat_date: data["repeat_date"] ?? [],
      teacher_id: data["teacher_id"] ?? 0,
      created_at: data["created_at"] ?? "",
    );
  }
}
