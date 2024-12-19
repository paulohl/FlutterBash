import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/services/registration_service.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/ui/common_language/common_language_screen.dart';
import 'package:xueli/ui/registration/signin/signin_screen.dart';
import 'package:xueli/ui/students/students_screen.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr(LocaleKeys.settings),
                  style: TextStyle(
                      color: AppColors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 20,
              ),
              _UserItem(
                  title: context.tr(LocaleKeys.common_language),
                  image: Assets.imagesLanguage,
                  callback: () {
                    NavManager().goTo(const CommonLanguageScreen());
                  }),
              const SizedBox(
                height: 10,
              ),
              _UserItem(
                  title: context.tr(LocaleKeys.student_list),
                  image: Assets.imagesStudents,
                  callback: () {
                    NavManager().goTo(const StudentsScreen());
                  }),
              const SizedBox(
                height: 10,
              ),
              _UserItem(
                  title: context.tr(LocaleKeys.security),
                  image: Assets.imagesSecurity,
                  callback: () {}),
              const SizedBox(
                height: 10,
              ),
              _UserItem(
                  title: context.tr(LocaleKeys.personal_center),
                  image: Assets.imagesHelp,
                  callback: () {}),
              const SizedBox(
                height: 10,
              ),
              _UserItem(
                  title: context.tr(LocaleKeys.change_language),
                  image: Assets.imagesLanguage,
                  callback: () {
                    if (context.locale.toString() == 'en') {
                      context.setLocale(const Locale('zh'));
                    } else {
                      context.setLocale(const Locale('en'));
                    }
                  }),
              const SizedBox(
                height: 10,
              ),
              _UserItem(
                  title: context.tr(LocaleKeys.logout),
                  image: Assets.imagesLogout,
                  callback: () {
                    DialogHelper.showConfirmationDialog(
                        context.tr(LocaleKeys.are_you_sure), (p0) async {
                      if (p0) {
                        await ref.read(registrationServiceProvider).signOut();
                        NavManager().goToAndRemoveUntil(
                            const SigninScreen(), (route) => false);
                      }
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserItem extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback callback;
  const _UserItem(
      {super.key,
      required this.title,
      required this.image,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.all(8),
        // decoration: BoxDecoration(
        //   color: AppColors.mustard.withOpacity(0.1),
        //   borderRadius: BorderRadius.circular(33),
        //   border:
        //       Border.all(color: AppColors.mustard.withOpacity(0.4), width: 0.5),
        // ),
        child: Row(
          children: [
            Center(
              child: Image.asset(
                image,
                height: 24,
                width: 24,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 24,
              color: AppColors.brown,
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback callback;
  const _LogoutItem(
      {super.key,
      required this.title,
      required this.image,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(33),
          border: Border.all(color: AppColors.red.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration:
                  BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
              child: Center(
                child: Image.asset(
                  image,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Image.asset(
              Assets.imagesArrow1,
              width: 28,
              height: 15,
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }
}
