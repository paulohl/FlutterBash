import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/common_language_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/common_language_model.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

class AddCommonLanguageScreen extends HookConsumerWidget {
  final List<CommonLanguageModel> previous;
  const AddCommonLanguageScreen(this.previous, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final AsyncValue<List<CommonLanguageModel>> sentenceList = ref.watch(
        commonLanguageLevelNonRepeatedSentencesProvider(FilterClass(
            classId: teacher?.levelId ?? 0,
            schoolId: 0,
            teacherId: teacher!.id)));
    ValueNotifier<List<CommonLanguageModel>> newList = useState([]);
    ValueNotifier<List<CommonLanguageModel>> selectedList = useState(previous);
    ref.listen(
        commonLanguageLevelNonRepeatedSentencesProvider(FilterClass(
            classId: teacher?.levelId ?? 0,
            schoolId: 0,
            teacherId: teacher!.id)), (previous, next) {
      if (next.asData?.value != null) {
        newList.value = next.asData!.value;
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
                CustomAppBar2(title: LocaleKeys.select.tr()),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Container(
                    child: sentenceList.when(data: (itemList) {
                      // newList.value = itemList;
                      List<CommonLanguageModel> list = [];
                      itemList.forEach((element) {
                        if (!selectedList.value.contains(element)) {
                          list.add(element);
                        }
                      });
                      newList.value = list;
                      // useValueListenable(newList);
                      return newList.value.isEmpty
                          ? CenterErrorView(
                              errorMsg:
                                  context.tr(LocaleKeys.no_sentence_found),
                            )
                          : MasonryGridView.count(
                              itemCount: newList.value.length,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              itemBuilder: (BuildContext context, int index) {
                                final item = newList.value[index];
                                return _CommonLanguageItem(
                                    languageModel: item,
                                    closeTapped: () {
                                      if (selectedList.value.length < 10) {
                                        var list = newList.value;
                                        list = list
                                            .where((element) =>
                                                element.id != item.id)
                                            .toList();
                                        newList.value = list;
                                        selectedList.value = [
                                          ...selectedList.value,
                                          item
                                        ];
                                      } else {
                                        DialogHelper.showError(LocaleKeys
                                            .cannot_select_more_than_10_items
                                            .tr());
                                      }
                                    },
                                    playTapped: () {});
                              },
                              crossAxisCount: 1,
                            );
                    }, error: (err, trace) {
                      debugPrint(
                          "Error occurred while fetching elements: $err");
                      return CenterErrorView(
                        errorMsg: context.tr(LocaleKeys.error_fetching_element),
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
                  label: LocaleKeys.save.tr(),
                  onPressed: () {
                    NavManager().goBack(selectedList.value);
                  },
                ),
              ],
            ),
          )),
        ],
      ),
    );
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
                  fontSize: 18),
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
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
