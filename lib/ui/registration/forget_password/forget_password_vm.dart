import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/dialog_helper.dart';
import '../../../core/view_model.dart';

final forgetPasswordVMProvider = ChangeNotifierProvider((ref) {
  return ForgetPasswordVM();
});

class ForgetPasswordVM extends ViewModel {
  Future<void> resetEmail({required String email}) async {
    if (validateCredentials(email)) {
      // showLoading();
      // try {
      //   await _auth.sendPasswordResetEmail(email: email);
      //   hideLoading();
      //   showSuccessSnack(
      //       "Password reset link sent to your email address $email");
      //   NavManager().goBack();
      // } catch (e) {
      //   print(e);
      //   hideLoading();
      //   if (e is FirebaseAuthException) {
      //     if (e.message != null) {
      //       // if (e.message!.contains("There is no user record")) {
      //       //   DialogHelper.showError(
      //       //       "Il n'y a pas d'enregistrement d'utilisateur correspondant à cet identifiant. L'utilisateur a peut-être été supprimé.");
      //       // } else {
      //       DialogHelper.showError(e.message!);
      //       // }
      //     } else {
      //       DialogHelper.showError("Error occurred, please try again");
      //     }
      //   } else {
      //     DialogHelper.showError("Error occurred, please try again");
      //   }
      // }
    }
  }

  bool validateCredentials(String email) {
    if (email.isEmpty) {
      DialogHelper.showError("Email is required");
      return false;
    }

    if (!isEmailValid(email)) {
      DialogHelper.showError("Email is invalid");
      return false;
    }

    return true;
  }

  void showSuccessSnack(String success) {
    SnackBarManager().showEasySnackbar(SnackBar(
      content: Text(
        success,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    ));
  }

  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
}
