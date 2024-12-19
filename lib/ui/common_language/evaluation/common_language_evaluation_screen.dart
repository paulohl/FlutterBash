import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/audio_player_providers.dart';
import 'package:xueli/data/providers/common_language_providers.dart';
import 'package:xueli/data/services/common_language_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/common_language_model.dart';
import 'package:xueli/models/evaluation_model.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/primary_button.dart';
import 'package:collection/collection.dart';

class CommonLanguageEvaluationScreen extends HookConsumerWidget {
  const CommonLanguageEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final evaluationList = ref
            .watch(
                commonLanguageTeacherEvaluationListProvider(teacher?.id ?? 0))
            .asData
            ?.value ??
        [];
    final AsyncValue<List<CommonLanguageModel>> list =
        ref.watch(commonLanguageSentenceListProvider(evaluationList));
    final ValueNotifier<List<CommonLanguageModel>> newList = useState([]);
    final ValueNotifier<List<CommonLanguageModel>> checkSelectedList =
        useState([]);
    final ValueNotifier<List<CommonLanguageModel>> unCheckSelectedList =
        useState([]);
    final AsyncValue<EvaluationModel?> evaluationResult = ref.watch(
        getEvaluationResult(
            evaluationList.isNotEmpty ? evaluationList.first.id : 0));

    final loading = useState(false);
    final isFirstTime = useState(true);
    var audioModeList = [
      AudioMode.english,
      AudioMode.chinese,
      AudioMode.englishAndChinese,
      AudioMode.chineseAndEnglish,
    ];
    var selectedAudioMode = useState(session.getCLAudioMode());
    var timeIntervalList = ["0s", "1s", "2s", "3s"];
    var selectedTextInterval = useState("${session.getCLTextInterval()}s");
    var selectedENGCHNInterval = useState("${session.getCLENGCHNInterval()}s");
    final audioPlayer = ref.watch(audioPlayerOnceProvider);
    final isAudioLoading = useState(false);
    void updateEvaluationResult(EvaluationModel item) {
      final sentenceList = list.asData?.value ?? [];
      item.list.indexed.forEach((element) {
        final id = int.tryParse(element.$2.toString());
        final res = item.evaluation_result[element.$1];
        final sentence =
            sentenceList.firstWhereOrNull((element) => element.id == id);
        if (sentence != null) {
          if (res) {
            if (unCheckSelectedList.value.contains(item)) {
              var list = unCheckSelectedList.value;
              list = list.where((element) => element.id != item.id).toList();
              unCheckSelectedList.value = list;
            } else {
              checkSelectedList.value = [...checkSelectedList.value, sentence];
            }
          } else {
            if (checkSelectedList.value.contains(item)) {
              var list = checkSelectedList.value;
              list = list.where((element) => element.id != item.id).toList();
              checkSelectedList.value = list;
            } else {
              unCheckSelectedList.value = [
                ...unCheckSelectedList.value,
                sentence
              ];
            }
          }
        }
      });
    }

    ref.listen(
        getEvaluationResult(
            evaluationList.isNotEmpty ? evaluationList.first.id : 0),
        (previous, next) {
      if (next.asData?.value != null) {
        final res = next.asData!.value;
        if (res != null) {
          updateEvaluationResult(res);
        }
      }
    });

