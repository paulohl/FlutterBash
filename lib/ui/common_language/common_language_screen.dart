import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/audio_player_providers.dart';
import 'package:xueli/data/providers/call_mode_providers.dart';
import 'package:xueli/data/providers/common_language_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/common_language_service.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/call_mode_model.dart';
import 'package:xueli/models/common_language_category_model.dart';
import 'package:xueli/models/common_language_model.dart';
import 'package:xueli/models/student_model.dart';
import 'package:xueli/ui/common_language/evaluation/common_language_evaluation_screen.dart';
import 'package:xueli/ui/common_language/learned/common_language_learned_screen.dart';
import 'package:xueli/ui/format_7/special_language/format_7_special_language.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/full_screen_image.dart';
import 'package:xueli/ui/widgets/primary_button.dart';
import 'package:collection/collection.dart';

class CommonLanguageScreen extends HookConsumerWidget {
  const CommonLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final teacher = session.getTeacherProfile();
    final list = ref.watch(commonLanguageTodayProvider(teacher?.id ?? 0));
    final students = ref.watch(classStudentsProvider(FilterClass(
        classId: teacher!.classId,
        schoolId: teacher.schoolId,
        teacherId: teacher.id)));
    final allCallModes = ref.watch(callModeProvider(teacher.levelId));
    final audioPlayer = ref.watch(commonAudioPlayerOnceProvider);
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
    final isAudioLoading = useState(false);
    //image show logic
    final showImage = useState(false);
    final imageLink = useState("");

    //download logic
    final isDownloading = useState(false);
    final downloadedFiles = useState(0);
    final totalFiles = useState(0);
    final isCardDownloaded = useState(false);
    final isNamesDownloaded = useState(false);
    final isCallModeDownloaded = useState(false);

    Future<void> downloadFile(String url) async {
      DefaultCacheManager().getSingleFile(url).then((value) {
        downloadedFiles.value += 1;
        if (isCallModeDownloaded.value &&
            isNamesDownloaded.value &&
            isCardDownloaded.value) {
          if (totalFiles.value == downloadedFiles.value) {
            isDownloading.value = false;
          }
        }
      });
    }

