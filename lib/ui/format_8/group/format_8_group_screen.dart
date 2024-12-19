import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/student_service.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/student_model.dart';
import 'package:xueli/ui/format_8/format_8_screen.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:collection/collection.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

class Format8GroupScreen extends HookConsumerWidget {
  final bool isFirstTime;
  const Format8GroupScreen({super.key, this.isFirstTime = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final studentList = ref.watch(classStudentsProvider(FilterClass(
        classId: teacher?.classId ?? 0,
        schoolId: teacher?.schoolId ?? 0,
        teacherId: teacher?.id ?? 0)));
    final list = useState([
      EnglishNumbers.list[0],
      EnglishNumbers.list[1],
      EnglishNumbers.list[2],
      EnglishNumbers.list[3],
      EnglishNumbers.list[4],
    ]);
    final ValueNotifier<Map<int, NumberModel>> redSelectedNames = useState({});
    final ValueNotifier<Map<int, NumberModel>> orangeSelectedNames =
        useState({});
    final ValueNotifier<Map<int, NumberModel>> yellowSelectedNames =
        useState({});
    final ValueNotifier<Map<int, NumberModel>> greenSelectedNames =
        useState({});
    final ValueNotifier<Map<int, NumberModel>> blueSelectedNames = useState({});
    final ValueNotifier<Map<int, NumberModel>> purpleSelectedNames =
        useState({});
    final ValueNotifier<Map<int, String>> studentColor = useState({});
    final loading = useState(false);

    final sortedStudentList = ref.watch(
        classStudentsFormat8SortedAllStudentsProvider(FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0)));
    void setStudents(List<StudentModel> studentList) {
      studentList.forEach((element) {
        if (element.eight_group == GroupNames.purple) {
          if (element.eight_sort > 0) {
            studentColor.value[element.id] = element.eight_group;
            purpleSelectedNames.value[element.id] =
                list.value[element.eight_sort - 1];
          }
        } else if (element.eight_group == GroupNames.green) {
          if (element.eight_sort > 0) {
            studentColor.value[element.id] = element.eight_group;
            greenSelectedNames.value[element.id] =
                list.value[element.eight_sort - 1];
          }
        } else if (element.eight_group == GroupNames.blue) {
          if (element.eight_sort > 0) {
            studentColor.value[element.id] = element.eight_group;
            blueSelectedNames.value[element.id] =
                list.value[element.eight_sort - 1];
          }
        } else if (element.eight_group == GroupNames.red) {
          if (element.eight_sort > 0) {
            studentColor.value[element.id] = element.eight_group;
            redSelectedNames.value[element.id] =
                list.value[element.eight_sort - 1];
          }
        } else if (element.eight_group == GroupNames.orange) {
          if (element.eight_sort > 0) {
            studentColor.value[element.id] = element.eight_group;
            orangeSelectedNames.value[element.id] =
                list.value[element.eight_sort - 1];
          }
        } else if (element.eight_group == GroupNames.yellow) {
          if (element.eight_sort > 0) {
            studentColor.value[element.id] = element.eight_group;
            yellowSelectedNames.value[element.id] =
                list.value[element.eight_sort - 1];
          }
        }
      });
    }

    useEffect(() {
      if (sortedStudentList.asData?.value != null) {
        final list = sortedStudentList.asData!.value;
        setStudents(list);
      }
      return;
    }, []);
    ref.listen(
        classStudentsFormat8SortedAllStudentsProvider(FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0)), (previous, next) {
      if (next.asData?.value != null) {
        final list = next.asData!.value;
        setStudents(list);
      }
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
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  CustomAppBar2(title: context.tr(LocaleKeys.groups)),
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
                                itemCount: items.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = items[index];
                                  final color = studentColor.value[item.id];
                                  return _StudentItem(
                                    selected: studentColor.value[item.id] ==
                                            GroupNames.red
                                        ? redSelectedNames.value
                                        : studentColor.value[item.id] ==
                                                GroupNames.orange
                                            ? orangeSelectedNames.value
                                            : studentColor.value[item.id] ==
                                                    GroupNames.yellow
                                                ? yellowSelectedNames.value
                                                : studentColor.value[item.id] ==
                                                        GroupNames.green
                                                    ? greenSelectedNames.value
                                                    : studentColor.value[
                                                                item.id] ==
                                                            GroupNames.blue
                                                        ? blueSelectedNames
                                                            .value
                                                        : purpleSelectedNames
                                                            .value,
                                    studentModel: item,
                                    list: list.value,
                                    callback: (NumberModel name) {
                                      final color = studentColor.value[item.id];
                                      if (color == GroupNames.red) {
                                        redSelectedNames.value[item.id] = name;
                                      } else if (color == GroupNames.orange) {
                                        orangeSelectedNames.value[item.id] =
                                            name;
                                      } else if (color == GroupNames.yellow) {
                                        yellowSelectedNames.value[item.id] =
                                            name;
                                      } else if (color == GroupNames.green) {
                                        greenSelectedNames.value[item.id] =
                                            name;
                                      } else if (color == GroupNames.blue) {
                                        blueSelectedNames.value[item.id] = name;
                                      } else if (color == GroupNames.purple) {
                                        purpleSelectedNames.value[item.id] =
                                            name;
                                      }
                                    },
                                    colorCallback: (String color) {
                                      if (studentColor.value[item.id] != null) {
                                        Map<int, String> list = {};
                                        studentColor.value
                                            .forEach((key, value) {
                                          if (key != item.id) {
                                            list[key] = value;
                                          }
                                        });
                                        studentColor.value = list;
                                        if (color == GroupNames.red) {
                                          redSelectedNames.value
                                              .remove(item.id);
                                        } else if (color == GroupNames.orange) {
                                          orangeSelectedNames.value
                                              .remove(item.id);
                                        } else if (color == GroupNames.yellow) {
                                          yellowSelectedNames.value
                                              .remove(item.id);
                                        } else if (color == GroupNames.green) {
                                          greenSelectedNames.value
                                              .remove(item.id);
                                        } else if (color == GroupNames.blue) {
                                          blueSelectedNames.value
                                              .remove(item.id);
                                        } else if (color == GroupNames.purple) {
                                          purpleSelectedNames.value
                                              .remove(item.id);
                                        }
                                      } else {
                                        Map<int, String> list = {};
                                        studentColor.value
                                            .forEach((key, value) {
                                          if (key != item.id) {
                                            list[key] = value;
                                          }
                                        });
                                        list[item.id] = color;
                                        // studentColor.value[item.id] = color;
                                        studentColor.value = list;
                                      }
                                    },
                                    colorSelected: studentColor.value,
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
                    label: context.tr(LocaleKeys.update),
                    loading: loading.value,
                    onPressed: () async {
                      var total = purpleSelectedNames.value.length +
                          blueSelectedNames.value.length +
                          greenSelectedNames.value.length +
                          yellowSelectedNames.value.length +
                          orangeSelectedNames.value.length +
                          redSelectedNames.value.length;
                      if (total != studentList.asData?.value.length) {
                        DialogHelper.showError(
                            context.tr(LocaleKeys.select_all_students));
                        return;
                      }
                      loading.value = true;
                      for (int id in redSelectedNames.value.keys) {
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat8Sort(GroupNames.red,
                                redSelectedNames.value[id]!.id, id);
                      }
                      for (int id in orangeSelectedNames.value.keys) {
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat8Sort(GroupNames.orange,
                                orangeSelectedNames.value[id]!.id, id);
                      }
                      for (int id in yellowSelectedNames.value.keys) {
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat8Sort(GroupNames.yellow,
                                yellowSelectedNames.value[id]!.id, id);
                      }
                      for (int id in greenSelectedNames.value.keys) {
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat8Sort(GroupNames.green,
                                greenSelectedNames.value[id]!.id, id);
                      }
                      for (int id in blueSelectedNames.value.keys) {
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat8Sort(GroupNames.blue,
                                blueSelectedNames.value[id]!.id, id);
                      }
                      for (int id in purpleSelectedNames.value.keys) {
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat8Sort(GroupNames.purple,
                                purpleSelectedNames.value[id]!.id, id);
                      }
                      var session = 1;
                      if (teacher!.levelId == 1) {
                        session = 1;
                      } else if (teacher.levelId == 2) {
                        session = 61;
                      } else if (teacher.levelId == 3) {
                        session = 181;
                      }
                      if (isFirstTime) {
                        await ref
                            .read(teacherServiceProvider)
                            .updateFormat8Session(session, teacher.id);
                      }
                      await ref.read(teacherServiceProvider).getTeacherProfile(
                          Supabase.instance.client.auth.currentUser!.id);
                      loading.value = false;
                      ref.refresh(sessionManagerProvider);
                      ref.refresh(classStudentsProvider(FilterClass(
                          classId: teacher?.classId ?? 0,
                          schoolId: teacher?.schoolId ?? 0,
                          teacherId: teacher?.id ?? 0)));
                      ref.refresh(classStudentsProvider(FilterClass(
                          classId: teacher?.classId ?? 0,
                          schoolId: teacher?.schoolId ?? 0,
                          teacherId: teacher?.id ?? 0)));
                      DialogHelper.showDialog(
                          LocaleKeys.updated_successfully.tr(), (p0) {
                        {
                          if (isFirstTime) {
                            NavManager().replace(const Format8Screen());
                          } else {
                            NavManager().goBack();
                          }
                        }
                      }, title: "");
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

class _StudentItem extends HookConsumerWidget {
  final StudentModel studentModel;
  final List<NumberModel> list;
  final ValueSetter<NumberModel> callback;
  final ValueSetter<String> colorCallback;
  final Map<int, NumberModel> selected;
  final Map<int, String> colorSelected;
  const _StudentItem(
      {super.key,
      required this.studentModel,
      required this.callback,
      required this.colorCallback,
      required this.selected,
      required this.colorSelected,
      required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<NumberModel?> selectedName = useState(null);
    final ValueNotifier<String?> selectedColor = useState(null);
    useEffect(() {
      Future.microtask(() {
        if (selected[studentModel.id] != null) {
          selectedName.value = selected[studentModel.id];
        } else {
          selectedName.value = null;
        }
        if (colorSelected[studentModel.id] != null) {
          selectedColor.value = colorSelected[studentModel.id];
        } else {
          selectedColor.value = null;
        }
      });
      return;
    }, [selected, colorSelected]);
    // useEffect(() {
    //   return;
    // }, [selectedColor.value, selectedName.value]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mustard.withOpacity(0.2),
        border:
            Border.all(color: AppColors.mustard.withOpacity(0.4), width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            studentModel.name,
            style: TextStyle(color: AppColors.black),
          ),
          const SizedBox(
            width: 10,
          ),
          if (selectedColor.value == null)
            Expanded(
                child: Row(
              children: [
                _ColorWidget(
                    color: AppColors.groupRed,
                    isCheck: false,
                    callback: () {
                      selectedColor.value = GroupNames.red;
                      colorCallback(GroupNames.red);
                    }),
                const SizedBox(
                  width: 5,
                ),
                _ColorWidget(
                    color: AppColors.groupOrange,
                    isCheck: false,
                    callback: () {
                      colorCallback(GroupNames.orange);
                      selectedColor.value = GroupNames.orange;
                    }),
                const SizedBox(
                  width: 5,
                ),
                _ColorWidget(
                    color: AppColors.groupYellow,
                    isCheck: false,
                    callback: () {
                      colorCallback(GroupNames.yellow);
                      selectedColor.value = GroupNames.yellow;
                    }),
                const SizedBox(
                  width: 5,
                ),
                _ColorWidget(
                    color: AppColors.groupGreen,
                    isCheck: false,
                    callback: () {
                      colorCallback(GroupNames.green);
                      selectedColor.value = GroupNames.green;
                    }),
                const SizedBox(
                  width: 5,
                ),
                _ColorWidget(
                    color: AppColors.groupBlue,
                    isCheck: false,
                    callback: () {
                      colorCallback(GroupNames.blue);
                      selectedColor.value = GroupNames.blue;
                    }),
                const SizedBox(
                  width: 5,
                ),
                _ColorWidget(
                    color: AppColors.groupPurple,
                    isCheck: false,
                    callback: () {
                      colorCallback(GroupNames.purple);
                      selectedColor.value = GroupNames.purple;
                    }),
              ],
            )),
          if (selectedColor.value != null)
            Expanded(
              child: Row(
                children: [
                  _ColorWidget(
                      color: selectedColor.value == GroupNames.red
                          ? AppColors.groupRed
                          : selectedColor.value == GroupNames.orange
                              ? AppColors.groupOrange
                              : selectedColor.value == GroupNames.yellow
                                  ? AppColors.groupYellow
                                  : selectedColor.value == GroupNames.green
                                      ? AppColors.groupGreen
                                      : selectedColor.value == GroupNames.blue
                                          ? AppColors.groupBlue
                                          : AppColors.groupPurple,
                      isCheck: true,
                      callback: () {
                        colorCallback(selectedColor.value!);
                      }),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: selectedColor.value == GroupNames.red
                            ? AppColors.groupRed
                            : selectedColor.value == GroupNames.orange
                                ? AppColors.groupOrange
                                : selectedColor.value == GroupNames.yellow
                                    ? AppColors.groupYellow
                                    : selectedColor.value == GroupNames.green
                                        ? AppColors.groupGreen
                                        : selectedColor.value == GroupNames.blue
                                            ? AppColors.groupBlue
                                            : AppColors.groupPurple,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<NumberModel>(
                          dropdownColor: AppColors.white,
                          hint: Text(
                            "",
                            style: TextStyle(
                                color: AppColors.textFieldHint,
                                fontWeight: FontWeight.w400,
                                fontSize: 17),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down_outlined,
                            color: AppColors.white,
                          ),
                          elevation: 16,
                          selectedItemBuilder: (BuildContext context) {
                            return list.map<Widget>((NumberModel item) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                constraints:
                                    const BoxConstraints(minWidth: 100),
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList();
                          },
                          style: TextStyle(color: AppColors.textFieldText),
                          value: selectedName.value,
                          onChanged: (NumberModel? Value) {
                            if (Value != null) {
                              if (selected.values.firstWhereOrNull(
                                      (element) => element == Value) ==
                                  null) {
                                selectedName.value = Value;
                                callback(Value);
                              } else {
                                DialogHelper.showError(context.tr(
                                    LocaleKeys.already_assigned_to_student));
                              }
                            }
                          },
                          items: list.map((NumberModel type) {
                            return DropdownMenuItem<NumberModel>(
                              value: type,
                              child: Text(
                                type.name,
                                maxLines: 1,
                                style: TextStyle(
                                    color: AppColors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

class _ColorWidget extends StatelessWidget {
  final Color color;
  final bool isCheck;
  final VoidCallback callback;
  const _ColorWidget(
      {super.key,
      required this.color,
      required this.isCheck,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: isCheck
            ? const Center(
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
