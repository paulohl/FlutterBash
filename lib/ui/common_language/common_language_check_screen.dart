import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/data/services/common_language_service.dart';
import 'package:xueli/data/services/forgetting_curve_service.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/models/teacher_common_language_model.dart';
import 'package:xueli/ui/common_language/selection/common_language_selection_screen.dart';
import 'package:xueli/ui/main/main_screen.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';

class CommonLanguageCheckScreen extends HookConsumerWidget {
  const CommonLanguageCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    void checkCommonLanguage() {
      ref
          .read(commonLanguageServiceProvider)
          .getTeacherCommonLanguageUnCompletedList(teacher?.id ?? 0)
          .then((commonList) {
        if (commonList.isNotEmpty) {
          //contains list of previous record, now check whether there is some repeat data for forgetting curve or new data
          ref
              .read(teacherServiceProvider)
              .getTeacherLoginData(teacher?.id ?? 0)
              .then((value) {
            if (value.isNotEmpty) {
              ref
                  .read(forgettingCurveServiceProvider)
                  .getForgettingCurve()
                  .then((value1) {
                List<int> days = [];
                value1.forEach((element) {
                  days.add(element.day);
                });
                if (value1.isEmpty) {
                  days = [1, 3, 5, 7, 14, 28];
                }
                days.sort((a, b) => a.compareTo(b));
                // var days = [1, 3, 5, 7, 14, 28];
                List<TeacherCommonLanguageModel> repeatList = [];
                commonList.forEach((element1) {
                  var index = value
                      .indexWhere((element) => element.date == element1.date);
                  if (index != -1) {
                    var dayAfterItPassed = value.length - index;
                    //as last element is at 2, and length is 3, it will return 1
                    //1,2,3,4
                    //// to add current day in it, for example, if previous day new content created, then today it's days will be zero, as login data will be added when common language list is selected
                    // dayAfterItPassed += 1;
                    if (days.contains(dayAfterItPassed)) {
                      //need to repeat this today,
                      if (days.last == dayAfterItPassed) {
                        element1.is_completed = true;
                      }
                      repeatList.add(element1);
                    }
                  }
                });
                if (repeatList.isNotEmpty) {
                  //add repeat, content and goto main screen
                  ref
                      .read(commonLanguageServiceProvider)
                      .addRepeatCommonLanguage(teacher?.id ?? 0, repeatList)
                      .then((value) {
                    if (value) {
                      NavManager().goTo(const MainScreen());
                    } else {
                      checkCommonLanguage();
                    }
                  });
                } else {
                  //goto selection screen
                  NavManager().goToAndRemoveUntil(
                      const CommonLanguageSelectionScreen(), (route) => false);
                }
              });
            } else {
              //no login record goto selection screen
              NavManager().goToAndRemoveUntil(
                  const CommonLanguageSelectionScreen(), (route) => false);
            }
          });
        } else {
          //No previous data goto selection screen
          NavManager().goToAndRemoveUntil(
              const CommonLanguageSelectionScreen(), (route) => false);
        }
      });
    }

    useEffect(() {
      checkCommonLanguage();
      return;
    }, []);
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
          CenterLoadingView(
            color: AppColors.mustard,
          ),
        ],
      ),
    );
  }
}