    useEffect(() {
      // audioPlayer.playerStateStream.listen((state) {
      //   if (state.playing) {
      //     isAudioLoading.value = false;
      //   } else {
      //     // isAudioLoading.value = false;
      //   }
      //   switch (state.processingState) {
      //     case ProcessingState.idle:
      //       {
      //         isAudioLoading.value = false;
      //       }
      //     case ProcessingState.loading:
      //       {
      //         isAudioLoading.value = true;
      //       }
      //     case ProcessingState.buffering:
      //       {
      //         isAudioLoading.value = true;
      //       }
      //     case ProcessingState.ready:
      //       {
      //         isAudioLoading.value = false;
      //       }
      //     case ProcessingState.completed:
      //       {
      //         isAudioLoading.value = false;
      //       }
      //   }
      // });
      if (evaluationResult.asData?.value != null) {
        final res = evaluationResult.asData!.value;
        if (res != null) {
          updateEvaluationResult(res);
        }
      }
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                NavManager().goBack();
                              },
                              child: Image.asset(
                                Assets.imagesBack,
                                height: 24,
                                width: 24,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          LocaleKeys.evaluation.tr(),
                          style: TextStyle(
                              color: AppColors.brown,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      Row(
                        children: [
                          StatefulBuilder(builder: (context, setState) {
                            return PopupMenuButton<String>(
                                elevation: 12,
                                color: AppColors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                onSelected: (val) async {},
                                child: Image.asset(
                                  Assets.imagesSetting,
                                  height: 24,
                                  width: 24,
                                ),
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        height: 35,
                                        value: "",
                                        padding: const EdgeInsets.only(left: 8),
                                        child: StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  LocaleKeys.audio_mode.tr(),
                                                  style: TextStyle(
                                                      color: AppColors.black),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      dropdownColor:
                                                          AppColors.white,
                                                      hint: Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .textFieldHint,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 17),
                                                      ),
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        color: AppColors.black,
                                                      ),
                                                      elevation: 16,
                                                      selectedItemBuilder:
                                                          (BuildContext
                                                              context) {
                                                        return audioModeList
                                                            .map<Widget>(
                                                                (String item) {
                                                          return Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minWidth:
                                                                        80),
                                                            child: Text(
                                                              item,
                                                              style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textFieldText),
                                                      value: selectedAudioMode
                                                          .value,
                                                      onChanged: (String?
                                                          Value) async {
                                                        if (Value != null) {
                                                          setState(() {
                                                            selectedAudioMode
                                                                .value = Value;
                                                          });

                                                          await ref
                                                              .read(
                                                                  sessionManagerProvider)
                                                              .saveCLAudioMode(
                                                                  selectedAudioMode
                                                                      .value);
                                                          ref.refresh(
                                                              sessionManagerProvider);
                                                        }
                                                      },
                                                      items: audioModeList
                                                          .map((String type) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: type,
                                                          child: Text(
                                                            type,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .black,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        }),
                                      ),
                                      PopupMenuItem(
                                        height: 35,
                                        value: "",
                                        padding: const EdgeInsets.only(left: 8),
                                        child: StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  LocaleKeys.text_interval.tr(),
                                                  style: TextStyle(
                                                      color: AppColors.black),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      dropdownColor:
                                                          AppColors.white,
                                                      hint: Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .textFieldHint,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 17),
                                                      ),
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        color: AppColors.black,
                                                      ),
                                                      elevation: 16,
                                                      selectedItemBuilder:
                                                          (BuildContext
                                                              context) {
                                                        return timeIntervalList
                                                            .map<Widget>(
                                                                (String item) {
                                                          return Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minWidth:
                                                                        80),
                                                            child: Text(
                                                              item,
                                                              style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textFieldText),
                                                      value:
                                                          selectedTextInterval
                                                              .value,
                                                      onChanged: (String?
                                                          Value) async {
                                                        if (Value != null) {
                                                          setState(() {
                                                            selectedTextInterval
                                                                .value = Value;
                                                          });
                                                          await ref
                                                              .read(
                                                                  sessionManagerProvider)
                                                              .saveCLTextInterval(int.parse(
                                                                  selectedTextInterval
                                                                      .value
                                                                      .replaceAll(
                                                                          "s",
                                                                          "")));
                                                          ref.refresh(
                                                              sessionManagerProvider);
                                                        }
                                                      },
                                                      items: timeIntervalList
                                                          .map((String type) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: type,
                                                          child: Text(
                                                            type,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .black,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        }),
                                      ),
                                      PopupMenuItem(
                                        height: 35,
                                        value: "",
                                        padding: const EdgeInsets.only(left: 8),
                                        child: StatefulBuilder(builder:
                                            (BuildContext context,
                                                StateSetter setState) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "ENG&CHN ${LocaleKeys.interval.tr()}",
                                                  style: TextStyle(
                                                      color: AppColors.black),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      dropdownColor:
                                                          AppColors.white,
                                                      hint: Text(
                                                        "",
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .textFieldHint,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 17),
                                                      ),
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        color: AppColors.black,
                                                      ),
                                                      elevation: 16,
                                                      selectedItemBuilder:
                                                          (BuildContext
                                                              context) {
                                                        return timeIntervalList
                                                            .map<Widget>(
                                                                (String item) {
                                                          return Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minWidth:
                                                                        80),
                                                            child: Text(
                                                              item,
                                                              style: TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .black,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .textFieldText),
                                                      value:
                                                          selectedENGCHNInterval
                                                              .value,
                                                      onChanged: (String?
                                                          Value) async {
                                                        if (Value != null) {
                                                          setState(() {
                                                            selectedENGCHNInterval
                                                                .value = Value;
                                                          });
                                                          await ref
                                                              .read(
                                                                  sessionManagerProvider)
                                                              .saveCLENGCHNInterval(int.parse(
                                                                  selectedENGCHNInterval
                                                                      .value
                                                                      .replaceAll(
                                                                          "s",
                                                                          "")));
                                                          ref.refresh(
                                                              sessionManagerProvider);
                                                        }
                                                      },
                                                      items: timeIntervalList
                                                          .map((String type) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: type,
                                                          child: Text(
                                                            type,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .black,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        }),
                                      ),
                                    ]);
                          }),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      child: list.when(data: (itemList) {
                        // newList.value = itemList;
                        List<CommonLanguageModel> list = [];
                        itemList.forEach((element) {
                          list.add(element);
                        });
                        newList.value = list;
                        if (isFirstTime.value) {
                          isFirstTime.value = false;
                          if (evaluationResult.asData?.value != null &&
                              evaluationResult.asData!.value != null) {
                            updateEvaluationResult(
                                evaluationResult.asData!.value!);
                          }
                        }
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
                                      checkSelectedList:
                                          checkSelectedList.value,
                                      uncheckSelectedList:
                                          unCheckSelectedList.value,
                                      doneTapped: () {
                                        if (unCheckSelectedList.value
                                            .contains(item)) {
                                          var list = unCheckSelectedList.value;
                                          list = list
                                              .where((element) =>
                                                  element.id != item.id)
                                              .toList();
                                          unCheckSelectedList.value = list;
                                        }
                                        checkSelectedList.value = [
                                          ...checkSelectedList.value,
                                          item
                                        ];
                                      },
                                      closeTapped: () {
                                        if (checkSelectedList.value
                                            .contains(item)) {
                                          var list = checkSelectedList.value;
                                          list = list
                                              .where((element) =>
                                                  element.id != item.id)
                                              .toList();
                                          checkSelectedList.value = list;
                                        }
                                        unCheckSelectedList.value = [
                                          ...unCheckSelectedList.value,
                                          item
                                        ];
                                      },
                                      playTapped: () async {
                                        final session =
                                            ref.watch(sessionManagerProvider);
                                        if (session.getCLAudioMode() ==
                                            AudioMode.chinese) {
                                          await audioPlayer
                                              .playAndCache(item.ch_audio);
                                        } else if (session.getCLAudioMode() ==
                                            AudioMode.english) {
                                          await audioPlayer
                                              .playAndCache(item.en_audio);
                                        } else if (session.getCLAudioMode() ==
                                            AudioMode.englishAndChinese) {
                                          await audioPlayer
                                              .playAndCache(item.en_audio);
                                          Future.delayed(Duration(
                                              seconds: session
                                                  .getCLENGCHNInterval()));
                                          await audioPlayer
                                              .playAndCache(item.ch_audio);
                                        } else if (session.getCLAudioMode() ==
                                            AudioMode.chineseAndEnglish) {
                                          await audioPlayer
                                              .playAndCache(item.ch_audio);
                                          Future.delayed(Duration(
                                              seconds: session
                                                  .getCLENGCHNInterval()));
                                          await audioPlayer
                                              .playAndCache(item.en_audio);
                                        }
                                      });
                                },
                                crossAxisCount: 1,
                              );
                      }, error: (err, trace) {
                        debugPrint(
                            "Error occurred while fetching elements:  $err");
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
                  Visibility(
                    visible: evaluationList.isNotEmpty,
                    child: CoreButton(
                      label: LocaleKeys.save.tr(),
                      loading: loading.value,
                      onPressed: () async {
                        loading.value = true;
                        for (var element in evaluationList) {
                          final res = await ref
                              .read(commonLanguageServiceProvider)
                              .updateTeacherCommonLanguageEvaluation(
                                  element.id, true);
                        }
                        List<int> ids = [];
                        List<bool> res = [];
                        checkSelectedList.value.forEach((element) {
                          ids.add(element.id);
                          res.add(true);
                        });
                        unCheckSelectedList.value.forEach((element) {
                          ids.add(element.id);
                          res.add(false);
                        });
                        if (evaluationResult.asData?.value != null &&
                            evaluationResult.asData!.value != null) {
                          await ref
                              .read(commonLanguageServiceProvider)
                              .updateEvaluation(
                                  teacher!.id,
                                  evaluationList.first.id,
                                  ids,
                                  res,
                                  evaluationResult.asData!.value!.id);
                        } else {
                          await ref
                              .read(commonLanguageServiceProvider)
                              .createEvaluation(teacher!.id,
                                  evaluationList.first.id, ids, res);
                        }
                        loading.value = false;
                        ref.refresh(
                            commonLanguageTeacherUncompletedListProvider(
                                teacher?.id ?? 0));
                        ref.refresh(getEvaluationResult(
                            evaluationList.isNotEmpty
                                ? evaluationList.first.id
                                : 0));
                        DialogHelper.showDialog(
                            LocaleKeys.updated_successfully.tr(), (p0) {
                          NavManager().goBack();
                        }, title: "");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isAudioLoading.value,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: CenterLoadingView(
                color: AppColors.mustard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommonLanguageItem extends HookConsumerWidget {
  final CommonLanguageModel languageModel;
  final VoidCallback closeTapped;
  final VoidCallback doneTapped;
  final VoidCallback playTapped;
  final List<CommonLanguageModel> checkSelectedList;
  final List<CommonLanguageModel> uncheckSelectedList;
  const _CommonLanguageItem(
      {super.key,
      required this.languageModel,
      required this.closeTapped,
      required this.doneTapped,
      required this.checkSelectedList,
      required this.uncheckSelectedList,
      required this.playTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: GestureDetector(
              onTap: playTapped,
              child: Text(
                languageModel.text,
                style: TextStyle(
                    color: AppColors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: closeTapped,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: uncheckSelectedList.contains(languageModel)
                          ? const Color(0xFF4F3422)
                          : const Color(0xFFBDB2AB),
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: doneTapped,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: checkSelectedList.contains(languageModel)
                          ? const Color(0xFF4F3422)
                          : const Color(0xFFBDB2AB),
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
