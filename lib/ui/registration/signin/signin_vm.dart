import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/ui/common_language/common_language_check_screen.dart';

import '../../../core/dialog_helper.dart';
import '../../../core/view_model.dart';
import '../../../data/services/registration_service.dart';
import '../../main/main_screen.dart';

final signinVMProvider = ChangeNotifierProvider.autoDispose<SigninVM>((ref) {
  final userService = ref.watch(teacherServiceProvider);
  final registrationService = ref.watch(registrationServiceProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return SigninVM(userService, registrationService, sessionManager);
});

class SigninVM extends ViewModel {
  final TeacherService teacherService;
  final RegistrationService registrationService;
  final SessionManager sessionManager;

  SigninVM(this.teacherService, this.registrationService, this.sessionManager);

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (validateCredentials(email, password)) {
      showLoading();
      final res = await registrationService.signinUser(email, password);
      if (res != null) {
        teacherService
            .getTeacherProfile(Supabase.instance.client.auth.currentUser!.id)
            .then((value) {
          if (value != null && value.isEnabled) {
            sessionManager.saveTeacherProfile(value);
            teacherService.getTeacherTodayLoginData(value.id).then((value) {
              hideLoading();
              if (value != null && value.common_id.isNotEmpty) {
                NavManager()
                    .goToAndRemoveUntil(const MainScreen(), (route) => false);
              } else {
                NavManager().goToAndRemoveUntil(
                    const CommonLanguageCheckScreen(), (route) => false);
              }
            });
          } else {
            hideLoading();
            registrationService.signOut();
          }
        });
      } else {
        hideLoading();
      }
    }
  }

  // Future<void> checkProfile(
  //     String uid, String name, String email, String? image) async {
  //   final user = await userService.getProfile(uid);
  //   if (user != null) {
  //     //goto main
  //     navManager.goToAndRemoveUntil(MainScreen(), (route) => false);
  //   } else {
  //     // await registrationService.updateProfile(name, email, image);
  //     navManager.goToAndRemoveUntil(
  //         CompleteProfileScreen(""), (route) => false);
  //     // navManager.goToAndRemoveUntil(
  //     //     CreateItemScreen(
  //     //       isFirstTime: true,
  //     //     ),
  //     //     (route) => false);
  //     hideLoading();
  //     // registrationService.signOut();
  //     // DialogHelper.showError("You are blocked by admin to use this app");
  //   }
  // }

  bool validateCredentials(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      DialogHelper.showError(LocaleKeys.both_fields_required.tr());
      return false;
    }

    // if (!isEmailValid(email)) {
    //   DialogHelper.showError("Email is invalid");
    //   return false;
    // }

    if (password.length < 8) {
      DialogHelper.showError(LocaleKeys.password_required.tr());
      return false;
    }

    return true;
  }

  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
}
