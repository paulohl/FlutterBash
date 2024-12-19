import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/audio_player_providers.dart';
import 'package:xueli/data/providers/format_8_providers.dart';
import 'package:xueli/data/providers/special_language_providers.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/special_language.dart';
import 'package:xueli/ui/format_7/special_language/format_7_special_language.dart';
import 'package:xueli/ui/format_7/special_language/widgets/special_language_item.dart';
import 'package:xueli/ui/special_language_setting/special_language_setting_screen.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/full_screen_image.dart';

class Format8SpecialLanguage extends StatefulHookConsumerWidget {
  final int sessionId;
  final String group;
  const Format8SpecialLanguage(this.sessionId, this.group, {super.key});

  @override
  ConsumerState<Format8SpecialLanguage> createState() =>
      _Format8SpecialLanguageState();
}

class _Format8SpecialLanguageState
    extends ConsumerState<Format8SpecialLanguage> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionManagerProvider);
    final audioPlayer = ref.watch(audioPlayerOnceProvider);
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final specialItems = ref.watch(specialSessionGroupFormatLanguageProvider(
        Format8FilterClass(
            sessionId: widget.sessionId, roundId: 8, group: widget.group)));
    var audioModeList = [
      AudioMode.english,
      AudioMode.chinese,
      AudioMode.englishAndChinese,
      AudioMode.chineseAndEnglish,
    ];
    var selectedAudioMode = useState(session.getSLAudioMode());
    var timeIntervalList = ["0s", "1s", "2s", "3s"];
    var selectedTextInterval = useState("${session.getSLTextInterval()}s");
    var selectedENGCHNInterval = useState("${session.getSLENGCHNInterval()}s");
    //image show logic
    final showImage = useState(false);
    final imageLink = useState("");

    final isAudioLoading = useState(false);
    final ValueNotifier<SpecialLanguageModel?> currentCardLoop = useState(null);

    Future<void> playCardInLoop(
        SpecialLanguageModel commonLanguageModel) async {
      while (currentCardLoop.value?.id == commonLanguageModel.id) {
        if (session.getSLAudioMode() == AudioMode.english) {
          await audioPlayer.playAndCache(commonLanguageModel.en_audio);
        } else if (session.getSLAudioMode() == AudioMode.chinese) {
          await audioPlayer.playAndCache(commonLanguageModel.ch_audio);
        } else if (session.getSLAudioMode() == AudioMode.englishAndChinese) {
          await audioPlayer.playAndCache(commonLanguageModel.en_audio);
          await Future.delayed(
              Duration(seconds: session.getSLENGCHNInterval()));
          if (currentCardLoop.value?.id == commonLanguageModel.id) {
            await audioPlayer.playAndCache(commonLanguageModel.ch_audio);
          }
        } else if (session.getSLAudioMode() == AudioMode.chineseAndEnglish) {
          await audioPlayer.playAndCache(commonLanguageModel.ch_audio);
          await Future.delayed(
              Duration(seconds: session.getSLENGCHNInterval()));
          if (currentCardLoop.value?.id == commonLanguageModel.id) {
            await audioPlayer.playAndCache(commonLanguageModel.en_audio);
          }
        }
        await Future.delayed(Duration(seconds: session.getSLTextInterval()));
      }
    }

    Future<void> reset() async {
      currentCardLoop.value = null;
      await audioPlayer.stop();
    }

    //download logic
    final isDownloading = useState(false);
    final downloadedFiles = useState(0);
    final totalFiles = useState(0);

    Future<void> downloadFile(String url) async {
      DefaultCacheManager().getSingleFile(url).then((value) {
        downloadedFiles.value += 1;
        if (totalFiles.value == downloadedFiles.value) {
          isDownloading.value = false;
        }
      });
    }

    void downloadFiles(List<SpecialLanguageModel> list) {
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
    }

    ref.listen(
        specialSessionGroupFormatLanguageProvider(Format8FilterClass(
            sessionId: widget.sessionId,
            roundId: 8,
            group: widget.group)), (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadFiles(next.asData!.value);
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
      if (specialItems.asData?.value != null) {
        if (specialItems.asData!.value.isNotEmpty) {
          downloadFiles(specialItems.asData!.value);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomAppBar2(
                  //   title: LocaleKeys.special_language.tr(),
                  //   showSetting: true,
                  //   settingCallback: () {
                  //     NavManager().goTo(const SpecialLanguageSettingScreen());
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
                          LocaleKeys.special_language.tr(),
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
                                                              .saveSLAudioMode(
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
                                                              .saveSLTextInterval(int.parse(
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
                                                              .saveSLENGCHNInterval(int.parse(
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
                      child: specialItems.when(data: (items) {
                        return items.isEmpty
                            ? CenterErrorView(
                                errorMsg:
                                    context.tr(LocaleKeys.no_sentence_found),
                              )
                            : MasonryGridView.count(
                                crossAxisCount: 1,
                                itemCount: items.length,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                itemBuilder: (BuildContext context, int index) {
                                  final item = items[index];
                                  return SpecialLanguageItem(
                                    languageModel: item,
                                    closeTapped: () {},
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
                                    playTapped: () async {
                                      reset();
                                      if (session.getSLAudioMode() ==
                                          AudioMode.chinese) {
                                        await audioPlayer
                                            .playAndCache(item.ch_audio);
                                      } else if (session.getSLAudioMode() ==
                                          AudioMode.english) {
                                        await audioPlayer
                                            .playAndCache(item.en_audio);
                                      } else if (session.getSLAudioMode() ==
                                          AudioMode.englishAndChinese) {
                                        await audioPlayer
                                            .playAndCache(item.en_audio);
                                        Future.delayed(Duration(
                                            seconds:
                                                session.getSLENGCHNInterval()));
                                        await audioPlayer
                                            .playAndCache(item.ch_audio);
                                      } else if (session.getSLAudioMode() ==
                                          AudioMode.chineseAndEnglish) {
                                        await audioPlayer
                                            .playAndCache(item.ch_audio);
                                        Future.delayed(Duration(
                                            seconds:
                                                session.getSLENGCHNInterval()));
                                        await audioPlayer
                                            .playAndCache(item.en_audio);
                                      }
                                    },
                                    studentTapped: () async {
                                      reset();
                                      if (session.getSLAudioMode() ==
                                          AudioMode.chinese) {
                                        await audioPlayer
                                            .playAndCache(item.ch_std_audio);
                                      } else if (session.getSLAudioMode() ==
                                          AudioMode.english) {
                                        await audioPlayer
                                            .playAndCache(item.en_std_audio);
                                      } else if (session.getSLAudioMode() ==
                                          AudioMode.englishAndChinese) {
                                        await audioPlayer
                                            .playAndCache(item.en_std_audio);
                                        Future.delayed(Duration(
                                            seconds:
                                                session.getSLENGCHNInterval()));
                                        await audioPlayer
                                            .playAndCache(item.ch_std_audio);
                                      } else if (session.getSLAudioMode() ==
                                          AudioMode.chineseAndEnglish) {
                                        await audioPlayer
                                            .playAndCache(item.ch_std_audio);
                                        Future.delayed(Duration(
                                            seconds:
                                                session.getSLENGCHNInterval()));
                                        await audioPlayer
                                            .playAndCache(item.en_std_audio);
                                      }
                                    },
                                    actionTapped: () async {
                                      reset();
                                      if (item.action_ch_audio.isNotEmpty &&
                                          item.action_en_audio.isNotEmpty) {
                                        imageLink.value = item.ad_image;
                                        showImage.value = true;
                                        if (session.getSLAudioMode() ==
                                            AudioMode.english) {
                                          await audioPlayer.playAndCache(
                                              item.action_en_audio);
                                        } else if (session.getSLAudioMode() ==
                                            AudioMode.chinese) {
                                          await audioPlayer.playAndCache(
                                              item.action_ch_audio);
                                        } else if (session.getSLAudioMode() ==
                                            AudioMode.englishAndChinese) {
                                          await audioPlayer.playAndCache(
                                              item.action_en_audio);
                                          await Future.delayed(Duration(
                                              seconds: session
                                                  .getSLENGCHNInterval()));
                                          await audioPlayer.playAndCache(
                                              item.action_ch_audio);
                                        } else if (session.getSLAudioMode() ==
                                            AudioMode.chineseAndEnglish) {
                                          await audioPlayer.playAndCache(
                                              item.action_ch_audio);
                                          await Future.delayed(Duration(
                                              seconds: session
                                                  .getSLENGCHNInterval()));
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
                                        imageLink.value = item.ad_image;
                                        showImage.value = true;
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
                                        imageLink.value = item.ad_image;
                                        showImage.value = true;
                                        if (session.getSLAudioMode() ==
                                            AudioMode.english) {
                                          await audioPlayer
                                              .playAndCache(item.ad_en_audio);
                                        } else if (session.getSLAudioMode() ==
                                            AudioMode.chinese) {
                                          await audioPlayer
                                              .playAndCache(item.ad_ch_audio);
                                        } else if (session.getSLAudioMode() ==
                                            AudioMode.englishAndChinese) {
                                          await audioPlayer
                                              .playAndCache(item.ad_en_audio);
                                          await Future.delayed(Duration(
                                              seconds: session
                                                  .getSLENGCHNInterval()));
                                          await audioPlayer
                                              .playAndCache(item.ad_ch_audio);
                                        } else if (session.getSLAudioMode() ==
                                            AudioMode.chineseAndEnglish) {
                                          await audioPlayer
                                              .playAndCache(item.ad_ch_audio);
                                          await Future.delayed(Duration(
                                              seconds: session
                                                  .getSLENGCHNInterval()));
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

class _SelectionItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback callback;
  const _SelectionItem(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightBlue
              : AppColors.lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.lightBlue.withOpacity(0.4), width: 0.5),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.lightBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