    void downloadFiles(List<CommonLanguageModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.ch_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.ch_audio);
        }
        if (element.en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.en_audio);
        }
        if (element.ch_std_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.ch_std_audio);
        }
        if (element.en_std_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.en_std_audio);
        }
        if (element.ad_en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.ad_en_audio);
        }
        if (element.ad_ch_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.ad_ch_audio);
        }
        if (element.action_en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.action_en_audio);
        }
        if (element.action_ch_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.action_ch_audio);
        }
      });
      isCardDownloaded.value = true;
    }

    void downloadNames(List<StudentModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.englishNameModel != null &&
            element.englishNameModel!.audioLink.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.englishNameModel!.audioLink);
        }
      });
      isNamesDownloaded.value = true;
    }

    void downloadCallMode(List<CallModeModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.audio_link.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.audio_link);
        }
      });
      isCallModeDownloaded.value = true;
    }

    ref.listen(commonLanguageTodayProvider(teacher?.id ?? 0), (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadFiles(next.asData!.value);
        } else {
          isCardDownloaded.value = true;
        }
      }
    });
    ref.listen(
        classStudentsProvider(FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0)), (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadNames(next.asData!.value);
        } else {
          isNamesDownloaded.value = true;
        }
      }
    });
    ref.listen(callModeProvider(teacher.levelId), (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadCallMode(next.asData!.value);
        } else {
          isCallModeDownloaded.value = true;
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
      if (list.asData?.value != null) {
        if (list.asData!.value.isNotEmpty) {
          downloadFiles(list.asData!.value);
        } else {
          isCardDownloaded.value = true;
        }
      }
      if (allCallModes.asData?.value != null) {
        if (allCallModes.asData?.value != null) {
          if (allCallModes.asData!.value.isNotEmpty) {
            downloadCallMode(allCallModes.asData!.value);
          } else {
            isCallModeDownloaded.value = true;
          }
        }
      }
      if (students.asData?.value != null) {
        if (students.asData?.value != null) {
          if (students.asData!.value.isNotEmpty) {
            downloadNames(students.asData!.value);
          } else {
            isNamesDownloaded.value = true;
          }
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
                  // CustomAppBar2(
                  //   title: context.tr(LocaleKeys.common_language),
                  //   showSetting: true,
                  //   settingCallback: () {
                  //     NavManager().goTo(const CommonLanguageSettingScreen());
                  //   },
                  // ),
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
                          LocaleKeys.common_language.tr(),
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
                    child: CommonLanguageWidget(
                      imageCallback: (String value) {
                        imageLink.value = value;
                        showImage.value = true;
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
          Visibility(
            visible: isDownloading.value,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr(LocaleKeys.downloading_audio_files),
                          style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        CenterLoadingView(
                          color: AppColors.mustard,
                          size: 35,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr(LocaleKeys.downloaded_files),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${downloadedFiles.value}/${totalFiles.value}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: showImage.value && imageLink.value.isNotEmpty,
            child: ImageView(
              imageUrl: imageLink.value,
              callback: () {
                showImage.value = false;
                imageLink.value = "";
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommonLanguageWidget extends HookConsumerWidget {
  final ValueSetter<String> imageCallback;
  const CommonLanguageWidget({super.key, required this.imageCallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final audioPlayer = ref.watch(commonAudioPlayerOnceProvider);
    final selectedType = useState(1);
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final evaluationList = ref
            .watch(commonLanguageTeacherEvaluationListProvider(teacher!.id))
            .asData
            ?.value ??
        [];
    final currentCallModeList =
        ref.watch(getCurrentCallModeProvider(teacher!.levelId)).asData?.value;

    final firstTime = useState(true);
    final ValueNotifier<List<int>> ids = useState([]);
    final ValueNotifier<CommonLanguageCategoryModel> selectedCategory =
        useState(CommonLanguageCategoryModel(
            id: 0, name: "All", level_id: teacher.levelId));
    final categoriesList = ref.watch(commonLanguageSentenceCategoriesProvider(
        CommonFilterClass(levelId: teacher.levelId, ids: ids.value)));

    final studentList = ref.watch(classStudentsProvider(FilterClass(
        classId: teacher?.classId ?? 0,
        schoolId: teacher?.schoolId ?? 0,
        teacherId: teacher?.id ?? 0)));
    final list = ref.watch(commonLanguageTodayWithCategoryProvider(
        CommonFilterClass(
            levelId: teacher!.id ?? 0,
            ids: [],
            categoryID: selectedCategory.value.id)));
    final listRepeat =
        ref.watch(commonLanguageRepeatTodayProvider(teacher?.id ?? 0));
    Future<void> addRepeat(CommonLanguageModel model) async {
      if (listRepeat.asData?.value != null) {
        var list1 = listRepeat.asData!.value;
        final item =
            list1.firstWhereOrNull((element) => element.common_id == model.id);
        if (item != null) {
          await ref
              .read(commonLanguageServiceProvider)
              .updateTeacherCommonLanguageRepeatHistory(
                  teacher!.id, model.id, item.played + 1, item.id);
          ref.refresh(commonLanguageRepeatTodayProvider(teacher?.id ?? 0));
        } else {
          await ref
              .read(commonLanguageServiceProvider)
              .createTeacherCommonLanguageRepeatHistory(teacher!.id, model.id);
          ref.refresh(commonLanguageRepeatTodayProvider(teacher?.id ?? 0));
        }
      }
    }

    //Audio Play Logic
    final showNames = useState(false);
    final isLoopPlay = useState(false);
    final isRandomPlay = useState(false);
    final isPlayInOrder = useState(false);
    final isPlayNames = useState(false);
    final isCallModeEnabled = useState(false);
    final ValueNotifier<CommonLanguageModel?> currentCardLoop = useState(null);
    final ValueNotifier<CommonLanguageModel?> selectedCard = useState(null);
    final ValueNotifier<StudentModel?> selectedUser = useState(null);

    Future<void> reset() async {
      isLoopPlay.value = false;
      isRandomPlay.value = false;
      isPlayInOrder.value = false;
      isPlayNames.value = false;
      // isCallModeEnabled.value = false;
      currentCardLoop.value = null;
      selectedUser.value = null;
      selectedCard.value = null;
      await audioPlayer.stop();
    }

    Future<void> playLoop(bool isIndOrder) async {
      if (isIndOrder) {
        var commonList = list.asData?.value ?? [];
        for (var item in commonList) {
          if (!isLoopPlay.value) {
            selectedCard.value = null;
            return;
          }
          selectedCard.value = item;
          if (session.getCLAudioMode() == AudioMode.englishAndChinese) {
            await audioPlayer.playAndCache(item.en_audio);
            await Future.delayed(
                Duration(seconds: session.getCLENGCHNInterval()));
            if (!isLoopPlay.value) {
              selectedCard.value = null;
              return;
            }
            await audioPlayer.playAndCache(item.ch_audio);
          } else if (session.getCLAudioMode() == AudioMode.chineseAndEnglish) {
            await audioPlayer.playAndCache(item.ch_audio);
            await Future.delayed(
                Duration(seconds: session.getCLENGCHNInterval()));
            if (!isLoopPlay.value) {
              selectedCard.value = null;
              return;
            }
            await audioPlayer.playAndCache(item.en_audio);
          } else if (session.getCLAudioMode() == AudioMode.english) {
            await audioPlayer.playAndCache(item.en_audio);
          } else if (session.getCLAudioMode() == AudioMode.chinese) {
            await audioPlayer.playAndCache(item.ch_audio);
          }
          await Future.delayed(Duration(seconds: session.getCLTextInterval()));
        }
        if (isLoopPlay.value) {
          playLoop(true);
        }
      } else {
        final data = list.asData?.value ?? [];
        final commonList = [...data];
        if (commonList.isNotEmpty) {
          while (isLoopPlay.value && commonList.isNotEmpty) {
            var index = Random().nextInt(commonList.length);
            var item = commonList[index];
            commonList.removeAt(index);
            selectedCard.value = item;
            if (session.getCLAudioMode() == AudioMode.englishAndChinese) {
              await audioPlayer.playAndCache(item.en_audio);
              await Future.delayed(
                  Duration(seconds: session.getCLENGCHNInterval()));
              if (!isLoopPlay.value) {
                selectedCard.value = null;
                return;
              }
              await audioPlayer.playAndCache(item.ch_audio);
            } else if (session.getCLAudioMode() ==
                AudioMode.chineseAndEnglish) {
              await audioPlayer.playAndCache(item.ch_audio);
              await Future.delayed(
                  Duration(seconds: session.getCLENGCHNInterval()));
              if (!isLoopPlay.value) {
                selectedCard.value = null;
                return;
              }
              await audioPlayer.playAndCache(item.en_audio);
            } else if (session.getCLAudioMode() == AudioMode.english) {
              await audioPlayer.playAndCache(item.en_audio);
            } else if (session.getCLAudioMode() == AudioMode.chinese) {
              await audioPlayer.playAndCache(item.ch_audio);
            }
            await Future.delayed(
                Duration(seconds: session.getCLTextInterval()));
          }
          if (isLoopPlay.value) {
            playLoop(false);
          }
        }
      }
    }

    Future<void> playRandom() async {
      final data = list.asData?.value ?? [];
      final commonList = [...data];
      if (commonList.isNotEmpty) {
        while (isRandomPlay.value && commonList.isNotEmpty) {
          var index = Random().nextInt(commonList.length);
          var item = commonList[index];
          commonList.removeAt(index);
          selectedCard.value = item;
          if (session.getCLAudioMode() == AudioMode.englishAndChinese) {
            await audioPlayer.playAndCache(item.en_audio);
            await Future.delayed(
                Duration(seconds: session.getCLENGCHNInterval()));
            if (!isRandomPlay.value) {
              selectedCard.value = null;
              return;
            }
            await audioPlayer.playAndCache(item.ch_audio);
          } else if (session.getCLAudioMode() == AudioMode.chineseAndEnglish) {
            await audioPlayer.playAndCache(item.ch_audio);
            await Future.delayed(
                Duration(seconds: session.getCLENGCHNInterval()));
            if (!isRandomPlay.value) {
              selectedCard.value = null;
              return;
            }
            await audioPlayer.playAndCache(item.en_audio);
          } else if (session.getCLAudioMode() == AudioMode.english) {
            await audioPlayer.playAndCache(item.en_audio);
          } else if (session.getCLAudioMode() == AudioMode.chinese) {
            await audioPlayer.playAndCache(item.ch_audio);
          }
          await Future.delayed(Duration(seconds: session.getCLTextInterval()));
        }
        selectedCard.value = null;
        if (commonList.isEmpty && isRandomPlay.value) {
          reset();
        }
      }
    }

    Future<void> playInOrder() async {
      var commonList = list.asData?.value ?? [];
      for (var item in commonList) {
        if (!isPlayInOrder.value) {
          selectedCard.value = null;
          return;
        }
        selectedCard.value = item;
        if (session.getCLAudioMode() == AudioMode.englishAndChinese) {
          await audioPlayer.playAndCache(item.en_audio);
          await Future.delayed(
              Duration(seconds: session.getCLENGCHNInterval()));
          if (!isPlayInOrder.value) {
            selectedCard.value = null;
            return;
          }
          await audioPlayer.playAndCache(item.ch_audio);
        } else if (session.getCLAudioMode() == AudioMode.chineseAndEnglish) {
          await audioPlayer.playAndCache(item.ch_audio);
          await Future.delayed(
              Duration(seconds: session.getCLENGCHNInterval()));
          if (!isPlayInOrder.value) {
            selectedCard.value = null;
            return;
          }
          await audioPlayer.playAndCache(item.en_audio);
        } else if (session.getCLAudioMode() == AudioMode.english) {
          await audioPlayer.playAndCache(item.en_audio);
        } else if (session.getCLAudioMode() == AudioMode.chinese) {
          await audioPlayer.playAndCache(item.ch_audio);
        }
        await Future.delayed(Duration(seconds: session.getCLTextInterval()));
      }
      selectedCard.value = null;
      if (isPlayInOrder.value) {
        reset();
      }
      // if (isPlayInOrder.value) {
      //   playInOrder();
      // }
    }

    Future<void> playNames(bool isIndOrder) async {
      if (isIndOrder) {
        var student = studentList.asData?.value ?? [];
        for (var item in student.indexed) {
          if (item.$2.englishNameModel != null) {
            if (!isPlayNames.value) {
              selectedUser.value = null;
              return;
            }
            selectedUser.value = item.$2;
            await audioPlayer.playAndCache(item.$2.englishNameModel!.audioLink);
            await Future.delayed(
                Duration(seconds: session.getCLTextInterval()));
          }
        }
        selectedUser.value = null;
        if (isPlayNames.value) {
          reset();
        }
        // if (isPlayNames.value) {
        //   playNames(true);
        // }
      } else {
        var data = studentList.asData?.value ?? [];
        var student = [...data];
        if (student.isNotEmpty) {
          while (isPlayNames.value && student.isNotEmpty) {
            var index = Random().nextInt(student.length);
            var element = student[index];
            student.removeAt(index);
            if (element.englishNameModel != null) {
              selectedUser.value = element;
              await audioPlayer
                  .playAndCache(element.englishNameModel!.audioLink);
              await Future.delayed(
                  Duration(seconds: session.getCLTextInterval()));
            }
          }
          selectedUser.value = null;
          if (student.isEmpty && isPlayNames.value) {
            reset();
          }
        } else {
          reset();
        }
      }
    }

    Future<void> playCardInLoop(CommonLanguageModel commonLanguageModel) async {
      while (currentCardLoop.value?.id == commonLanguageModel.id) {
        if (session.getCLAudioMode() == AudioMode.english) {
          await audioPlayer.playAndCache(commonLanguageModel.en_audio);
        } else if (session.getCLAudioMode() == AudioMode.chinese) {
          await audioPlayer.playAndCache(commonLanguageModel.ch_audio);
        } else if (session.getCLAudioMode() == AudioMode.englishAndChinese) {
          await audioPlayer.playAndCache(commonLanguageModel.en_audio);
          await Future.delayed(
              Duration(seconds: session.getCLENGCHNInterval()));
          if (currentCardLoop.value?.id == commonLanguageModel.id) {
            await audioPlayer.playAndCache(commonLanguageModel.ch_audio);
          }
        } else if (session.getCLAudioMode() == AudioMode.chineseAndEnglish) {
          await audioPlayer.playAndCache(commonLanguageModel.ch_audio);
          await Future.delayed(
              Duration(seconds: session.getCLENGCHNInterval()));
          if (currentCardLoop.value?.id == commonLanguageModel.id) {
            await audioPlayer.playAndCache(commonLanguageModel.en_audio);
          }
        }
        await Future.delayed(Duration(seconds: session.getCLTextInterval()));
      }
    }

    Future<void> updateCallModeCount() async {
      var count = teacher!.format_s_call_mode + 1;
      await ref
          .read(teacherServiceProvider)
          .updateTeacherFormat7CallMode(count, teacher.id);
      await ref
          .read(teacherServiceProvider)
          .getTeacherProfile(Supabase.instance.client.auth.currentUser!.id);
      ref.refresh(sessionManagerProvider);
    }

    return FocusDetector(
      onFocusLost: () {
        reset();
      },
      onFocusGained: () {},
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              ImageButton(
                  btnSize: 30,
                  iconSize: 24,
                  image: Assets.imagesLearned,
                  callback: () {
                    NavManager().goTo(const CommonLanguageLearnedScreen());
                  }),
              const SizedBox(
                width: 5,
              ),
              TopItem(
                  image: Assets.imagesIcons8LanguageSkill,
                  title: context.tr(LocaleKeys.student_list),
                  callback: () {
                    showNames.value = !showNames.value;
                  }),
              const SizedBox(
                width: 5,
              ),
              TopItem(
                  notify: evaluationList.isNotEmpty ? true : false,
                  image: Assets.imagesIcons8Language,
                  title: context.tr(LocaleKeys.evaluation),
                  callback: () {
                    NavManager().goTo(const CommonLanguageEvaluationScreen());
                  }),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 40,
            child: Container(
              child: categoriesList.when(data: (items) {
                return items.isEmpty
                    ? CenterErrorView(
                        errorMsg: context.tr(LocaleKeys.no_sentence_found),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        primary: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = items[index];
                          return CategoryItem(
                              model: item,
                              callback: () {
                                selectedCategory.value = item;
                              },
                              isSelected: selectedCategory.value.id == item.id);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            width: 15,
                          );
                        },
                      );
              }, error: (err, trace) {
                debugPrint(
                    "Error occurred while fetching elements: $err, $trace");
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
            height: 15,
          ),
          Row(
            children: [
              Visibility(
                visible: showNames.value,
                child: Row(
                  children: [
                    MenuItem1(
                        isPlaying: isPlayNames.value,
                        image: isPlayNames.value
                            ? Assets.imagesStop
                            : Assets.imagesName,
                        title: LocaleKeys.play_name.tr(),
                        title1: LocaleKeys.play_in_order.tr(),
                        title2: LocaleKeys.random_play.tr(),
                        callback: (String val) {
                          reset();
                          if (val == "1") {
                            isPlayNames.value = true;
                            playNames(true);
                          } else if (val == "2") {
                            isPlayNames.value = true;
                            playNames(false);
                          } else {
                            reset();
                          }
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    ImageButtonItem(
                        image: isCallModeEnabled.value
                            ? Assets.imagesCallmode
                            : Assets.imagesCallMode,
                        title: isCallModeEnabled.value
                            ? LocaleKeys.stop.tr()
                            : LocaleKeys.call_mode.tr(),
                        callback: () {
                          isCallModeEnabled.value = !isCallModeEnabled.value;
                        }),
                  ],
                ),
              ),
              const Spacer(),
              MenuItem(
                  isPlaying: isLoopPlay.value,
                  image:
                      isLoopPlay.value ? Assets.imagesStop : Assets.imagesLoop,
                  title: LocaleKeys.loop_play.tr(),
                  title1: LocaleKeys.loop_in_order.tr(),
                  title2: LocaleKeys.loop_randomly.tr(),
                  callback: (String val) {
                    reset();
                    if (val == "1") {
                      isLoopPlay.value = true;
                      playLoop(true);
                    } else if (val == "2") {
                      isLoopPlay.value = true;
                      playLoop(false);
                    } else {
                      reset();
                    }
                  }),
              const SizedBox(
                width: 5,
              ),
              ImageTextItem(
                  isPlaying: isRandomPlay.value,
                  image: isRandomPlay.value
                      ? Assets.imagesStop
                      : Assets.imagesShuffle,
                  title: LocaleKeys.random_play.tr(),
                  callback: () {
                    if (isRandomPlay.value) {
                      reset();
                    } else {
                      reset();
                      isRandomPlay.value = true;
                      playRandom();
                    }
                  }),
              const SizedBox(
                width: 5,
              ),
              ImageTextItem(
                  isPlaying: isPlayInOrder.value,
                  image: isPlayInOrder.value
                      ? Assets.imagesStop
                      : Assets.imagesName,
                  title: LocaleKeys.play_in_order.tr(),
                  callback: () {
                    if (isPlayInOrder.value) {
                      reset();
                    } else {
                      reset();
                      isPlayInOrder.value = true;
                      playInOrder();
                    }
                  }),
              const Spacer(),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: showNames.value,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Container(
                              child: studentList.when(data: (items) {
                                return items.isEmpty
                                    ? CenterErrorView(
                                        errorMsg: context
                                            .tr(LocaleKeys.no_sentence_found),
                                      )
                                    : MasonryGridView.count(
                                        primary: false,
                                        shrinkWrap: true,
                                        crossAxisCount: 1,
                                        itemCount: items.length,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final item = items[index];
                                          return _StudentItem(
                                              studentModel: item,
                                              isSelected:
                                                  selectedUser.value == item,
                                              nameTapped: () async {
                                                reset();
                                                if (isCallModeEnabled.value) {
                                                  if (currentCallModeList !=
                                                          null &&
                                                      currentCallModeList
                                                          .isAudioBeforeName) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            currentCallModeList
                                                                .audio_link);
                                                  }
                                                }
                                                if (item.englishNameModel !=
                                                    null) {
                                                  await audioPlayer
                                                      .playAndCache(item
                                                          .englishNameModel!
                                                          .audioLink);
                                                }
                                                if (isCallModeEnabled.value) {
                                                  if (currentCallModeList !=
                                                          null &&
                                                      !currentCallModeList
                                                          .isAudioBeforeName) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            currentCallModeList
                                                                .audio_link);
                                                  }
                                                }
                                                if (isCallModeEnabled.value) {
                                                  updateCallModeCount();
                                                }
                                              });
                                        },
                                      );
                              }, error: (err, trace) {
                                debugPrint(
                                    "Error occurred while fetching elements: $err, $trace");
                                return CenterErrorView(
                                  errorMsg: context
                                      .tr(LocaleKeys.error_fetching_element),
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
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: list.when(data: (items) {
                          if (firstTime.value) {
                            firstTime.value = false;
                            List<int> id = [];
                            items.forEach((element) {
                              id.add(element.category_id);
                            });
                            ids.value = id;
                          }
                          return items.isEmpty
                              ? CenterErrorView(
                                  errorMsg:
                                      context.tr(LocaleKeys.no_sentence_found),
                                )
                              : MasonryGridView.count(
                                  primary: false,
                                  shrinkWrap: true,
                                  crossAxisCount: 1,
                                  itemCount: items.length,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final item = items[index];
                                    return _CommonLanguageItem(
                                      languageModel: item,
                                      isSelected: selectedCard.value == item,
                                      isLoop:
                                          currentCardLoop.value?.id == item.id,
                                      cardLoopTapped: () {
                                        if (currentCardLoop.value?.id !=
                                            item.id) {
                                          reset();
                                          currentCardLoop.value = item;
                                          playCardInLoop(item);
                                        } else {
                                          reset();
                                        }
                                      },
                                      closeTapped: () {
                                        reset();
                                        DialogHelper.showConfirmationDialog(
                                            LocaleKeys.delete_msg.tr(),
                                            (p0) async {
                                          if (p0) {
                                            await ref
                                                .read(
                                                    commonLanguageServiceProvider)
                                                .deleteSentenceFromTodayLoginDate(
                                                    teacher!.id,
                                                    items,
                                                    item.id);
                                            ref.refresh(
                                                commonLanguageTodayProvider(
                                                    teacher?.id ?? 0));
                                          }
                                        });
                                      },
                                      playTapped: () async {
                                        reset();
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
                                        addRepeat(item);
                                      },
                                      studentTapped: () async {
                                        reset();
                                        final session =
                                            ref.watch(sessionManagerProvider);
                                        if (session.getCLAudioMode() ==
                                            AudioMode.chinese) {
                                          await audioPlayer
                                              .playAndCache(item.ch_std_audio);
                                        } else if (session.getCLAudioMode() ==
                                            AudioMode.english) {
                                          await audioPlayer
                                              .playAndCache(item.en_std_audio);
                                        } else if (session.getCLAudioMode() ==
                                            AudioMode.englishAndChinese) {
                                          await audioPlayer
                                              .playAndCache(item.en_std_audio);
                                          Future.delayed(Duration(
                                              seconds: session
                                                  .getCLENGCHNInterval()));
                                          await audioPlayer
                                              .playAndCache(item.ch_std_audio);
                                        } else if (session.getCLAudioMode() ==
                                            AudioMode.chineseAndEnglish) {
                                          await audioPlayer
                                              .playAndCache(item.ch_std_audio);
                                          Future.delayed(Duration(
                                              seconds: session
                                                  .getCLENGCHNInterval()));
                                          await audioPlayer
                                              .playAndCache(item.en_std_audio);
                                        }
                                      },
                                      actionTapped: () async {
                                        reset();
                                        if (item.action_ch_audio.isNotEmpty &&
                                            item.action_en_audio.isNotEmpty) {
                                          imageCallback(item.ad_image);
                                          if (session.getCLAudioMode() ==
                                              AudioMode.english) {
                                            await audioPlayer.playAndCache(
                                                item.action_en_audio);
                                          } else if (session.getCLAudioMode() ==
                                              AudioMode.chinese) {
                                            await audioPlayer.playAndCache(
                                                item.action_ch_audio);
                                          } else if (session.getCLAudioMode() ==
                                              AudioMode.englishAndChinese) {
                                            await audioPlayer.playAndCache(
                                                item.action_en_audio);
                                            await Future.delayed(Duration(
                                                seconds: session
                                                    .getCLENGCHNInterval()));
                                            await audioPlayer.playAndCache(
                                                item.action_ch_audio);
                                          } else if (session.getCLAudioMode() ==
                                              AudioMode.chineseAndEnglish) {
                                            await audioPlayer.playAndCache(
                                                item.action_ch_audio);
                                            await Future.delayed(Duration(
                                                seconds: session
                                                    .getCLENGCHNInterval()));
                                            await audioPlayer.playAndCache(
                                                item.action_en_audio);
                                          }
                                        } else {
                                          DialogHelper.showError(context
                                              .tr(LocaleKeys.no_audio_found));
                                        }
                                      },
                                      imageTapped: () {
                                        // reset();
                                        if (item.ad_image.isNotEmpty) {
                                          imageCallback(item.ad_image);
                                          // NavManager().goTo(FullScreenImage(
                                          //     imageUrl: item.ad_image));
                                        } else {
                                          DialogHelper.showError(context
                                              .tr(LocaleKeys.no_image_found));
                                        }
                                      },
                                      descriptionTapped: () async {
                                        reset();
                                        if (item.ad_en_audio.isNotEmpty &&
                                            item.ad_ch_audio.isNotEmpty) {
                                          imageCallback(item.ad_image);
                                          if (session.getCLAudioMode() ==
                                              AudioMode.english) {
                                            await audioPlayer
                                                .playAndCache(item.ad_en_audio);
                                          } else if (session.getCLAudioMode() ==
                                              AudioMode.chinese) {
                                            await audioPlayer
                                                .playAndCache(item.ad_ch_audio);
                                          } else if (session.getCLAudioMode() ==
                                              AudioMode.englishAndChinese) {
                                            await audioPlayer
                                                .playAndCache(item.ad_en_audio);
                                            await Future.delayed(Duration(
                                                seconds: session
                                                    .getCLENGCHNInterval()));
                                            await audioPlayer
                                                .playAndCache(item.ad_ch_audio);
                                          } else if (session.getCLAudioMode() ==
                                              AudioMode.chineseAndEnglish) {
                                            await audioPlayer
                                                .playAndCache(item.ad_ch_audio);
                                            await Future.delayed(Duration(
                                                seconds: session
                                                    .getCLENGCHNInterval()));
                                            await audioPlayer
                                                .playAndCache(item.ad_en_audio);
                                          }
                                        } else {
                                          DialogHelper.showError(context
                                              .tr(LocaleKeys.no_audio_found));
                                        }
                                      },
                                    );
                                  },
                                );
                        }, error: (err, trace) {
                          debugPrint(
                              "Error occurred while fetching elements: $err, $trace");
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommonLanguageItem extends StatelessWidget {
  final CommonLanguageModel languageModel;
  final VoidCallback closeTapped;
  final VoidCallback playTapped;
  final VoidCallback studentTapped;
  final VoidCallback imageTapped;
  final VoidCallback actionTapped;
  final VoidCallback descriptionTapped;
  final VoidCallback cardLoopTapped;
  final bool isLoop;
  final bool isSelected;
  const _CommonLanguageItem(
      {super.key,
      required this.languageModel,
      required this.closeTapped,
      required this.playTapped,
      required this.studentTapped,
      required this.imageTapped,
      required this.descriptionTapped,
      required this.cardLoopTapped,
      required this.isLoop,
      required this.isSelected,
      required this.actionTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        // height: 125,
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.brown)),
        child: Column(
          children: [
            ButtonAnimationWidget(
              onTap: playTapped,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.yellow : AppColors.white,
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
                        style: TextStyle(color: AppColors.brown),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    ImageButton(
                        image: isLoop ? Assets.imagesStop : Assets.imagesLoop,
                        bg: AppColors.white,
                        btnSize: 34,
                        iconSize: 22,
                        callback: cardLoopTapped),
                    const SizedBox(
                      width: 5,
                    ),
                    ImageButton(
                        image: Assets.imagesDelete,
                        bg: AppColors.white,
                        btnSize: 34,
                        iconSize: 22,
                        callback: closeTapped),
                    const SizedBox(
                      width: 5,
                    ),
                    ImageButton(
                        image: Assets.imagesStudent,
                        bg: AppColors.white,
                        btnSize: 34,
                        iconSize: 22,
                        callback: studentTapped),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: languageModel.ad_text.isNotEmpty ||
                  languageModel.action_text.isNotEmpty,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Visibility(
                        visible: languageModel.action_text.isNotEmpty,
                        child: ButtonAnimationWidget(
                          onTap: actionTapped,
                          child: Container(
                            height: 45,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(color: AppColors.brown),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(
                                      0, 4), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                languageModel.action_text,
                                style: TextStyle(
                                    color: AppColors.brown, fontSize: 12),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Visibility(
                          visible: languageModel.ad_text.isNotEmpty,
                          child: ButtonAnimationWidget(
                            onTap: descriptionTapped,
                            child: Container(
                              height: 45,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(23),
                                border: Border.all(color: AppColors.brown),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(
                                        0, 4), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      languageModel.ad_text,
                                      style: TextStyle(
                                          color: AppColors.brown, fontSize: 12),
                                      maxLines: 2,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                  ImageButton(
                                      image: Assets.imagesGallery,
                                      bg: AppColors.white,
                                      btnSize: 34,
                                      iconSize: 22,
                                      callback: imageTapped),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class _StudentItem extends StatelessWidget {
  final StudentModel studentModel;
  final VoidCallback nameTapped;
  final bool isSelected;
  const _StudentItem(
      {super.key,
      required this.studentModel,
      required this.nameTapped,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: nameTapped,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : AppColors.white,
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                studentModel.englishNameModel?.name ?? "",
                style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
              // Text(" • ", style: TextStyle(color: AppColors.black)),
              Text(
                studentModel.name,
                style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CommonLanguageCategoryModel model;
  final VoidCallback callback;
  final bool isSelected;
  const CategoryItem(
      {super.key,
      required this.model,
      required this.callback,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Center(
        child: Text(
          model.name,
          style: TextStyle(
              color: isSelected ? AppColors.brown : const Color(0xFFBDB2AB),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
