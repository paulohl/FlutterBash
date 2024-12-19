import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/english_name_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/student_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/english_name_model.dart';
import 'package:xueli/models/student_model.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/primary_button.dart';
import 'package:collection/collection.dart';

class AssignStudentEnglishNameScreen extends HookConsumerWidget {
  const AssignStudentEnglishNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final studentList = ref.watch(classStudentsProvider(FilterClass(
        classId: teacher?.classId ?? 0,
        schoolId: teacher?.schoolId ?? 0,
        teacherId: teacher?.id ?? 0)));
    final englishGirlNameList =
        ref.watch(englishGirlNameProvider).asData?.value ?? [];
    final englishBoyNameList =
        ref.watch(englishBoyNameProvider).asData?.value ?? [];
    final ValueNotifier<Map<int, EnglishNameModel>> selectedNames =
        useState({});
    final loading = useState(false);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppBar2(
                      title: context.tr(LocaleKeys.assign_student_name)),
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
                                    selected: selectedNames.value,
                                    studentModel: item,
                                    isBlue: index % 2 == 0,
                                    list: item.gender == "Female"
                                        ? englishGirlNameList
                                        : englishBoyNameList,
                                    callback: (EnglishNameModel name) {
                                      selectedNames.value[item.id] = name;
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
                      if (selectedNames.value.isEmpty) {
                        DialogHelper.showError(
                            context.tr(LocaleKeys.no_name_selected));
                        return;
                      }
                      loading.value = true;
                      for (int id in selectedNames.value.keys) {
                        // print("id ${id}, ${selectedNames.value[id]!.id}");
                        await ref
                            .read(studentServiceProvider)
                            .updateStudentEnglishName(
                                selectedNames.value[id]!.id, id);
                      }
                      loading.value = false;
                      // ref.refresh(classStudentsProvider(FilterClass(
                      //     classId: teacher?.classId ?? 0,
                      //     schoolId: teacher?.schoolId ?? 0,
                      //     teacherId: teacher?.id ?? 0)));
                      DialogHelper.showDialog(
                          LocaleKeys.updated_successfully.tr(), (p0) {
                        ref.refresh(classStudentsProvider(FilterClass(
                            classId: teacher?.classId ?? 0,
                            schoolId: teacher?.schoolId ?? 0,
                            teacherId: teacher?.id ?? 0)));
                        NavManager().goBack();
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
  final List<EnglishNameModel> list;
  final ValueSetter<EnglishNameModel> callback;
  final Map<int, EnglishNameModel> selected;
  const _StudentItem(
      {super.key,
      required this.studentModel,
      required this.isBlue,
      required this.callback,
      required this.selected,
      required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<EnglishNameModel?> selectedName = useState(null);
    Future.microtask(() {
      if (selectedName.value == null) {
        if (selected[studentModel.id] != null) {
          selectedName.value = selected[studentModel.id];
        } else {
          final item = list.firstWhereOrNull(
              (element) => element.id == studentModel.english_id);
          selectedName.value = item;
        }
      } else {
        // print(
        //     "stident name ${studentModel.name} , ${selectedName.value?.name}");
        // if (selected[studentModel.id] != null) {
        //   selectedName.value = selected[studentModel.id];
        // }
      }
    });
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                child: DropdownButton<EnglishNameModel>(
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
                    return list.map<Widget>((EnglishNameModel item) {
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
                  onChanged: (EnglishNameModel? Value) {
                    if (Value != null) {
                      selectedName.value = Value;
                      callback(Value);
                    }
                  },
                  items: list.map((EnglishNameModel type) {
                    return DropdownMenuItem<EnglishNameModel>(
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
