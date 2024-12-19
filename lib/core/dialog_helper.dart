import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:xueli/generated/locale_keys.g.dart';

import '../constants/app_colors.dart';

class DialogHelper {
  static void showError(String errorMessage) {
    DialogManager().showEasyDialog(builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          LocaleKeys.sorry.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        content: Text(
          errorMessage,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          InkWell(
            onTap: () {
              NavManager().goBack();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                border: Border.all(color: AppColors.black),
              ),
              child: Text(
                LocaleKeys.ok.tr(),
                style: TextStyle(
                  color: AppColors.black,
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  static void showConfirmationDialog(String message, Function(bool) onConfirm,
      {String? title}) {
    DialogManager().showEasyDialog(builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        title: Text(
          title ?? LocaleKeys.confirmation.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          InkWell(
            onTap: () {
              NavManager().goBack();
              onConfirm(false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                border: Border.all(color: AppColors.black),
              ),
              child: Text(
                LocaleKeys.cancel.tr(),
                style: TextStyle(
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              NavManager().goBack();
              onConfirm(true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                border: Border.all(color: AppColors.black),
              ),
              child: Text(
                LocaleKeys.ok.tr(),
                style: TextStyle(
                  color: AppColors.black,
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  static void showDialog(String message, Function(bool) onConfirm,
      {required String title, String buttonTitle = "OK"}) {
    DialogManager().showEasyDialog(builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          InkWell(
            onTap: () {
              NavManager().goBack();
              onConfirm(true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                border: Border.all(color: AppColors.black),
              ),
              child: Text(
                buttonTitle,
                style: TextStyle(
                  color: AppColors.black,
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
