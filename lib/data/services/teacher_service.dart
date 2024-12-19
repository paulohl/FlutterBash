import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/models/login_model.dart';

import '../../core/dialog_helper.dart';
import '../../models/teacher_model.dart';

final teacherServiceProvider = Provider((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return TeacherService(sessionManager);
});

class TeacherService {
  final supabase = Supabase.instance.client;
  final SessionManager sessionManager;

  TeacherService(this.sessionManager);

  Future<bool> updateTeacher(String name, String email, String phone,
      String gender, int levelID, int schoolID, int classID, int id) async {
    try {
      await supabase.from('Teachers').update({
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'level_id': levelID,
        'school_id': schoolID,
        'class_id': classID,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateFormat7Session(int session, int id) async {
    final f = DateFormat('yyyy-MM-dd');
    try {
      await supabase.from('Teachers').update({
        'format_seven_session': session,
        "format_seven_switch_date": f.format(DateTime.now())
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateFormat8Session(int session, int id) async {
    try {
      await supabase.from('Teachers').update({
        'format_eight_session': session,
        "format_eight_round": 1
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateFormat8SessionRound(int round, int id) async {
    try {
      await supabase
          .from('Teachers')
          .update({'format_eight_round': round}).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteTeacher(int id) async {
    try {
      await supabase.from('Teachers').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<TeacherModel>> getSchoolTeachers(int schoolId) async {
    List<TeacherModel> list = [];
    try {
      final PostgrestList data =
          await supabase.from('Teachers').select('*').eq('school_id', schoolId);
      data.forEach((element) {
        list.add(TeacherModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<TeacherModel?> getTeacherProfile(String uid) async {
    TeacherModel? list;
    try {
      final PostgrestList data =
          await supabase.from('Teachers').select('*').eq('uid', uid);
      data.forEach((element) {
        list = TeacherModel.fromMap(element);
      });
      if (list != null) {
        await sessionManager.saveTeacherProfile(list!);
      }
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  //Login Data
  Future<LoginDataModel?> getTeacherTodayLoginData(int id) async {
    LoginDataModel? list;
    final f = DateFormat('yyyy-MM-dd');
    try {
      final PostgrestList data = await supabase
          .from('LoginData')
          .select('*')
          .match({'teacher_id': id, "date": f.format(DateTime.now())});
      data.forEach((element) {
        list = LoginDataModel.fromMap(element);
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<LoginDataModel>> getTeacherLoginData(int id) async {
    List<LoginDataModel> list = [];
    final f = DateFormat('yyyy-MM-dd');
    try {
      final PostgrestList data = await supabase
          .from('LoginData')
          .select('*')
          .match({'teacher_id': id});
      data.forEach((element) {
        list.add(LoginDataModel.fromMap(element));
      });
      list.sort((a, b) => a.created_at.compareTo(b.created_at));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  ///call mode
  Future<bool> updateTeacherFormat7CallMode(int callModeCount, int id) async {
    try {
      await supabase.from('Teachers').update({
        'format_s_call_mode': callModeCount,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateTeacherFormat8TeacherPhrase(
      int callModeCount, int id, bool isBegin) async {
    try {
      await supabase.from('Teachers').update({
        isBegin ? 'eight_tp_begin_frequency' : 'eight_tp_end_frequency':
            callModeCount,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }
}
