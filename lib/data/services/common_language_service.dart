import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/common_language_category_model.dart';
import 'package:xueli/models/common_language_model.dart';
import 'package:xueli/models/common_language_repeat_model.dart';
import 'package:xueli/models/evaluation_model.dart';
import 'package:xueli/models/login_model.dart';
import 'package:xueli/models/teacher_common_language_model.dart';

import '../../core/dialog_helper.dart';

final commonLanguageServiceProvider =
    Provider((ref) => CommonLanguageService());

class CommonLanguageService {
  final supabase = Supabase.instance.client;

  Future<bool> createCategory(String name, int levelId) async {
    final map = {
      "name": name,
      "level_id": levelId,
    };
    try {
      await supabase.from('CommonLanguageCategories').insert(map);
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateCategory(String name, int levelId, int id) async {
    final map = {
      "name": name,
      "level_id": levelId,
    };
    try {
      await supabase
          .from('CommonLanguageCategories')
          .update(map)
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<CommonLanguageCategoryModel>> getLevelCategories(
      int levelId) async {
    List<CommonLanguageCategoryModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('CommonLanguageCategories')
          .select('*')
          .eq('level_id', levelId);
      data.forEach((element) {
        list.add(CommonLanguageCategoryModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createSentence(
      String text,
      String chAudio,
      String enAudio,
      String chStdAudio,
      String enStdAudio,
      int playCount,
      int playCountDown,
      int sequence,
      int levelId,
      int categoryId) async {
    final map = {
      "text": text,
      "ch_audio": chAudio,
      "en_audio": enAudio,
      "ch_std_audio": chStdAudio,
      "en_std_audio": enStdAudio,
      "play_count": playCount,
      "play_count_down": playCountDown,
      "sequence": sequence,
      "level_id": levelId,
      "category_id": categoryId,
    };
    try {
      await supabase.from('CommonLanguage').insert(map);
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSentence(
      String text,
      String? chAudio,
      String? enAudio,
      String? chStdAudio,
      String? enStdAudio,
      int playCount,
      int playCountDown,
      int sequence,
      int levelId,
      int categoryId,
      int id) async {
    final map = {
      "text": text,
      "play_count": playCount,
      "play_count_down": playCountDown,
      "sequence": sequence,
      "level_id": levelId,
      "category_id": categoryId,
    };
    if (chAudio != null) {
      map["ch_audio"] = chAudio;
    }
    if (enAudio != null) {
      map["en_audio"] = enAudio;
    }
    if (chStdAudio != null) {
      map["ch_std_audio"] = chStdAudio;
    }
    if (enStdAudio != null) {
      map["en_std_audio"] = enStdAudio;
    }
    try {
      await supabase.from('CommonLanguage').update(map).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteCommonLanguage(int id) async {
    try {
      await supabase.from('CommonLanguage').delete().match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<CommonLanguageModel>> getLevelCategorySentences(
      int levelId, int categoryId) async {
    List<CommonLanguageModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('CommonLanguage')
          .select('*')
          .eq('category_id', levelId);
      data.forEach((element) {
        list.add(CommonLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  // Future<List<CommonLanguageModel>> getLevelCategory2Sentences(
  //     int levelId, int categoryId) async {
  //   List<CommonLanguageModel> list = [];
  //   try {
  //     final PostgrestList data = await supabase
  //         .from('CommonLanguage')
  //         .select('*')
  //         .eq('category_id', levelId);
  //     data.forEach((element) {
  //       list.add(CommonLanguageModel.fromMap(element));
  //     });
  //     list.sort((a, b) => a.sequence.compareTo(b.sequence));
  //     return list;
  //   } on PostgrestException catch (e) {
  //     DialogHelper.showError(e.message);
  //     return list;
  //   }
  // }

  Future<List<CommonLanguageModel>> getLevelSentences(int levelId) async {
    List<CommonLanguageModel> list = [];
    try {
      final PostgrestList data = await supabase
          .from('CommonLanguage')
          .select('*')
          .eq('level_id', levelId);
      data.forEach((element) {
        list.add(CommonLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<CommonLanguageModel>> getLevelNonRepeatedSentences(
      int levelId, int teacherId) async {
    List<CommonLanguageModel> list = [];
    try {
      List<int> ids = [];
      final PostgrestList data = await supabase
          .from('TeacherCommonLanguage')
          .select('*')
          .match({'teacher_id': teacherId});
      data.forEach((element) {
        final item = (TeacherCommonLanguageModel.fromMap(element));
        item.list.forEach((element) {
          ids.add(int.tryParse(element.toString()) ?? 0);
        });
      });
      final PostgrestList data1 = await supabase
          .from('CommonLanguage')
          .select('*')
          .eq('level_id', levelId);
      data1.forEach((element) {
        final item = CommonLanguageModel.fromMap(element);
        if (!ids.contains(item.id)) {
          list.add(CommonLanguageModel.fromMap(element));
        }
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<CommonLanguageModel>> getLevelLearnedSentences(
      int levelId, int teacherId) async {
    List<CommonLanguageModel> list = [];
    try {
      List<int> ids = [];
      final PostgrestList data = await supabase
          .from('TeacherCommonLanguage')
          .select('*')
          .match({'teacher_id': teacherId, "is_completed": true});
      data.forEach((element) {
        final item = (TeacherCommonLanguageModel.fromMap(element));
        item.list.forEach((element) {
          ids.add(int.tryParse(element.toString()) ?? 0);
        });
      });
      final PostgrestList data1 =
          await supabase.from('CommonLanguage').select('*').inFilter('id', ids);
      data1.forEach((element) {
        list.add(CommonLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<CommonLanguageModel>> getTodayCommonLanguage(
      int teacherId) async {
    List<CommonLanguageModel> list = [];
    try {
      final f = DateFormat('yyyy-MM-dd');
      LoginDataModel? item;
      final PostgrestList data = await supabase
          .from('LoginData')
          .select('*')
          .match({'teacher_id': teacherId, "date": f.format(DateTime.now())});
      data.forEach((element) {
        item = LoginDataModel.fromMap(element);
      });
      if (item != null) {
        List<int> list1 = [];
        item!.common_id.forEach((element) {
          list1.add(int.parse(element.toString()));
        });
        final PostgrestList data = await supabase
            .from('CommonLanguage')
            .select('*')
            .inFilter('id', list1);
        data.forEach((element) {
          list.add(CommonLanguageModel.fromMap(element));
        });
        list.sort((a, b) => a.sequence.compareTo(b.sequence));
        return list;
      } else {
        return list;
      }
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<CommonLanguageModel>> getCommonLanguageFromList(
      List<TeacherCommonLanguageModel> teacher) async {
    List<CommonLanguageModel> list = [];
    try {
      List<int> list1 = [];
      teacher.forEach((element) {
        element.list.forEach((element1) {
          list1.add(int.parse(element1.toString()));
        });
      });
      final PostgrestList data = await supabase
          .from('CommonLanguage')
          .select('*')
          .inFilter('id', list1);
      data.forEach((element) {
        list.add(CommonLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.sequence.compareTo(b.sequence));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  ///TeacherCommonLanguage
  ///
  Future<List<TeacherCommonLanguageModel>>
      getTeacherCommonLanguageCompletedList(int id) async {
    List<TeacherCommonLanguageModel> list = [];
    // final f = DateFormat('yyyy-MM-dd');
    try {
      final PostgrestList data = await supabase
          .from('TeacherCommonLanguage')
          .select('*')
          .match({'teacher_id': id, "is_completed": true});
      data.forEach((element) {
        list.add(TeacherCommonLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.created_at.compareTo(b.created_at));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<List<TeacherCommonLanguageModel>>
      getTeacherCommonLanguageUnCompletedList(int id) async {
    List<TeacherCommonLanguageModel> list = [];
    // final f = DateFormat('yyyy-MM-dd');
    try {
      final PostgrestList data = await supabase
          .from('TeacherCommonLanguage')
          .select('*')
          .match({'teacher_id': id, "is_completed": false});
      data.forEach((element) {
        list.add(TeacherCommonLanguageModel.fromMap(element));
      });
      list.sort((a, b) => a.created_at.compareTo(b.created_at));
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<TeacherCommonLanguageModel?> getTeacherCommonLanguage(
      int id, String date) async {
    TeacherCommonLanguageModel? list;
    // final f = DateFormat('yyyy-MM-dd');
    try {
      final PostgrestList data = await supabase
          .from('TeacherCommonLanguage')
          .select('*')
          .match({'teacher_id': id, "date": date});
      data.forEach((element) {
        list = (TeacherCommonLanguageModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  Future<bool> createTeacherCommonLanguage(
      int teacherId, List<int> common) async {
    final f = DateFormat('yyyy-MM-dd');
    final time = DateTime.now();
    final map = {
      "teacher_id": teacherId,
      "date": f.format(time),
      "list": common,
      "is_completed": false,
    };
    try {
      final res1 =
          await supabase.from('TeacherCommonLanguage').insert(map).select();
      TeacherCommonLanguageModel? list;
      List<dynamic> ids = [];
      res1.forEach((element) {
        list = TeacherCommonLanguageModel.fromMap(element);
        ids.add(list!.id);
      });
      final res = await createLoginDate(teacherId, common, ids);
      return res;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateTeacherCommonLanguageRepeat(
      int id, List<dynamic> repeat, bool? isCompleted) async {
    final f = DateFormat('yyyy-MM-dd');
    final time = DateTime.now();
    final Map<String, dynamic> map = {
      "repeat_date": repeat,
    };
    if (isCompleted != null) {
      map["is_completed"] = isCompleted;
    }
    try {
      await supabase
          .from('TeacherCommonLanguage')
          .update(map)
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      // DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateTeacherCommonLanguageEvaluation(
      int id, bool isEvaluated) async {
    final Map<String, dynamic> map = {
      "is_evaluated": isEvaluated,
    };
    try {
      await supabase
          .from('TeacherCommonLanguage')
          .update(map)
          .match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> addRepeatCommonLanguage(
      int teacherId, List<TeacherCommonLanguageModel> repeatList) async {
    final f = DateFormat('yyyy-MM-dd');
    final time = DateTime.now();
    List<dynamic> commonIdList = [];
    List<dynamic> teacherCommonLanguageIdList = [];
    repeatList.forEach((element) {
      commonIdList.addAll(element.list);
      teacherCommonLanguageIdList.add(element.id);
    });
    final res = await createLoginDate(
        teacherId, commonIdList, teacherCommonLanguageIdList);
    if (res) {
      repeatList.forEach((element) {
        element.repeat_date.add(f.format(time));
        updateTeacherCommonLanguageRepeat(element.id, element.repeat_date,
            element.is_completed == true ? true : null);
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> createLoginDate(
      int id, List<dynamic> list, List<dynamic> teacherCommonIdList) async {
    final f = DateFormat('yyyy-MM-dd');
    final time = DateTime.now();
    try {
      await supabase.from('LoginData').insert({
        'teacher_id': id,
        'date': f.format(time),
        'login_time': time.millisecondsSinceEpoch,
        "common_id": list,
        "teacher_common_language_id": teacherCommonIdList,
        "common_lang_added": true,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> deleteSentenceFromTodayLoginDate(
      int teacherId, List<CommonLanguageModel> list, int removeId) async {
    try {
      final f = DateFormat('yyyy-MM-dd');
      LoginDataModel? item;
      final PostgrestList data = await supabase
          .from('LoginData')
          .select('*')
          .match({'teacher_id': teacherId, "date": f.format(DateTime.now())});
      data.forEach((element) {
        item = LoginDataModel.fromMap(element);
      });
      if (item != null) {
        List<int> list1 = [];
        list.forEach((element) {
          if (element.id != removeId) {
            list1.add(element.id);
          }
        });
        await supabase.from('LoginData').update({
          "common_id": list1,
        }).match({"id": item!.id});
      }
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  ///CommonLanguagePlayHistory
  Future<bool> createTeacherCommonLanguageRepeatHistory(
      int teacherId, int commonId) async {
    try {
      await supabase.from('CommonLanguagePlayHistory').insert({
        'teacher_id': teacherId,
        'played': 1,
        "common_id": commonId,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateTeacherCommonLanguageRepeatHistory(
      int teacherId, int commonId, int played, int id) async {
    try {
      await supabase.from('CommonLanguagePlayHistory').update({
        'teacher_id': teacherId,
        'played': played,
        "common_id": commonId,
      }).match({'id': id});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<CommonLanguageRepeatModel>> getRepeatTodayCommonLanguage(
      int teacherId) async {
    List<CommonLanguageRepeatModel> list = [];
    try {
      final f = DateFormat('yyyy-MM-dd');
      LoginDataModel? item;
      final PostgrestList data = await supabase
          .from('LoginData')
          .select('*')
          .match({'teacher_id': teacherId, "date": f.format(DateTime.now())});
      data.forEach((element) {
        item = LoginDataModel.fromMap(element);
      });
      if (item != null) {
        List<int> list1 = [];
        item!.common_id.forEach((element) {
          list1.add(int.parse(element.toString()));
        });
        final PostgrestList data = await supabase
            .from('CommonLanguagePlayHistory')
            .select('*')
            .match({'teacher_id': teacherId}).inFilter('common_id', list1);
        data.forEach((element) {
          list.add(CommonLanguageRepeatModel.fromMap(element));
        });
        // list.sort((a, b) => a.sequence.compareTo(b.sequence));
        return list;
      } else {
        return list;
      }
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }

  ///CommonLanguageEvaluation
  Future<bool> createEvaluation(
      int id, int commonId, List<int> list, List<bool> result) async {
    try {
      await supabase.from('CommonLanguageEvaluation').insert({
        'teacher_id': id,
        "list": list,
        "evaluation_result": result,
        "teacher_common_id": commonId,
      });
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateEvaluation(int id, int commonId, List<int> list,
      List<bool> result, int evaluationId) async {
    try {
      await supabase.from('CommonLanguageEvaluation').insert({
        'teacher_id': id,
        "list": list,
        "evaluation_result": result,
        "teacher_common_id": commonId,
      }).match({"id": evaluationId});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<EvaluationModel?> getEvaluation(int id) async {
    EvaluationModel? list;
    // final f = DateFormat('yyyy-MM-dd');
    try {
      final PostgrestList data = await supabase
          .from('CommonLanguageEvaluation')
          .select('*')
          .match({'teacher_common_id': id});
      data.forEach((element) {
        list = (EvaluationModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
