import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/dialog_helper.dart';
import '../../models/student_model.dart';

final studentServiceProvider = Provider((ref) => StudentService());

class StudentService {
  final supabase = Supabase.instance.client;

  Future<bool> createStudent(String name, String phone, String gender,
      int schoolID, int classID) async {
    try {
      await supabase.from('Students').insert({
        'name': name,
        'phone': phone,
        'gender': gender,
        'school_id': schoolID,
        'class_id': classID,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateStudent(String name, String phone, String gender,
      int schoolID, int classID, int id) async {
    try {
      await supabase.from('Students').update({
        'name': name,
        'phone': phone,
        'gender': gender,
        'school_id': schoolID,
        'class_id': classID,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateStudentEnglishName(int englishId, int id) async {
    try {
      await supabase.from('Students').update({
        'english_id': englishId,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateStudentFormat7Sort(int sortNumber, int id) async {
    try {
      await supabase.from('Students').update({
        'format_seven_sort': sortNumber,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateStudentFormat8Sort(
      String group, int sortNumber, int id) async {
    try {
      await supabase.from('Students').update({
        'eight_sort': sortNumber,
        'eight_group': group,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      await supabase.from('Students').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<StudentModel>> getClassStudents(
      int schoolId, int classId, int studentId) async {
    List<StudentModel> list = [];
    try {
      final PostgrestList data = await supabase.from('Students').select('''
    *,
    EnglishName:english_id ( name, audio_link )
  ''').match({
        'class_id': classId,
        "school_id": schoolId,
        // "student_id": studentId
      });
      // data.forEach((element) {
      //
      // })
      // final PostgrestList data =
      //     await supabase.from('Students').select('*').match({
      //   'class_id': classId,
      //   "school_id": schoolId,
      // });
      data.forEach((element) {
        list.add(StudentModel.fromMap(element));
      });
      list.sort((a, b) => a.id.compareTo(b.id));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
