import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/class_model.dart';

import '../../core/dialog_helper.dart';

final classServiceProvider = Provider((ref) => ClassService());

class ClassService {
  final supabase = Supabase.instance.client;

  Future<bool> createClass(
      String name, String startTime, String endTime, int schoolID) async {
    try {
      await supabase.from('Grade').insert({
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        'school_id': schoolID,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateClass(String name, String startTime, String endTime,
      int schoolID, int id) async {
    try {
      await supabase.from('Grade').update({
        'name': name,
        'start_time': startTime,
        'end_time': endTime,
        'school_id': schoolID,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteClass(int id) async {
    try {
      await supabase.from('Grade').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<ClassModel>> getSchoolClasses(int schoolId) async {
    List<ClassModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('Grade').select('*').eq('school_id', schoolId);
      data.forEach((element) {
        list.add(ClassModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<ClassModel?> getClass(int classId) async {
    ClassModel? list;
    try {
      final PostgrestList data =
          await supabase.from('Grade').select('*').eq('id', classId);
      data.forEach((element) {
        list = (ClassModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
