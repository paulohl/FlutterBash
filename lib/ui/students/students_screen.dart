import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/student_model.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

import 'assign_name/assign_student_english_name_screen.dart';

class StudentsScreen extends HookConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final studentList = ref.watch(classStudentsProvider(FilterClass(
        classId: teacher?.classId ?? 0,
        schoolId: teacher?.schoolId ?? 0,
        teacherId: teacher?.id ?? 0)));
    return Scaffold(
      backgroundColor: Colors.white,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar2(title: context.tr(LocaleKeys.students)),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      child: studentList.when(data: (items) {
                        return items.isEmpty
                            ? CenterErrorView(
                                errorMsg:
                                    context.tr(LocaleKeys.no_student_found),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 8),
                                itemCount: items.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = items[index];
                                  return _StudentItem(
                                    studentModel: item,
                                    isBlue: index % 2 == 0,
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(
                                    height: 10,
                                  );
                                },
                              );
                      }, error: (err, trace) {
                        debugPrint(
                            "Error occurred while fetching elements: $err");
                        return CenterErrorView(
                          errorMsg:
                              context.tr(LocaleKeys.error_fetching_element),
                        );
                      }, loading: () {
                        return CenterLoadingView(
                          color: AppColors.mustard,
                          size: 24,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CoreButton(
                    label: context.tr(LocaleKeys.assign_english_name),
                    onPressed: () {
                      NavManager().goTo(const AssignStudentEnglishNameScreen());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentItem extends StatelessWidget {
  final StudentModel studentModel;
  final bool isBlue;
  const _StudentItem(
      {super.key, required this.studentModel, required this.isBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isBlue ? AppColors.lightBlue : AppColors.mustard,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              studentModel.name,
              style: TextStyle(color: AppColors.black),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          if (studentModel.englishNameModel != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBlue ? AppColors.lightBlue : AppColors.mustard,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                studentModel.englishNameModel?.name ?? "",
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }
}
