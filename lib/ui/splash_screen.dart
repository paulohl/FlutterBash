import 'dart:io';

import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/ui/common_language/common_language_check_screen.dart';
import 'package:xueli/ui/registration/signin/signin_screen.dart';

import '../core/dialog_helper.dart';
import '../data/services/registration_service.dart';
import 'main/main_screen.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      // ref.read(registrationServiceProvider).signOut();
      isUpdateAvailable(ref).then((value) {
        if (value) {
          PackageInfo.fromPlatform().then((value) => {
                DialogHelper.showConfirmationDialog(
                    "The version of your application v${value.version} is obsolete. Please update to the latest version.",
                    (p0) async {
                  if (p0) {
                    if (Platform.isAndroid) {
                      final uri = Uri.parse(
                          "https://play.google.com/store/apps/details?id=");
                      await launchUrl(uri);
                    } else {
                      final uri =
                          Uri.parse("https://apps.apple.com/us/app/ha/id");
                      await launchUrl(uri);
                    }
                  }
                }, title: "Update required")
              });
        } else {
          if (Supabase.instance.client.auth.currentUser != null) {
            ref
                .read(teacherServiceProvider)
                .getTeacherProfile(
                    Supabase.instance.client.auth.currentUser!.id)
                .then((value) {
              if (value != null && value.isEnabled) {
                ref.read(sessionManagerProvider).saveTeacherProfile(value);
                ref
                    .read(teacherServiceProvider)
                    .getTeacherTodayLoginData(value.id)
                    .then((value) {
                  if (value != null && value.common_id.isNotEmpty) {
                    NavManager().goToAndRemoveUntil(
                        const MainScreen(), (route) => false);
                  } else {
                    NavManager().goToAndRemoveUntil(
                        const CommonLanguageCheckScreen(), (route) => false);
                  }
                });
              } else {
                ref.read(registrationServiceProvider).signOut();
                NavManager()
                    .goToAndRemoveUntil(const SigninScreen(), (route) => false);
              }
            });
          } else {
            NavManager()
                .goToAndRemoveUntil(const SigninScreen(), (route) => false);
          }
        }
      });
    });
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.white,
                  Color(0xFFF9FBFF),
                  Color(0xFFF5F9FF)
                ])),
          ),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Image.asset(
                "assets/images/app_logo.png",
                height: 140,
                width: 140,
                // fit: BoxFit.fill,
              ),
            ),
          ))
        ],
      ),
    );
  }

  Future<bool> isUpdateAvailable(WidgetRef ref) async {
    final appVersion =
        await ref.read(registrationServiceProvider).getAppVersion();
    if (appVersion != null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      if (Platform.isAndroid) {
        print("version: $version, $buildNumber");
        print("appversion ${appVersion.android}");
        print(version.compareTo(appVersion.android));
        if (version.compareTo(appVersion.android) < 0) {
          return true;
        } else {
          return false;
        }
      } else {
        print("version: $version");
        print("appversion ${appVersion.ios}");
        print(version.compareTo(appVersion.ios));
        if (version.compareTo(appVersion.ios) < 0) {
          return true;
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }
}
