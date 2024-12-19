import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/data/session_manager/session_manager.dart';

import '../../core/dialog_helper.dart';
import '../../models/app_version.dart';

final registrationServiceProvider = Provider((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return RegistrationService(sessionManager);
});

class RegistrationService {
  final supabase = Supabase.instance.client;
  final SessionManager sessionManager;

  RegistrationService(this.sessionManager);

  Future<AuthResponse?> signinUser(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        phone: email,
        password: password,
      );
      return res;
    } on AuthException catch (e) {
      DialogHelper.showError(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    await sessionManager.deleteSession();
    return await supabase.auth.signOut();
  }

  Future<AppVersion?> getAppVersion() async {
    //AppVersion
    AppVersion? list;
    try {
      final PostgrestList data = await supabase.from('AppVersion').select('*');
      data.forEach((element) {
        list = (AppVersion.fromJSON(element));
      });
      return list;
    } on PostgrestException catch (e) {
      DialogHelper.showError(e.message);
      return list;
    }
    return null;
    // final snap = await FirebaseDatabase.instance.ref("AppVersions").once();
    // if (snap.snapshot.exists) {
    //   final appVersion =
    //   AppVersion.fromJSON(snap.snapshot.value as LinkedHashMap);
    //   return appVersion;
    // } else {
    //   return null;
    // }
  }
}
