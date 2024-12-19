import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/audio_player_providers.dart';
import 'package:xueli/data/providers/call_mode_providers.dart';
import 'package:xueli/data/providers/format7_providers.dart';
import 'package:xueli/data/providers/special_language_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/call_mode_model.dart';
import 'package:xueli/models/card_model.dart';
import 'package:xueli/models/special_language.dart';
import 'package:xueli/models/student_model.dart';
import 'package:xueli/ui/common_language/common_language_screen.dart';
import 'package:xueli/ui/format_7/sort_students/sort_students_screen.dart';
import 'package:xueli/ui/format_7/special_language/format_7_special_language.dart';
import 'package:xueli/ui/format_setting/format_setting_screen.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/full_screen_image.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

import 'special_language/widgets/special_language_item.dart';

class Format7Screen extends HookConsumerWidget {
  const Format7Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final allCallModes = ref.watch(callModeProvider(teacher!.levelId));
    final currentCallModeList =
        ref.watch(getCurrentCallModeProvider(teacher!.levelId)).asData?.value;
    final studentList = ref.watch(classStudentsFormat7SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0)));
    final cards = ref.watch(levelCardSessionSortedProvider(FilterClass(
        classId: teacher?.formatSevenSession ?? 1,
        schoolId: teacher?.levelId ?? 0)));

    ///Special Language
    final specialLanguage =
        ref.watch(specialFormat7LanguageProvider(teacher.formatSevenSession));
    final isSpecialLanguageShown = useState(false);

    final isAudioLoading = useState(false);
    var audioModeList = [
      AudioMode.english,
      AudioMode.chinese,
      AudioMode.englishAndChinese,
      AudioMode.chineseAndEnglish,
    ];
    var selectedAudioMode = useState(session.getFormatAudioMode());
    var timeIntervalList = ["0s", "1s", "2s", "3s"];
    var selectedTextInterval = useState("${session.getFormatTextInterval()}s");
    var selectedENGCHNInterval =
        useState("${session.getFormatENGCHNInterval()}s");

    //image show logic
    final showImage = useState(false);
    final imageLink = useState("");

    //Audio Play Logic
    final isLoopPlay = useState(false);
    final isRandomPlay = useState(false);
    final isPlayInOrder = useState(false);
    final isPlayNames = useState(false);
    final isCallModeEnabled = useState(false);
    final ValueNotifier<CardModel?> currentCardLoop = useState(null);
    final ValueNotifier<CardModel?> selectedCard = useState(null);
    final ValueNotifier<StudentModel?> selectedUser = useState(null);

    Future<void> reset() async {
      isLoopPlay.value = false;
      isRandomPlay.value = false;
      isPlayInOrder.value = false;
      isPlayNames.value = false;
      // isCallModeEnabled.value = false;
      currentCardLoop.value = null;
      selectedCard.value = null;
      selectedUser.value = null;
      await audioPlayer.stop();
    }

    Future<void> playLoop(bool isIndOrder) async {
      if (isIndOrder) {
        var student = studentList.asData?.value ?? [];
        for (var item in student.indexed) {
          if (!isLoopPlay.value) {
            return;
          }
          if (item.$2.englishNameModel != null) {
            await audioPlayer.playAndCache(item.$2.englishNameModel!.audioLink);
          }
          if ((cards.asData?.value ?? []).length > item.$1) {
            await Future.delayed(
                Duration(seconds: session.getFormatTextInterval()));
            if (!isLoopPlay.value) {
              return;
            }
            var card = (cards.asData?.value ?? [])[item.$1];
            if (session.getFormatAudioMode() == AudioMode.englishAndChinese) {
              await audioPlayer.playAndCache(card.englishAudioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatENGCHNInterval()));
              if (!isLoopPlay.value) {
                return;
              }
              await audioPlayer.playAndCache(card.chineseAudioLink);
            } else if (session.getFormatAudioMode() ==
                AudioMode.chineseAndEnglish) {
              await audioPlayer.playAndCache(card.chineseAudioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatENGCHNInterval()));
              if (!isPlayInOrder.value) {
                return;
              }
              await audioPlayer.playAndCache(card.englishAudioLink);
            } else if (session.getFormatAudioMode() == AudioMode.english) {
              await audioPlayer.playAndCache(card.englishAudioLink);
            } else if (session.getFormatAudioMode() == AudioMode.chinese) {
              await audioPlayer.playAndCache(card.chineseAudioLink);
            }
          }
        }
        if (isLoopPlay.value) {
          playLoop(true);
        }
      } else {
        var student = studentList.asData?.value ?? [];
        if (student.isNotEmpty) {
          while (isLoopPlay.value) {
            var index = Random().nextInt(student.length);
            var element = student[index];
            if (element.englishNameModel != null) {
              await audioPlayer
                  .playAndCache(element.englishNameModel!.audioLink);
            }
            if ((cards.asData?.value ?? []).length > index) {
              await Future.delayed(
                  Duration(seconds: session.getFormatTextInterval()));
              if (!isLoopPlay.value) {
                return;
              }
              var card = (cards.asData?.value ?? [])[index];
              if (session.getFormatAudioMode() == AudioMode.englishAndChinese) {
                await audioPlayer.playAndCache(card.englishAudioLink);
                await Future.delayed(
                    Duration(seconds: session.getFormatENGCHNInterval()));
                if (!isLoopPlay.value) {
                  return;
                }
                await audioPlayer.playAndCache(card.chineseAudioLink);
              } else if (session.getFormatAudioMode() ==
                  AudioMode.chineseAndEnglish) {
                await audioPlayer.playAndCache(card.chineseAudioLink);
                await Future.delayed(
                    Duration(seconds: session.getFormatENGCHNInterval()));
                if (!isPlayInOrder.value) {
                  return;
                }
                await audioPlayer.playAndCache(card.englishAudioLink);
              } else if (session.getFormatAudioMode() == AudioMode.english) {
                await audioPlayer.playAndCache(card.englishAudioLink);
              } else if (session.getFormatAudioMode() == AudioMode.chinese) {
                await audioPlayer.playAndCache(card.chineseAudioLink);
              }
            }
          }
        }
      }
    }

    Future<void> playRandom(bool isWithName) async {
      if (isWithName) {
        var data = studentList.asData?.value ?? [];
        var student = [...data];
        final data1 = (cards.asData?.value ?? []);
        var cards1 = [...data1];
        if (student.isNotEmpty) {
          while (isRandomPlay.value && student.isNotEmpty) {
            var index = Random().nextInt(student.length);
            var element = student[index];
            student.removeAt(index);
            selectedCard.value = null;
            selectedUser.value = element;
            if (element.englishNameModel != null) {
              await audioPlayer
                  .playAndCache(element.englishNameModel!.audioLink);
            }
            if (cards1.length > index) {
              // await Future.delayed(
              //     Duration(seconds: session.getFormatTextInterval()));
              // if (!isRandomPlay.value) {
              //   return;
              // }
              var card = cards1[index];
              cards1.removeAt(index);
              selectedUser.value = null;
              selectedCard.value = card;
              if (session.getFormatAudioMode() == AudioMode.englishAndChinese) {
                await audioPlayer.playAndCache(card.englishAudioLink);
                await Future.delayed(
                    Duration(seconds: session.getFormatENGCHNInterval()));
                if (!isRandomPlay.value) {
                  selectedCard.value = null;
                  return;
                }
                await audioPlayer.playAndCache(card.chineseAudioLink);
              } else if (session.getFormatAudioMode() ==
                  AudioMode.chineseAndEnglish) {
                await audioPlayer.playAndCache(card.chineseAudioLink);
                await Future.delayed(
                    Duration(seconds: session.getFormatENGCHNInterval()));
                if (!isRandomPlay.value) {
                  selectedCard.value = null;
                  return;
                }
                await audioPlayer.playAndCache(card.englishAudioLink);
              } else if (session.getFormatAudioMode() == AudioMode.english) {
                await audioPlayer.playAndCache(card.englishAudioLink);
              } else if (session.getFormatAudioMode() == AudioMode.chinese) {
                await audioPlayer.playAndCache(card.chineseAudioLink);
              }
              await Future.delayed(
                  Duration(seconds: session.getFormatTextInterval()));
            }
          }
          selectedCard.value = null;
          selectedUser.value = null;
          if (isRandomPlay.value && student.isEmpty) {
            reset();
          }
        } else {
          reset();
        }
      } else {
        var data = studentList.asData?.value ?? [];
        var student = [...data];
        final data1 = (cards.asData?.value ?? []);
        var cards1 = [...data1];
        if (student.isNotEmpty) {
          while (isRandomPlay.value && student.isNotEmpty) {
            var index = Random().nextInt(student.length);
            student.removeAt(index);
            if (cards1.length > index) {
              var card = cards1[index];
              selectedCard.value = card;
              cards1.removeAt(index);
              if (session.getFormatAudioMode() == AudioMode.englishAndChinese) {
                await audioPlayer.playAndCache(card.englishAudioLink);
                await Future.delayed(
                    Duration(seconds: session.getFormatENGCHNInterval()));
                if (!isRandomPlay.value) {
                  selectedCard.value = null;
                  return;
                }
                await audioPlayer.playAndCache(card.chineseAudioLink);
              } else if (session.getFormatAudioMode() ==
                  AudioMode.chineseAndEnglish) {
                await audioPlayer.playAndCache(card.chineseAudioLink);
                await Future.delayed(
                    Duration(seconds: session.getFormatENGCHNInterval()));
                if (!isRandomPlay.value) {
                  selectedCard.value = null;
                  return;
                }
                await audioPlayer.playAndCache(card.englishAudioLink);
              } else if (session.getFormatAudioMode() == AudioMode.english) {
                await audioPlayer.playAndCache(card.englishAudioLink);
              } else if (session.getFormatAudioMode() == AudioMode.chinese) {
                await audioPlayer.playAndCache(card.chineseAudioLink);
              }
              await Future.delayed(
                  Duration(seconds: session.getFormatTextInterval()));
            }
          }
          selectedCard.value = null;
          selectedUser.value = null;
          if (isRandomPlay.value && student.isEmpty) {
            reset();
          }
        } else {
          reset();
        }
      }
    }

    Future<void> playInOrder(bool isWithName) async {
      if (isWithName) {
        var student = studentList.asData?.value ?? [];
        for (var item in student.indexed) {
          if (!isPlayInOrder.value) {
            selectedCard.value = null;
            selectedUser.value = null;
            return;
          }
          if (item.$2.englishNameModel != null) {
            selectedCard.value = null;
            selectedUser.value = item.$2;
            await audioPlayer.playAndCache(item.$2.englishNameModel!.audioLink);
          }
          if ((cards.asData?.value ?? []).length > item.$1) {
            // await Future.delayed(
            //     Duration(seconds: session.getFormatTextInterval()));
            // if (!isPlayInOrder.value) {
            //   return;
            // }
            selectedUser.value = null;
            var card = (cards.asData?.value ?? [])[item.$1];
            selectedCard.value = card;
            if (session.getFormatAudioMode() == AudioMode.englishAndChinese) {
              await audioPlayer.playAndCache(card.englishAudioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatENGCHNInterval()));
              if (!isPlayInOrder.value) {
                selectedCard.value = null;
                return;
              }
              await audioPlayer.playAndCache(card.chineseAudioLink);
            } else if (session.getFormatAudioMode() ==
                AudioMode.chineseAndEnglish) {
              await audioPlayer.playAndCache(card.chineseAudioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatENGCHNInterval()));
              if (!isPlayInOrder.value) {
                selectedCard.value = null;
                return;
              }
              await audioPlayer.playAndCache(card.englishAudioLink);
            } else if (session.getFormatAudioMode() == AudioMode.english) {
              await audioPlayer.playAndCache(card.englishAudioLink);
            } else if (session.getFormatAudioMode() == AudioMode.chinese) {
              await audioPlayer.playAndCache(card.chineseAudioLink);
            }
            await Future.delayed(
                Duration(seconds: session.getFormatTextInterval()));
          }
        }
        if (isPlayInOrder.value) {
          reset();
        }
        // if (isPlayInOrder.value) {
        //   playInOrder(true);
        // }
      } else {
        var data = studentList.asData?.value ?? [];
        var student = [...data];
        for (var item in student.indexed) {
          if ((cards.asData?.value ?? []).length > item.$1) {
            if (!isPlayInOrder.value) {
              selectedCard.value = null;
              return;
            }
            var card = (cards.asData?.value ?? [])[item.$1];
            selectedCard.value = card;
            if (session.getFormatAudioMode() == AudioMode.englishAndChinese) {
              await audioPlayer.playAndCache(card.englishAudioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatENGCHNInterval()));
              if (!isPlayInOrder.value) {
                selectedCard.value = null;
                return;
              }
              await audioPlayer.playAndCache(card.chineseAudioLink);
            } else if (session.getFormatAudioMode() ==
                AudioMode.chineseAndEnglish) {
              await audioPlayer.playAndCache(card.chineseAudioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatENGCHNInterval()));
              if (!isPlayInOrder.value) {
                selectedCard.value = null;
                return;
              }
              await audioPlayer.playAndCache(card.englishAudioLink);
            } else if (session.getFormatAudioMode() == AudioMode.english) {
              await audioPlayer.playAndCache(card.englishAudioLink);
            } else if (session.getFormatAudioMode() == AudioMode.chinese) {
              await audioPlayer.playAndCache(card.chineseAudioLink);
            }
            await Future.delayed(
                Duration(seconds: session.getFormatTextInterval()));
          }
        }
        if (isPlayInOrder.value) {
          reset();
        }
        // if (isPlayInOrder.value) {
        //   playInOrder(false);
        // }
      }
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
                Duration(seconds: session.getFormatTextInterval()));
          }
        }
        reset();
        // if (isPlayNames.value) {
        //   playNames(true);
        // }
      } else {
        final data = studentList.asData?.value ?? [];
        var student = [...data];
        if (student.isNotEmpty) {
          while (isPlayNames.value && student.isNotEmpty) {
            var index = Random().nextInt(student.length);
            var element = student[index];
            student.removeAt(index);
            selectedUser.value = element;
            if (element.englishNameModel != null) {
              await audioPlayer
                  .playAndCache(element.englishNameModel!.audioLink);
              await Future.delayed(
                  Duration(seconds: session.getFormatTextInterval()));
            }
          }
          if (isPlayNames.value && student.isEmpty) {
            reset();
          }
        }
      }
    }

    Future<void> playCardInLoop(CardModel cardModel) async {
      while (currentCardLoop.value?.id == cardModel.id) {
        if (session.getFormatAudioMode() == AudioMode.english) {
          await audioPlayer.playAndCache(cardModel.englishAudioLink);
        } else if (session.getFormatAudioMode() == AudioMode.chinese) {
          await audioPlayer.playAndCache(cardModel.chineseAudioLink);
        } else if (session.getFormatAudioMode() ==
            AudioMode.englishAndChinese) {
          await audioPlayer.playAndCache(cardModel.englishAudioLink);
          await Future.delayed(
              Duration(seconds: session.getFormatENGCHNInterval()));
          if (currentCardLoop.value?.id == cardModel.id) {
            await audioPlayer.playAndCache(cardModel.chineseAudioLink);
          }
        } else if (session.getFormatAudioMode() ==
            AudioMode.chineseAndEnglish) {
          await audioPlayer.playAndCache(cardModel.chineseAudioLink);
          await Future.delayed(
              Duration(seconds: session.getFormatENGCHNInterval()));
          if (currentCardLoop.value?.id == cardModel.id) {
            await audioPlayer.playAndCache(cardModel.englishAudioLink);
          }
        }
        await Future.delayed(
            Duration(seconds: session.getFormatTextInterval()));
      }
    }

    Future<void> updateCallModeCount() async {
      var count = teacher.format_s_call_mode + 1;
      await ref
          .read(teacherServiceProvider)
          .updateTeacherFormat7CallMode(count, teacher.id);
      await ref
          .read(teacherServiceProvider)
          .getTeacherProfile(Supabase.instance.client.auth.currentUser!.id);
      ref.refresh(sessionManagerProvider);
    }

    //download logic
    final isDownloading = useState(false);
    final downloadedFiles = useState(0);
    final totalFiles = useState(0);
    final isCardDownloaded = useState(false);
    final isNamesDownloaded = useState(false);
    final isCallModeDownloaded = useState(false);
    final isSpecialLanguageDownloaded = useState(false);

    Future<void> downloadFile(String url) async {
      DefaultCacheManager().getSingleFile(url).then((value) {
        downloadedFiles.value += 1;
        if (isCallModeDownloaded.value &&
            isNamesDownloaded.value &&
            isSpecialLanguageDownloaded.value &&
            isCardDownloaded.value) {
          if (totalFiles.value == downloadedFiles.value) {
            isDownloading.value = false;
          }
        }
      });
    }

    void downloadFiles(List<CardModel> list) {
      isDownloading.value = true;
      final students = studentList.asData?.value ?? [];
      if (students.isNotEmpty) {
        var total = students.length;
        var index = 0;
        list.forEach((element) {
          if (index < total) {
            if (element.englishAudioLink.isNotEmpty) {
              totalFiles.value += 1;
              downloadFile(element.englishAudioLink);
            }
            if (element.chineseAudioLink.isNotEmpty) {
              totalFiles.value += 1;
              downloadFile(element.chineseAudioLink);
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
            index += 1;
          }
        });
        isCardDownloaded.value = true;
      } else {
        list.forEach((element) {
          if (element.englishAudioLink.isNotEmpty) {
            totalFiles.value += 1;
            downloadFile(element.englishAudioLink);
          }
          if (element.chineseAudioLink.isNotEmpty) {
            totalFiles.value += 1;
            downloadFile(element.chineseAudioLink);
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
    }

    void downloadSpecialLanguage(List<SpecialLanguageModel> list) {
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
      isSpecialLanguageDownloaded.value = true;
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

    ref.listen(specialFormat7LanguageProvider(teacher.formatSevenSession),
        (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadSpecialLanguage(next.asData!.value);
        } else {
          isSpecialLanguageDownloaded.value = true;
        }
      }
    });
    ref.listen(
        classStudentsFormat7SortedProvider(FilterClass(
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
    ref.listen(
        levelCardSessionSortedProvider(FilterClass(
            classId: teacher?.formatSevenSession ?? 1,
            schoolId: teacher?.levelId ?? 0)), (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadFiles(next.asData!.value);
        } else {
          isCardDownloaded.value = true;
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
      if (specialLanguage.asData?.value != null) {
        if (specialLanguage.asData!.value.isNotEmpty) {
          downloadSpecialLanguage(specialLanguage.asData!.value);
        } else {
          isSpecialLanguageDownloaded.value = true;
        }
      }
      if (cards.asData?.value != null) {
        if (cards.asData?.value != null) {
          if (cards.asData!.value.isNotEmpty) {
            downloadFiles(cards.asData!.value);
          } else {
            isCardDownloaded.value = true;
          }
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
      if (studentList.asData?.value != null) {
        if (studentList.asData?.value != null) {
          if (studentList.asData!.value.isNotEmpty) {
            downloadNames(studentList.asData!.value);
          } else {
            isNamesDownloaded.value = true;
          }
        }
      }
      return;
    }, []);

    return FocusDetector(
      onFocusLost: () {
        reset();
      },
      onFocusGained: () {},
      child: Scaffold(
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleKeys.accompany_card.tr(),
                                  style: TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${LocaleKeys.session.tr()} ${teacher.formatSevenSession}",
                                  style: TextStyle(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10),
                                ),
                              ],
                            )
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            final f = DateFormat('yyyy-MM-dd');
                            if (teacher.format_seven_switch_date !=
                                f.format(DateTime.now())) {
                              if ((cards.asData?.value ?? []).length >
                                  teacher.formatSevenSession) {
                                DialogHelper.showConfirmationDialog(
                                    LocaleKeys.start_next_session.tr(),
                                    (p0) async {
                                  if (p0) {
                                    await ref
                                        .read(teacherServiceProvider)
                                        .updateFormat7Session(
                                            (teacher?.formatSevenSession ?? 1) +
                                                1,
                                            teacher?.id ?? 0);
                                    await ref
                                        .read(teacherServiceProvider)
                                        .getTeacherProfile(Supabase.instance
                                            .client.auth.currentUser!.id);
                                    ref.refresh(sessionManagerProvider);
                                    ref.refresh(levelCardSessionSortedProvider(
                                        FilterClass(
                                            classId:
                                                teacher?.formatSevenSession ??
                                                    1,
                                            schoolId: teacher?.levelId ?? 0)));
                                  }
                                });
                              } else {
                                DialogHelper.showError(context
                                    .tr(LocaleKeys.create_session_error));
                              }
                            } else {
                              DialogHelper.showError(context
                                  .tr(LocaleKeys.switch_one_session_in_day));
                            }
                          },
                          child: Image.asset(
                            Assets.imagesSessionSwitch,
                            height: 24,
                            width: 24,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            Assets.imagesSubmit,
                            height: 24,
                            width: 24,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        StatefulBuilder(builder: (context, setState) {
                          return PopupMenuButton<String>(
                              elevation: 12,
                              color: AppColors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              onSelected: (val) async {
                                if (val == "setting") {
                                  NavManager().goTo(const SortStudentsScreen(
                                    isFirstTime: false,
                                  ));
                                }
                              },
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
                                                            .saveFormatAudioMode(
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
                                                            .saveFormatTextInterval(int.parse(
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
                                                            .saveFormatENGCHNInterval(int.parse(
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
                                    PopupMenuItem(
                                      height: 35,
                                      value: "setting",
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: StatefulBuilder(builder:
                                          (BuildContext context,
                                              StateSetter setState) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${LocaleKeys.class_name.tr()} ${LocaleKeys.settings.tr()}",
                                                style: TextStyle(
                                                    color: AppColors.black),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Image.asset(
                                              Assets.imagesSetting1,
                                              height: 20,
                                              width: 20,
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ]);
                        }),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              TopItem(
                                  image: Assets.imagesIcons8Language,
                                  title: LocaleKeys.common_language.tr(),
                                  callback: () {
                                    NavManager()
                                        .goTo(const CommonLanguageScreen());
                                  }),
                              const SizedBox(
                                width: 5,
                              ),
                              TopItem(
                                  image: Assets.imagesIcons8LanguageSkill,
                                  title: LocaleKeys.special_language.tr(),
                                  isSelected: isSpecialLanguageShown.value,
                                  callback: () {
                                    // NavManager()
                                    //     .goTo(const Format7SpecialLanguage());
                                    isSpecialLanguageShown.value =
                                        !isSpecialLanguageShown.value;
                                  }),
                            ],
                          ),
                          Visibility(
                            visible: isSpecialLanguageShown.value,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: specialLanguage.when(data: (items) {
                                    return items.isEmpty
                                        ? CenterErrorView(
                                            errorMsg: context.tr(
                                                LocaleKeys.no_sentence_found),
                                          )
                                        : MasonryGridView.count(
                                            primary: false,
                                            shrinkWrap: true,
                                            crossAxisCount: 2,
                                            itemCount: items.length,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final item = items[index];
                                              return SpecialLanguageItem(
                                                languageModel: item,
                                                closeTapped: () {},
                                                isLoop:
                                                    currentCardLoop.value?.id ==
                                                        item.id,
                                                cardLoopTapped: () {
                                                  // if (currentCardLoop.value?.id !=
                                                  //     item.id) {
                                                  //   reset();
                                                  //   currentCardLoop.value = item;
                                                  //   playCardInLoop(item);
                                                  // } else {
                                                  //   reset();
                                                  // }
                                                },
                                                playTapped: () async {
                                                  reset();
                                                  if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode.chinese) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode.english) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode
                                                          .englishAndChinese) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_audio);
                                                    Future.delayed(Duration(
                                                        seconds: session
                                                            .getFormatENGCHNInterval()));
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode
                                                          .chineseAndEnglish) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_audio);
                                                    Future.delayed(Duration(
                                                        seconds: session
                                                            .getFormatENGCHNInterval()));
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_audio);
                                                  }
                                                },
                                                studentTapped: () async {
                                                  reset();
                                                  if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode.chinese) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_std_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode.english) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_std_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode
                                                          .englishAndChinese) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_std_audio);
                                                    Future.delayed(Duration(
                                                        seconds: session
                                                            .getFormatENGCHNInterval()));
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_std_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode
                                                          .chineseAndEnglish) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_std_audio);
                                                    Future.delayed(Duration(
                                                        seconds: session
                                                            .getFormatENGCHNInterval()));
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_std_audio);
                                                  }
                                                },
                                                actionTapped: () async {
                                                  reset();
                                                  if (item.action_ch_audio
                                                          .isNotEmpty &&
                                                      item.action_en_audio
                                                          .isNotEmpty) {
                                                    imageLink.value =
                                                        item.ad_image;
                                                    showImage.value = true;
                                                    if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode.english) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .action_en_audio);
                                                    } else if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode.chinese) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .action_ch_audio);
                                                    } else if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode
                                                            .englishAndChinese) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .action_en_audio);
                                                      await Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormatENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .action_ch_audio);
                                                    } else if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode
                                                            .chineseAndEnglish) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .action_ch_audio);
                                                      await Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormatENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .action_en_audio);
                                                    }
                                                  } else {
                                                    DialogHelper.showError(
                                                        context.tr(LocaleKeys
                                                            .no_audio_found));
                                                  }
                                                },
                                                imageTapped: () {
                                                  // reset();
                                                  if (item
                                                      .ad_image.isNotEmpty) {
                                                    imageLink.value =
                                                        item.ad_image;
                                                    showImage.value = true;
                                                    // NavManager().goTo(
                                                    //     FullScreenImage(
                                                    //         imageUrl:
                                                    //             item.ad_image));
                                                  } else {
                                                    DialogHelper.showError(
                                                        context.tr(LocaleKeys
                                                            .no_image_found));
                                                  }
                                                },
                                                descriptionTapped: () async {
                                                  reset();
                                                  if (item.ad_en_audio
                                                          .isNotEmpty &&
                                                      item.ad_ch_audio
                                                          .isNotEmpty) {
                                                    imageLink.value =
                                                        item.ad_image;
                                                    showImage.value = true;
                                                    if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode.english) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ad_en_audio);
                                                    } else if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode.chinese) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ad_ch_audio);
                                                    } else if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode
                                                            .englishAndChinese) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ad_en_audio);
                                                      await Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormatENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ad_ch_audio);
                                                    } else if (session
                                                            .getFormatAudioMode() ==
                                                        AudioMode
                                                            .chineseAndEnglish) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ad_ch_audio);
                                                      await Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormatENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ad_en_audio);
                                                    }
                                                  } else {
                                                    DialogHelper.showError(
                                                        context.tr(LocaleKeys
                                                            .no_audio_found));
                                                  }
                                                },
                                              );
                                            },
                                          );
                                  }, error: (err, trace) {
                                    debugPrint(
                                        "Error occurred while fetching elements: $err");
                                    return CenterErrorView(
                                      errorMsg: context.tr(
                                          LocaleKeys.error_fetching_element),
                                    );
                                  }, loading: () {
                                    return CenterLoadingView(
                                      color: AppColors.mustard,
                                      size: 24,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
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
                                    isCallModeEnabled.value =
                                        !isCallModeEnabled.value;
                                  }),
                              const Spacer(),
                              MenuItem(
                                  isPlaying: isRandomPlay.value,
                                  image: isRandomPlay.value
                                      ? Assets.imagesStop
                                      : Assets.imagesShuffle,
                                  title: LocaleKeys.random_play.tr(),
                                  title1: LocaleKeys.play_with_names.tr(),
                                  title2: LocaleKeys.play_without_names.tr(),
                                  callback: (String val) {
                                    reset();
                                    if (val == "1") {
                                      isRandomPlay.value = true;
                                      playRandom(true);
                                    } else if (val == "2") {
                                      isRandomPlay.value = true;
                                      playRandom(false);
                                    } else {
                                      reset();
                                    }
                                  }),
                              const SizedBox(
                                width: 5,
                              ),
                              MenuItem(
                                  isPlaying: isPlayInOrder.value,
                                  image: isPlayInOrder.value
                                      ? Assets.imagesStop
                                      : Assets.imagesName,
                                  title: LocaleKeys.play_in_order.tr(),
                                  title1: LocaleKeys.play_with_names.tr(),
                                  title2: LocaleKeys.play_without_names.tr(),
                                  callback: (String val) {
                                    reset();
                                    if (val == "1") {
                                      isPlayInOrder.value = true;
                                      playInOrder(true);
                                    } else if (val == "2") {
                                      isPlayInOrder.value = true;
                                      playInOrder(false);
                                    } else {
                                      reset();
                                    }
                                  }),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: cards.when(data: (items) {
                              return items.isEmpty
                                  ? CenterErrorView(
                                      errorMsg: context
                                          .tr(LocaleKeys.no_sentence_found),
                                    )
                                  : Container(
                                      child: studentList.when(data: (items) {
                                        return items.isEmpty
                                            ? CenterErrorView(
                                                errorMsg: context.tr(LocaleKeys
                                                    .no_student_found),
                                              )
                                            : ListView.separated(
                                                primary: false,
                                                shrinkWrap: true,
                                                itemCount: items.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final item = items[index];
                                                  CardModel? cardModel;
                                                  if (index <
                                                      (cards.asData?.value ??
                                                              [])
                                                          .length) {
                                                    cardModel =
                                                        (cards.asData?.value ??
                                                            [])[index];
                                                  }
                                                  return _StudentItem(
                                                    studentModel: item,
                                                    cardModel: cardModel,
                                                    isSelected:
                                                        selectedUser.value ==
                                                            item,
                                                    isCardSelected:
                                                        selectedCard.value ==
                                                            cardModel,
                                                    isLoop: currentCardLoop
                                                            .value?.id ==
                                                        cardModel?.id,
                                                    cardLoopTapped: () {
                                                      if (cardModel != null) {
                                                        if (currentCardLoop
                                                                .value?.id !=
                                                            cardModel.id) {
                                                          reset();
                                                          currentCardLoop
                                                                  .value =
                                                              cardModel;
                                                          playCardInLoop(
                                                              cardModel);
                                                        } else {
                                                          reset();
                                                        }
                                                      }
                                                    },
                                                    cardTapped: () async {
                                                      reset();
                                                      if (cardModel != null) {
                                                        if (session
                                                                .getFormatAudioMode() ==
                                                            AudioMode.english) {
                                                          await audioPlayer
                                                              .playAndCache(
                                                                  cardModel
                                                                      .englishAudioLink);
                                                        } else if (session
                                                                .getFormatAudioMode() ==
                                                            AudioMode.chinese) {
                                                          await audioPlayer
                                                              .playAndCache(
                                                                  cardModel
                                                                      .chineseAudioLink);
                                                        } else if (session
                                                                .getFormatAudioMode() ==
                                                            AudioMode
                                                                .chineseAndEnglish) {
                                                          await audioPlayer
                                                              .playAndCache(
                                                                  cardModel
                                                                      .chineseAudioLink);
                                                          await Future.delayed(
                                                              Duration(
                                                                  seconds: session
                                                                      .getFormatENGCHNInterval()));
                                                          await audioPlayer
                                                              .playAndCache(
                                                                  cardModel
                                                                      .englishAudioLink);
                                                        } else {
                                                          await audioPlayer
                                                              .playAndCache(
                                                                  cardModel
                                                                      .englishAudioLink);
                                                          await Future.delayed(
                                                              Duration(
                                                                  seconds: session
                                                                      .getFormatENGCHNInterval()));
                                                          await audioPlayer
                                                              .playAndCache(
                                                                  cardModel
                                                                      .chineseAudioLink);
                                                        }
                                                      }
                                                    },
                                                    nameTapped: () async {
                                                      reset();
                                                      if (isCallModeEnabled
                                                          .value) {
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
                                                      if (isCallModeEnabled
                                                          .value) {
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
                                                      if (isCallModeEnabled
                                                          .value) {
                                                        updateCallModeCount();
                                                      }
                                                    },
                                                    actionTapped: () async {
                                                      reset();
                                                      if (cardModel != null) {
                                                        if (cardModel
                                                                .action_ch_audio
                                                                .isNotEmpty &&
                                                            cardModel
                                                                .action_en_audio
                                                                .isNotEmpty) {
                                                          imageLink.value =
                                                              cardModel
                                                                  .ad_image;
                                                          showImage.value =
                                                              true;
                                                          if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .english) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .action_en_audio);
                                                          } else if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .chinese) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .action_ch_audio);
                                                          } else if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .englishAndChinese) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .action_en_audio);
                                                            await Future.delayed(
                                                                Duration(
                                                                    seconds: session
                                                                        .getFormatENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .action_ch_audio);
                                                          } else if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .chineseAndEnglish) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .action_ch_audio);
                                                            await Future.delayed(
                                                                Duration(
                                                                    seconds: session
                                                                        .getFormatENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .action_en_audio);
                                                          }
                                                        } else {
                                                          DialogHelper.showError(
                                                              context.tr(LocaleKeys
                                                                  .no_audio_found));
                                                        }
                                                      }
                                                    },
                                                    imageTapped: () {
                                                      // reset();
                                                      if (cardModel != null) {
                                                        if (cardModel.ad_image
                                                            .isNotEmpty) {
                                                          imageLink.value =
                                                              cardModel
                                                                  .ad_image;
                                                          showImage.value =
                                                              true;
                                                          // NavManager().goTo(
                                                          //     FullScreenImage(
                                                          //         imageUrl: cardModel
                                                          //             .ad_image));
                                                        } else {
                                                          DialogHelper.showError(
                                                              context.tr(LocaleKeys
                                                                  .no_image_found));
                                                        }
                                                      }
                                                    },
                                                    descriptionTapped:
                                                        () async {
                                                      reset();
                                                      if (cardModel != null) {
                                                        if (cardModel
                                                                .ad_en_audio
                                                                .isNotEmpty &&
                                                            cardModel
                                                                .ad_ch_audio
                                                                .isNotEmpty) {
                                                          imageLink.value =
                                                              cardModel
                                                                  .ad_image;
                                                          showImage.value =
                                                              true;
                                                          if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .english) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .ad_en_audio);
                                                          } else if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .chinese) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .ad_ch_audio);
                                                          } else if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .englishAndChinese) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .ad_en_audio);
                                                            await Future.delayed(
                                                                Duration(
                                                                    seconds: session
                                                                        .getFormatENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .ad_ch_audio);
                                                          } else if (session
                                                                  .getFormatAudioMode() ==
                                                              AudioMode
                                                                  .chineseAndEnglish) {
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .ad_ch_audio);
                                                            await Future.delayed(
                                                                Duration(
                                                                    seconds: session
                                                                        .getFormatENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(
                                                                    cardModel
                                                                        .ad_en_audio);
                                                          }
                                                        } else {
                                                          DialogHelper.showError(
                                                              context.tr(LocaleKeys
                                                                  .no_audio_found));
                                                        }
                                                      }
                                                    },
                                                  );
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return const SizedBox(
                                                    height: 15,
                                                  );
                                                },
                                              );
                                      }, error: (err, trace) {
                                        debugPrint(
                                            "Error occurred while fetching elements: $err");
                                        return CenterErrorView(
                                          errorMsg: context.tr(LocaleKeys
                                              .error_fetching_element),
                                        );
                                      }, loading: () {
                                        return CenterLoadingView(
                                          color: AppColors.mustard,
                                          size: 24,
                                        );
                                      }),
                                    );
                            }, error: (err, trace) {
                              debugPrint(
                                  "Error occurred while fetching elements: $err");
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
                        ],
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

