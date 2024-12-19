import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:xueli/ui/format_7/format_7_screen.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:collection/collection.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

class SortStudentsScreen extends HookConsumerWidget {
  final bool isFirstTime;
  const SortStudentsScreen({super.key, this.isFirstTime = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final studentList = ref.watch(classStudentsFormat7SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0)));
    final ValueNotifier<Map<int, NumberModel>> selectedNames = useState({});
    final list = useState([EnglishNumbers.list.first]);
    final loading = useState(false);
    ref.listen(
        classStudentsFormat7SortedProvider(FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0)), (previous, next) {
      if (next.asData?.value != null) {
        final val = next.asData!.value;
        final length = val.length;
        if (length > 0) {
          var index = 1;
          while (index < length) {
            list.value.add(EnglishNumbers.list[index]);
            index += 1;
          }
          val.forEach((element) {
            if (element.format_seven_sort > 0) {
              selectedNames.value[element.id] =
                  list.value[element.format_seven_sort - 1];
            }
          });
        }
      }
    });
    useEffect(() {
      if (studentList.asData?.value != null) {
        final val = studentList.asData!.value;
        final length = val.length;
        if (length > 0) {
          var index = 1;
          while (index < length) {
            list.value.add(EnglishNumbers.list[index]);
            index += 1;
          }
          val.forEach((element) {
            if (element.format_seven_sort > 0) {
              selectedNames.value[element.id] =
                  list.value[element.format_seven_sort - 1];
            }
          });
        }
      }
      return;
    }, []);
    void resetList() {
      var newList = list;
    }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar2(title: LocaleKeys.sort_students.tr()),
                  const SizedBox(
                    height: 10,
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
                                  return _StudentItem(
                                    selected: selectedNames.value,
                                    studentModel: item,
                                    isBlue: index % 2 == 0,
                                    list: list.value,
                                    callback: (NumberModel? name) {
                                      if (name != null) {
                                        selectedNames.value[item.id] = name;
                                      } else {
                                        Map<int, NumberModel> list = {};
                                        selectedNames.value
                                            .forEach((key, value) {
                                          if (key != item.id) {
                                            list[key] = value;
                                          }
                                        });
                                        selectedNames.value = list;
                                        // selectedNames.value.remove(item.id);
                                      }
                                    },
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
                      // if (selectedNames.value.isEmpty) {
                      //   DialogHelper.showError(context.tr("No user selected"));
                      //   return;
                      // }
                      if (selectedNames.value.length !=
                          studentList.asData?.value.length) {
                        DialogHelper.showError(
                            context.tr(LocaleKeys.select_all_students));
                        return;
                      }
                      loading.value = true;
                      for (int id in selectedNames.value.keys) {
                        // print("id ${id}, ${selectedNames.value[id]!.id}");
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentFormat7Sort(
                                selectedNames.value[id]!.id, id);
                      }
                      if (isFirstTime) {
                        await ref
                            .read(teacherServiceProvider)
                            .updateFormat7Session(1, teacher?.id ?? 0);
                      }
                      await ref.read(teacherServiceProvider).getTeacherProfile(
                          Supabase.instance.client.auth.currentUser!.id);
                      loading.value = false;
                      ref.refresh(sessionManagerProvider);
                      ref.refresh(classStudentsProvider(FilterClass(
                          classId: teacher?.classId ?? 0,
                          schoolId: teacher?.schoolId ?? 0,
                          teacherId: teacher?.id ?? 0)));
                      DialogHelper.showDialog(
                          LocaleKeys.updated_successfully.tr(), (p0) {
                        if (isFirstTime) {
                          NavManager().replace(const Format7Screen());
                        } else {
                          NavManager().goBack();
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
  final bool isBlue;
  final List<NumberModel> list;
  final ValueSetter<NumberModel?> callback;
  final Map<int, NumberModel> selected;
  const _StudentItem(
      {super.key,
      required this.studentModel,
      required this.isBlue,
      required this.callback,
      required this.selected,
      required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<NumberModel?> selectedName = useState(null);
    Future.microtask(() {
      if (selected[studentModel.id] != null) {
        selectedName.value = selected[studentModel.id];
      }
    });
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isBlue
            ? AppColors.lightBlue.withOpacity(0.2)
            : AppColors.mustard.withOpacity(0.2),
        border: Border.all(
            color: isBlue
                ? AppColors.lightBlue.withOpacity(0.4)
                : AppColors.mustard.withOpacity(0.4),
            width: 0.5),
        borderRadius: BorderRadius.circular(6),
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
            width: 10,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isBlue ? AppColors.lightBlue : AppColors.mustard,
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
                        constraints: const BoxConstraints(minWidth: 100),
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
                      final select = selected.values
                          .firstWhereOrNull((element) => element == Value);
                      if (select == null) {
                        selectedName.value = Value;
                        callback(Value);
                      } else if (select?.id == selectedName.value?.id) {
                        selectedName.value = null;
                        callback(null);
                      } else {
                        DialogHelper.showError(
                            context.tr(LocaleKeys.already_assigned_to_student));
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
          )
        ],
      ),
    );
  }
}
