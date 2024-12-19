import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/data/providers/class_providers.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/ui/format_7/format_7_screen.dart';
import 'package:xueli/ui/format_7/sort_students/sort_students_screen.dart';
import 'package:xueli/ui/format_8/format_8_screen.dart';
import 'package:xueli/ui/format_8/group/format_8_group_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final classModel = ref.watch(classProvider(teacher!.classId)).asData?.value;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  Text("${classModel?.name}",
                      style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    width: 4,
                  ),
                  Text("${context.tr(LocaleKeys.level)} ${teacher!.levelId}",
                      style: const TextStyle(
                          color: Color(0xFFBDB2AB),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.time_table),
                        image: Assets.imagesFootball,
                        callback: () {}),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.game),
                        image: Assets.imagesFootball,
                        callback: () {}),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.physical_fitness),
                        image: Assets.imagesPhysical,
                        callback: () {}),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.nursery_rhymes),
                        image: Assets.imagesFootball,
                        callback: () {}),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.drama),
                        image: Assets.imagesFootball,
                        callback: () {}),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.other_format),
                        image: Assets.imagesFootball,
                        callback: () {}),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.accompany_card),
                        image: Assets.imagesCards,
                        callback: () {
                          if (ref
                                  .read(sessionManagerProvider)
                                  .getTeacherProfile() !=
                              null) {
                            final val = ref
                                .read(sessionManagerProvider)
                                .getTeacherProfile()!;
                            if (val.formatSevenSession != 0) {
                              NavManager().goTo(const Format7Screen());
                            } else {
                              NavManager().goTo(const SortStudentsScreen());
                            }
                          }
                        }),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: _FormatItem(
                        title: context.tr(LocaleKeys.stem),
                        image: Assets.imagesFootball,
                        callback: () {
                          if (ref
                                  .read(sessionManagerProvider)
                                  .getTeacherProfile() !=
                              null) {
                            final val = ref
                                .read(sessionManagerProvider)
                                .getTeacherProfile()!;
                            if (val.formatEightSession != 0) {
                              NavManager().goTo(const Format8Screen());
                            } else {
                              NavManager().goTo(const Format8GroupScreen());
                            }
                          }
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatItem extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback callback;
  const _FormatItem(
      {super.key,
      required this.title,
      required this.image,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
            child: Center(
              child: Image.asset(
                image,
                height: 110,
                width: 110,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
