class LoginDataModel {
  int id;
  int teacher_id;
  String login_time;
  String logout_time;
  String date;
  String created_at;
  bool common_lang_added;
  List<dynamic> common_id;
  List<dynamic> teacher_common_language_id;

  LoginDataModel({
    required this.id,
    required this.date,
    required this.common_lang_added,
    required this.login_time,
    required this.logout_time,
    required this.teacher_id,
    required this.created_at,
    required this.common_id,
    required this.teacher_common_language_id,
  });

  factory LoginDataModel.fromMap(dynamic data) {
    return LoginDataModel(
      id: data["id"] ?? 0,
      date: data["date"] ?? "",
      common_lang_added: data["common_lang_added"] ?? false,
      login_time: data["login_time"] ?? "",
      logout_time: data["logout_time"] ?? "",
      created_at: data["created_at"] ?? "",
      teacher_id: data["teacher_id"] ?? 0,
      common_id: data["common_id"] ?? [],
      teacher_common_language_id: data["teacher_common_language_id"] ?? [],
    );
  }
}
