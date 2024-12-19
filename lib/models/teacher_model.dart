import 'dart:convert';

class TeacherModel {
  int id;
  String name;
  String email;
  String phone;
  String gender;
  int levelId;
  int schoolId;
  int classId;
  String uid;
  int formatSevenSession;
  int formatEightSession;
  int format_s_call_mode;
  int format_eight_round;
  String format_seven_switch_date;
  int eight_tp_begin_frequency;
  int eight_tp_end_frequency;
  bool isEnabled;

  TeacherModel({
    required this.id,
    required this.phone,
    required this.email,
    required this.name,
    required this.gender,
    required this.levelId,
    required this.schoolId,
    required this.classId,
    required this.uid,
    required this.formatSevenSession,
    required this.formatEightSession,
    required this.format_eight_round,
    required this.format_s_call_mode,
    required this.format_seven_switch_date,
    required this.eight_tp_end_frequency,
    required this.eight_tp_begin_frequency,
    required this.isEnabled,
  });

  factory TeacherModel.fromMap(dynamic data) {
    return TeacherModel(
      id: data["id"] ?? 0,
      phone: data["phone"] ?? "",
      email: data["email"] ?? "",
      name: data["name"] ?? "",
      gender: data['gender'] ?? "",
      levelId: data["level_id"] ?? 0,
      schoolId: data["school_id"] ?? 0,
      classId: data["class_id"] ?? 0,
      formatSevenSession: data["format_seven_session"] ?? 0,
      formatEightSession: data["format_eight_session"] ?? 0,
      format_s_call_mode: data["format_s_call_mode"] ?? 0,
      eight_tp_end_frequency: data["eight_tp_end_frequency"] ?? 0,
      eight_tp_begin_frequency: data["eight_tp_begin_frequency"] ?? 0,
      format_eight_round: data["format_eight_round"] ?? 1,
      uid: data["uid"] ?? "",
      format_seven_switch_date: data["format_seven_switch_date"] ?? "",
      isEnabled: data["is_enabled"] ?? true,
    );
  }

  static Map<String, dynamic> toMap(TeacherModel teacherModel) => {
        'id': teacherModel.id,
        'phone': teacherModel.phone,
        'email': teacherModel.email,
        'name': teacherModel.name,
        'gender': teacherModel.gender,
        'level_id': teacherModel.levelId,
        'school_id': teacherModel.schoolId,
        'class_id': teacherModel.classId,
        'uid': teacherModel.uid,
        'format_seven_session': teacherModel.formatSevenSession,
        'format_eight_session': teacherModel.formatEightSession,
        'format_s_call_mode': teacherModel.format_s_call_mode,
        'format_eight_round': teacherModel.format_eight_round,
        'format_seven_switch_date': teacherModel.format_seven_switch_date,
        'eight_tp_end_frequency': teacherModel.eight_tp_end_frequency,
        'eight_tp_begin_frequency': teacherModel.eight_tp_begin_frequency,
        'isEnabled': teacherModel.isEnabled,
      };

  static String encode(TeacherModel musics) =>
      json.encode(TeacherModel.toMap(musics));

  static TeacherModel decode(String musics) =>
      TeacherModel.fromMap(jsonDecode(musics));
}
