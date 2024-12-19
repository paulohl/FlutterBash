import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/data/providers/common_language_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/common_language_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/common_language_category_model.dart';
import 'package:xueli/models/common_language_model.dart';
import 'package:xueli/ui/common_language/selection/add/add_common_language_screen.dart';
import 'package:xueli/ui/main/main_screen.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

class CommonLanguageSelectionScreen extends HookConsumerWidget {
  const CommonLanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    // final AsyncValue<List<CommonLanguageModel>> sentenceList = ref.watch(
    //     commonLanguage10RandomLevelSentenceProvider(teacher?.levelId ?? 0));
    ValueNotifier<List<CommonLanguageModel>> newList = useState([]);
    final loading = useState(false);
    final listLoading = useState(true);
    ref.listen(
        commonLanguage10RandomLevelSentenceProvider(FilterClass(
            classId: teacher?.levelId ?? 0,
            schoolId: 0,
            teacherId: teacher!.id)), (previous, next) {
      if (next.asData?.value != null) {
        newList.value = next.asData!.value;
        listLoading.value = false;
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
                  Expanded(
                    child: Container(
                      child: listLoading.value
                          ? CenterLoadingView(
                              color: AppColors.mustard,
                            )
                          : newList.value.isEmpty
                              ? CenterErrorView(
                                  errorMsg:
                                      context.tr(LocaleKeys.no_sentence_found),
                                )
                              : MasonryGridView.count(
                                  itemCount: newList.value.length,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final item = newList.value[index];
                                    return _CommonLanguageItem(
                                        languageModel: item,
                                        closeTapped: () {
                                          var list = newList.value;
                                          list = list
                                              .where((element) =>
                                                  element.id != item.id)
                                              .toList();
                                          newList.value = list;
                                        },
                                        playTapped: () {});
                                  },
                                  crossAxisCount: 1,
                                ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CoreButton(
                    label: newList.value.length < 10
                        ? LocaleKeys.add_more_sentence.tr()
                        : LocaleKeys.enter_app.tr(),
                    loading: loading.value,
                    onPressed: () async {
                      if (newList.value.length < 10) {
                        List<CommonLanguageModel>? res = await NavManager()
                            .goTo(AddCommonLanguageScreen(newList.value));
                        if (res != null) {
                          newList.value = res;
                        }
                      } else {
                        loading.value = true;
                        List<int> ids = [];
                        newList.value.forEach((element) {
                          ids.add(element.id);
                        });
                        final res = await ref
                            .read(commonLanguageServiceProvider)
                            .createTeacherCommonLanguage(teacher!.id, ids);
                        loading.value = false;
                        if (res) {
                          NavManager().goTo(const MainScreen());
                        }
                      }
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

class _CategoryItem extends HookConsumerWidget {
  final CommonLanguageCategoryModel categoryModel;
  const _CategoryItem({super.key, required this.categoryModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        categoryModel.name,
        style: TextStyle(
            color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    ]);
  }
}

class _CommonLanguageItem extends StatelessWidget {
  final CommonLanguageModel languageModel;
  final VoidCallback closeTapped;
  final VoidCallback playTapped;
  const _CommonLanguageItem(
      {super.key,
      required this.languageModel,
      required this.closeTapped,
      required this.playTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.brown),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              languageModel.text,
              style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              maxLines: 1,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            children: [
              GestureDetector(
                onTap: closeTapped,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: const Color(0xFF4F3422),
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Image.asset(
                      Assets.imagesIcons8Close,
                      height: 18,
                      width: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              // GestureDetector(
              //   onTap: playTapped,
              //   child: Container(
              //     width: 34,
              //     height: 30,
              //     decoration: BoxDecoration(
              //         color: AppColors.lightBlue,
              //         borderRadius: BorderRadius.circular(10)),
              //     child: Center(
              //       child: Image.asset(
              //         Assets.imagesIcons8AvailableUpdates,
              //         height: 18,
              //         width: 18,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }
}
