import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/data/providers/audio_player_providers.dart';
import 'package:xueli/data/providers/common_language_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/common_language_model.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';

import '../../widgets/primary_button.dart';

class CommonLanguageLearnedScreen extends HookConsumerWidget {
  const CommonLanguageLearnedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final AsyncValue<List<CommonLanguageModel>> list = ref.watch(
        commonLanguageTeacherLearnedSentencesProvider(FilterClass(
            classId: teacher?.levelId ?? 0,
            schoolId: 0,
            teacherId: teacher!.id)));
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

    Future<void> reset() async {
      // isLoopPlay.value = false;
      // isRandomPlay.value = false;
      // isPlayInOrder.value = false;
      // isPlayNames.value = false;
      // // isCallModeEnabled.value = false;
      // currentCardLoop.value = null;
      await audioPlayer.stop();
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
                        context.tr(LocaleKeys.learned_list),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
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
                                                        (BuildContext context) {
                                                      return audioModeList
                                                          .map<Widget>(
                                                              (String item) {
                                                        return Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          constraints:
                                                              const BoxConstraints(
                                                                  minWidth: 80),
                                                          child: Text(
                                                            item,
                                                            style: TextStyle(
                                                                color: AppColors
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
                                                        selectedAudioMode.value,
                                                    onChanged:
                                                        (String? Value) async {
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
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
                                                        (BuildContext context) {
                                                      return timeIntervalList
                                                          .map<Widget>(
                                                              (String item) {
                                                        return Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          constraints:
                                                              const BoxConstraints(
                                                                  minWidth: 80),
                                                          child: Text(
                                                            item,
                                                            style: TextStyle(
                                                                color: AppColors
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
                                                    value: selectedTextInterval
                                                        .value,
                                                    onChanged:
                                                        (String? Value) async {
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
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
                                                        (BuildContext context) {
                                                      return timeIntervalList
                                                          .map<Widget>(
                                                              (String item) {
                                                        return Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          constraints:
                                                              const BoxConstraints(
                                                                  minWidth: 80),
                                                          child: Text(
                                                            item,
                                                            style: TextStyle(
                                                                color: AppColors
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
                                                    onChanged:
                                                        (String? Value) async {
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
                      return itemList.isEmpty
                          ? CenterErrorView(
                              errorMsg:
                                  context.tr(LocaleKeys.no_sentence_found),
                            )
                          : MasonryGridView.count(
                              itemCount: itemList.length,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              itemBuilder: (BuildContext context, int index) {
                                final item = itemList[index];
                                return _CommonLanguageItem(
                                    languageModel: item,
                                    doneTapped: () {},
                                    closeTapped: () {},
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
                                            seconds:
                                                session.getCLENGCHNInterval()));
                                        await audioPlayer
                                            .playAndCache(item.ch_audio);
                                      } else if (session.getCLAudioMode() ==
                                          AudioMode.chineseAndEnglish) {
                                        await audioPlayer
                                            .playAndCache(item.ch_audio);
                                        Future.delayed(Duration(
                                            seconds:
                                                session.getCLENGCHNInterval()));
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
              ],
            ),
          ))
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
  const _CommonLanguageItem(
      {super.key,
      required this.languageModel,
      required this.closeTapped,
      required this.doneTapped,
      required this.playTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ButtonAnimationWidget(
      onTap: playTapped,
      child: Container(
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
            // Row(
            //   children: [
            //     GestureDetector(
            //       onTap: closeTapped,
            //       child: Container(
            //         width: 30,
            //         height: 30,
            //         decoration: BoxDecoration(
            //             color: uncheckSelectedList.contains(languageModel)
            //                 ? const Color(0xFF4F3422)
            //                 : const Color(0xFFBDB2AB),
            //             borderRadius: BorderRadius.circular(6)),
            //         child: Center(
            //           child: Icon(
            //             Icons.close,
            //             size: 18,
            //             color: AppColors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(
            //       width: 10,
            //     ),
            //     GestureDetector(
            //       onTap: doneTapped,
            //       child: Container(
            //         width: 30,
            //         height: 30,
            //         decoration: BoxDecoration(
            //             color: checkSelectedList.contains(languageModel)
            //                 ? const Color(0xFF4F3422)
            //                 : const Color(0xFFBDB2AB),
            //             borderRadius: BorderRadius.circular(6)),
            //         child: Center(
            //           child: Icon(
            //             Icons.check,
            //             size: 18,
            //             color: AppColors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
