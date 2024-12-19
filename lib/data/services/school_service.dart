import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/models/school_model.dart';

import '../../core/dialog_helper.dart';

final schoolServiceProvider = Provider((ref) => SchoolService());

class SchoolService {
  final supabase = Supabase.instance.client;

  Future<bool> createSchool(String name, String email, String phone,
      String address, String city, String state) async {
    final map = {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "state": state,
    };
    try {
      await supabase.from('Schools').insert(map);
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<bool> updateSchool(String name, String email, String phone,
      String address, String city, String state, int schoolId) async {
    final map = {
      "name": name,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "state": state,
    };
    try {
      await supabase.from('Schools').update(map).match({'id': schoolId});
      return true;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return false;
    }
  }

  Future<List<SchoolModel>> getAllSchools() async {
    List<SchoolModel> list = [];
    try {
      final PostgrestList data = await supabase.from('Schools').select('*');
      data.forEach((element) {
        list.add(SchoolModel.fromMap(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
  }
}