class _StudentItem extends StatelessWidget {
  final StudentModel studentModel;
  final CardModel? cardModel;
  final VoidCallback cardTapped;
  final VoidCallback nameTapped;
  final VoidCallback imageTapped;
  final VoidCallback actionTapped;
  final VoidCallback descriptionTapped;
  final VoidCallback cardLoopTapped;
  final bool isLoop;
  final bool isSelected;
  final bool isCardSelected;
  const _StudentItem(
      {super.key,
      required this.studentModel,
      required this.cardModel,
      required this.nameTapped,
      required this.cardTapped,
      required this.imageTapped,
      required this.descriptionTapped,
      required this.actionTapped,
      required this.cardLoopTapped,
      required this.isSelected,
      required this.isCardSelected,
      required this.isLoop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ButtonAnimationWidget(
          onTap: nameTapped,
          child: Container(
            height: 125,
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
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            height: 125,
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
            child: cardModel != null
                ? Column(
                    children: [
                      ButtonAnimationWidget(
                        onTap: cardTapped,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: isCardSelected
                                ? AppColors.yellow
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
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
                                  cardModel?.name ?? "",
                                  style: TextStyle(color: AppColors.brown),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              ImageButton(
                                  image: isLoop
                                      ? Assets.imagesStop
                                      : Assets.imagesLoop,
                                  bg: AppColors.white,
                                  btnSize: 34,
                                  iconSize: 22,
                                  callback: cardLoopTapped),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: cardModel!.ad_text.isNotEmpty ||
                            cardModel!.action_text.isNotEmpty,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Visibility(
                                  visible: cardModel!.action_text.isNotEmpty,
                                  child: ButtonAnimationWidget(
                                    onTap: actionTapped,
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                        color: AppColors.lightBlue,
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: AppColors.brown),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            spreadRadius: 0,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                4), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          cardModel?.action_text ?? "",
                                          style: TextStyle(
                                              color: AppColors.brown,
                                              fontSize: 12),
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
                                    visible: cardModel!.ad_text.isNotEmpty,
                                    child: ButtonAnimationWidget(
                                      onTap: descriptionTapped,
                                      child: Container(
                                        height: 45,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(23),
                                          border: Border.all(
                                              color: AppColors.brown),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.25),
                                              spreadRadius: 0,
                                              blurRadius: 4,
                                              offset: const Offset(0,
                                                  4), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                cardModel?.ad_text ?? "",
                                                style: TextStyle(
                                                    color: AppColors.brown,
                                                    fontSize: 12),
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
                  )
                : CenterErrorView(
                    errorMsg: context.tr(LocaleKeys.no_sentence_found),
                  ),
          ),
        ),
      ],
    );
  }
}
