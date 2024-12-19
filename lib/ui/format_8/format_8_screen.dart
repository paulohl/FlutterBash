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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/core/dialog_helper.dart';
import 'package:xueli/data/providers/audio_player_providers.dart';
import 'package:xueli/data/providers/call_mode_providers.dart';
import 'package:xueli/data/providers/format_8_providers.dart';
import 'package:xueli/data/providers/special_language_providers.dart';
import 'package:xueli/data/providers/student_providers.dart';
import 'package:xueli/data/services/format_8_service.dart';
import 'package:xueli/data/services/teacher_service.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/box_card_model.dart';
import 'package:xueli/models/box_model.dart';
import 'package:xueli/models/call_mode_model.dart';
import 'package:xueli/models/session_model.dart';
import 'package:xueli/models/sound_effect_model.dart';
import 'package:xueli/models/special_language.dart';
import 'package:xueli/models/student_model.dart';
import 'package:xueli/ui/common_language/common_language_screen.dart';
import 'package:xueli/ui/format_7/special_language/format_7_special_language.dart';
import 'package:xueli/ui/format_7/special_language/widgets/special_language_item.dart';
import 'package:xueli/ui/format_8/group/format_8_group_screen.dart';
import 'package:xueli/ui/widgets/center_error_view.dart';
import 'package:xueli/ui/widgets/center_loading_view.dart';
import 'package:xueli/ui/widgets/primary_button.dart';
import 'package:collection/collection.dart';

import 'special_language/format_8_special_language.dart';

class Format8Screen extends HookConsumerWidget {
  const Format8Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
    final audioPlayer = ref.watch(audioPlayerProvider);
    final teacher = ref.watch(sessionManagerProvider).getTeacherProfile();
    final currentCallModeList =
        ref.watch(getCurrentCallModeProvider(teacher!.levelId)).asData?.value;
    final teacherPhrases = ref.watch(getCurrentTeacherPhraseProvider);

    final boxList = ref.watch(sessionBoxesSessionNumberProvider(FilterClass(
        classId: teacher?.classId ?? 0,
        schoolId: teacher?.schoolId ?? 0,
        teacherId: teacher?.id ?? 0,
        session: teacher.formatEightSession)));

    var audioModeList = [
      AudioMode.english,
      AudioMode.chinese,
      AudioMode.englishAndChinese,
      AudioMode.chineseAndEnglish,
    ];
    var selectedAudioMode = useState(session.getForma8tAudioMode());
    var timeIntervalList = ["0s", "1s", "2s", "3s"];
    var selectedTextInterval = useState("${session.getFormat8TextInterval()}s");
    var selectedENGCHNInterval =
        useState("${session.getFormat8ENGCHNInterval()}s");

    ///session
    final sessionModel = ref
        .watch(sessionDetailsProvider(teacher.formatEightSession))
        .asData
        ?.value;
    final isGameMode = useState(false);
    final ValueNotifier<RoundModel?> selectedRound = useState(null);
    final ValueNotifier<String> selectedGroup = useState("A");

    final roundsList = ref.watch(
        sessionRoundsWithSessionNumberProvider(teacher.formatEightSession));
    final AsyncValue<RoundDataModel?> roundDataItem = ref.watch(
        sessionCurrentRoundsDataWithSessionNumberProvider(Format8FilterClass(
            sessionId: teacher.formatEightSession,
            roundId: selectedRound.value?.id ?? 0,
            group: selectedGroup.value)));
    final sessionCTPList = ref.watch(sessionRoundsGroupDataCTPProvider(
        roundDataItem.asData?.value?.id ?? 0));
    final sessionCTPComboPlay = useState(0);
    final sessionGamePhrase = ref.watch(
        sessionRoundsGroupDataGamePhraseProvider(
            roundDataItem.asData?.value?.id ?? 0));

    final soundEffect = ref.watch(sessionGroupSoundProvider(
      FilterClass(
          classId: 0,
          schoolId: 0,
          session: teacher.formatEightSession,
          format: selectedGroup.value),
    ));

    final isAudioLoading = useState(false);
    ref.listen(
        sessionRoundsWithSessionNumberProvider(teacher.formatEightSession),
        (previous, next) {
      if (next.asData?.value != null) {
        final list = next.asData!.value;
        if (list.isNotEmpty) {
          final res = list.firstWhereOrNull(
              (element) => element.round == teacher.format_eight_round);
          if (res != null) {
            selectedRound.value = res;
            selectedGroup.value = "A";
          } else {
            selectedRound.value = null;
          }
        }
      }
    });

    Color getGroupColor(String group) {
      var reminder = teacher.formatEightSession % 60;
      reminder = reminder == 0 ? 60 : reminder;
      if (group == "A") {
        if (reminder < 11) {
          return AppColors.groupRed;
        } else if (reminder < 21) {
          return AppColors.groupPurple;
        } else if (reminder < 31) {
          return AppColors.groupBlue;
        } else if (reminder < 41) {
          return AppColors.groupGreen;
        } else if (reminder < 51) {
          return AppColors.groupYellow;
        } else {
          return AppColors.groupOrange;
        }
      } else if (group == "B") {
        if (reminder < 11) {
          return AppColors.groupOrange;
        } else if (reminder < 21) {
          return AppColors.groupRed;
        } else if (reminder < 31) {
          return AppColors.groupPurple;
        } else if (reminder < 41) {
          return AppColors.groupBlue;
        } else if (reminder < 51) {
          return AppColors.groupGreen;
        } else {
          return AppColors.groupYellow;
        }
      } else if (group == "C") {
        if (reminder < 11) {
          return AppColors.groupYellow;
        } else if (reminder < 21) {
          return AppColors.groupOrange;
        } else if (reminder < 31) {
          return AppColors.groupRed;
        } else if (reminder < 41) {
          return AppColors.groupPurple;
        } else if (reminder < 51) {
          return AppColors.groupBlue;
        } else {
          return AppColors.groupGreen;
        }
      } else if (group == "D") {
        if (reminder < 11) {
          return AppColors.groupGreen;
        } else if (reminder < 21) {
          return AppColors.groupYellow;
        } else if (reminder < 31) {
          return AppColors.groupOrange;
        } else if (reminder < 41) {
          return AppColors.groupRed;
        } else if (reminder < 51) {
          return AppColors.groupPurple;
        } else {
          return AppColors.groupBlue;
        }
      } else if (group == "E") {
        if (reminder < 11) {
          return AppColors.groupBlue;
        } else if (reminder < 21) {
          return AppColors.groupGreen;
        } else if (reminder < 31) {
          return AppColors.groupYellow;
        } else if (reminder < 41) {
          return AppColors.groupOrange;
        } else if (reminder < 51) {
          return AppColors.groupRed;
        } else {
          return AppColors.groupPurple;
        }
      } else if (group == "F") {
        if (reminder < 11) {
          return AppColors.groupPurple;
        } else if (reminder < 21) {
          return AppColors.groupBlue;
        } else if (reminder < 31) {
          return AppColors.groupGreen;
        } else if (reminder < 41) {
          return AppColors.groupYellow;
        } else if (reminder < 51) {
          return AppColors.groupOrange;
        } else {
          return AppColors.groupRed;
        }
      } else {
        //will not come here
        return AppColors.groupBlue;
      }
    }

    final ValueNotifier<Color> selectedColor = useState(getGroupColor("A"));

    ///students
    final studentList = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: selectedColor.value)));

    final studentListGroupA = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: getGroupColor("A"))));
    final studentListGroupB = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: getGroupColor("B"))));
    final studentListGroupC = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: getGroupColor("C"))));
    final studentListGroupD = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: getGroupColor("D"))));
    final studentListGroupE = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: getGroupColor("E"))));
    final studentListGroupF = ref.watch(classStudentsFormat8SortedProvider(
        FilterClass(
            classId: teacher?.classId ?? 0,
            schoolId: teacher?.schoolId ?? 0,
            teacherId: teacher?.id ?? 0,
            groupColor: getGroupColor("F"))));
    final isFirstTime = useState(true);

    void checkFirstSelectedGroup() {
      if (isFirstTime.value) {
        isFirstTime.value = false;
        final groupA = studentListGroupA.asData?.value ?? [];
        final groupB = studentListGroupB.asData?.value ?? [];
        final groupC = studentListGroupC.asData?.value ?? [];
        final groupD = studentListGroupD.asData?.value ?? [];
        final groupE = studentListGroupE.asData?.value ?? [];
        final groupF = studentListGroupF.asData?.value ?? [];
        Future.microtask(() {
          if (groupA.isEmpty &&
              groupB.isEmpty &&
              groupC.isEmpty &&
              groupD.isEmpty &&
              groupE.isEmpty &&
              groupF.isNotEmpty) {
            selectedGroup.value = "F";
            selectedColor.value = getGroupColor("F");
          }
          if (groupA.isEmpty &&
              groupB.isEmpty &&
              groupC.isEmpty &&
              groupD.isEmpty &&
              groupE.isNotEmpty) {
            selectedGroup.value = "E";
            selectedColor.value = getGroupColor("E");
          }
          if (groupA.isEmpty &&
              groupB.isEmpty &&
              groupC.isEmpty &&
              groupD.isNotEmpty) {
            selectedGroup.value = "D";
            selectedColor.value = getGroupColor("D");
          }
          if (groupA.isEmpty && groupB.isEmpty && groupC.isNotEmpty) {
            selectedGroup.value = "C";
            selectedColor.value = getGroupColor("C");
          }
          if (groupA.isEmpty && groupB.isNotEmpty) {
            selectedGroup.value = "B";
            selectedColor.value = getGroupColor("B");
          }
        });
      }
    }

    ///Special Language
    final groupSpecialLanguage = ref.watch(
        format8SessionGroupSpecialLanguageProvider(Format8FilterClass(
            sessionId: teacher.formatEightSession,
            roundId: 0,
            group: selectedGroup.value)));
    final isSpecialLanguageShown = useState(false);
    //image show logic
    final showImage = useState(false);
    final imageLink = useState("");

    ///Audio Player
    //Audio Play Logic
    final isLoopPlay = useState(false);
    final isRandomPlay = useState(false);
    final isPlayInOrder = useState(false);
    final isPlayNames = useState(false);
    final isCallModeEnabled = useState(false);
    final ValueNotifier<StudentModel?> selectedUser = useState(null);

    Future<void> reset() async {
      isLoopPlay.value = false;
      isRandomPlay.value = false;
      isPlayInOrder.value = false;
      isPlayNames.value = false;
      selectedUser.value = null;
      // isCallModeEnabled.value = false;
      await audioPlayer.stop();
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
                Duration(seconds: session.getFormat8TextInterval()));
          }
        }
        if (isPlayNames.value) {
          reset();
        }
      } else {
        final data = studentList.asData?.value ?? [];
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
                  Duration(seconds: session.getFormat8TextInterval()));
            }
          }
          if (isPlayNames.value && student.isEmpty) {
            reset();
          }
        }
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

    Future<void> updateTeacherPhraseCount(bool isBegin) async {
      var count = (isBegin
              ? teacher.eight_tp_begin_frequency
              : teacher.eight_tp_end_frequency) +
          1;
      await ref
          .read(teacherServiceProvider)
          .updateTeacherFormat8TeacherPhrase(count, teacher.id, isBegin);
      await ref
          .read(teacherServiceProvider)
          .getTeacherProfile(Supabase.instance.client.auth.currentUser!.id);
      ref.refresh(sessionManagerProvider);
    }

    //download logic
    final isDownloading = useState(false);
    final downloadedFiles = useState(0);
    final totalFiles = useState(0);
    //boxes
    final isCardDownloaded = useState(false);
    final isCaedExplodedDownloaded = useState(false);
    //all
    final isNamesDownloaded = useState(false);
    final isCallModeDownloaded = useState(false);
    final isTeacherPhraseDownloaded = useState(false);
    //session
    final isSessionRoundsDownloaded = useState(false);
    final isSessionCTPDownloaded = useState(false);
    final isSessionGamePhraseDownloaded = useState(false);
    final isSessionSoundEffectDownloaded = useState(false);
    final isSpecialLanguageDownloaded = useState(false);

    final allCallModes = ref.watch(callModeProvider(teacher.levelId));
    final students = ref.watch(classStudentsProvider(FilterClass(
        classId: teacher?.classId ?? 0,
        schoolId: teacher?.schoolId ?? 0,
        teacherId: teacher?.id ?? 0)));

    final AsyncValue<List<RoundDataModel>> roundsData = ref.watch(
        sessionRoundsDataWithSessionNumberProvider(teacher.formatEightSession));
    final AsyncValue<List<EightChineseTeacherModel>> sessionCTP = ref.watch(
        sessionAllRoundsGroupDataCTPProvider(teacher.formatEightSession));
    final AsyncValue<List<SoundEffectModel>> sessionSoundEffects =
        ref.watch(sessionAllSoundEffectsProvider(teacher.formatEightSession));
    final AsyncValue<List<EightGamePhraseModel>> sessionGamePhrases = ref.watch(
        sessionAllRoundsGroupDataGamePhraseProvider(
            teacher.formatEightSession));
    final teacherPhrasesDownload = ref.watch(teacherPhrasesProvider);
    final specialLanguage = ref.watch(
        format8SessionSpecialLanguageProvider(teacher.formatEightSession));

    Future<void> downloadFile(String url) async {
      DefaultCacheManager().getSingleFile(url).then((value) {
        downloadedFiles.value += 1;
        // print(
        //     "downloaded ${isCallModeDownloaded.value}, ${isNamesDownloaded.value}, ${isCaedExplodedDownloaded.value}, ${isSessionRoundsDownloaded.value}, ${isSessionCTPDownloaded.value}, ${isSessionGamePhraseDownloaded.value}, ${isSessionSoundEffectDownloaded.value}, ${isCardDownloaded.value}, ${isSpecialLanguageDownloaded.value}");
        if (isCallModeDownloaded.value &&
            isNamesDownloaded.value &&
            isCaedExplodedDownloaded.value &&
            isSessionRoundsDownloaded.value &&
            isSessionCTPDownloaded.value &&
            isSessionGamePhraseDownloaded.value &&
            isSessionSoundEffectDownloaded.value &&
            isTeacherPhraseDownloaded.value &&
            isSpecialLanguageDownloaded.value &&
            isCardDownloaded.value) {
          if (totalFiles.value == downloadedFiles.value) {
            isDownloading.value = false;
          }
        }
      });
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

    void downloadTeacherPhrase(List<TeacherPhraseModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.en_audio);
        }
        if (element.ch_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.ch_audio);
        }
      });
      isTeacherPhraseDownloaded.value = true;
    }

    void downloadSessionSoundEffect(List<SoundEffectModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.audio_link.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.audio_link);
        }
      });
      isSessionSoundEffectDownloaded.value = true;
    }

    void downloadSessionGamePhrase(List<EightGamePhraseModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.audio_link.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.audio_link);
        }
        if (element.suf_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.suf_audio);
        }
        if (element.pre_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.pre_audio);
        }
      });
      isSessionGamePhraseDownloaded.value = true;
    }

    void downloadSessionCTP(List<EightChineseTeacherModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.audio_link.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.audio_link);
        }
      });
      isSessionCTPDownloaded.value = true;
    }

    void downloadRoundsData(List<RoundDataModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.std_ch_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.std_ch_audio);
        }
        if (element.std_en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.std_en_audio);
        }
        if (element.std_en_pre.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.std_en_pre);
        }
        if (element.std_en_suf.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.std_en_suf);
        }
        if (element.std_ch_pre.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.std_ch_pre);
        }
        if (element.std_ch_suf.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.std_ch_suf);
        }

        if (element.ctp_ch_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.ctp_ch_audio);
        }
        if (element.etp_en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.etp_en_audio);
        }
        if (element.etp_pre_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.etp_pre_audio);
        }
        if (element.etp_suf_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.etp_suf_audio);
        }
        if (element.eti_en_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.eti_en_audio);
        }
        if (element.eti_suf_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.eti_suf_audio);
        }
        if (element.eti_pre_audio.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.eti_pre_audio);
        }
      });
      isSessionRoundsDownloaded.value = true;
    }

    void downloadFiles(List<BoxCardModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.chineseAudioLink.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.chineseAudioLink);
        }
        if (element.englishAudioLink.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.englishAudioLink);
        }
      });
      isCardDownloaded.value = true;
    }

    void downloadBoxExplodedAudio(List<EightBoxExplodedAudioModel> list) {
      isDownloading.value = true;
      list.forEach((element) {
        if (element.audio_link.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.audio_link);
        }
      });
      isCaedExplodedDownloaded.value = true;
    }

    Future<void> downloadNames(List<StudentModel> list) async {
      isDownloading.value = true;
      List<int> ids = [];
      list.forEach((element) {
        if (element.englishNameModel != null &&
            element.englishNameModel!.audioLink.isNotEmpty) {
          totalFiles.value += 1;
          downloadFile(element.englishNameModel!.audioLink);
        }
        ids.add(element.getFormat8BoxId(teacher.formatEightSession));
      });
      final cards = await ref.read(format8Service).getBoxCardsFromList(ids);
      downloadFiles(cards);
      final explodedCardAudios =
          await ref.read(format8Service).getBoxExplodedAudioFromList(ids);
      downloadBoxExplodedAudio(explodedCardAudios);
      isNamesDownloaded.value = true;
      if (isCallModeDownloaded.value &&
          isNamesDownloaded.value &&
          isCaedExplodedDownloaded.value &&
          isSessionRoundsDownloaded.value &&
          isSessionCTPDownloaded.value &&
          isSessionGamePhraseDownloaded.value &&
          isSessionSoundEffectDownloaded.value &&
          isTeacherPhraseDownloaded.value &&
          isSpecialLanguageDownloaded.value &&
          isCardDownloaded.value) {
        if (totalFiles.value == downloadedFiles.value) {
          isDownloading.value = false;
        }
      }
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

    ref.listen(
        format8SessionSpecialLanguageProvider(teacher.formatEightSession),
        (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadSpecialLanguage(next.asData!.value);
        } else {
          isSpecialLanguageDownloaded.value = true;
        }
      }
    });
    ref.listen(teacherPhrasesProvider, (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadTeacherPhrase(next.asData!.value);
        } else {
          isTeacherPhraseDownloaded.value = true;
        }
      }
    });
    ref.listen(sessionAllSoundEffectsProvider(teacher.formatEightSession),
        (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadSessionSoundEffect(next.asData!.value);
        } else {
          isSessionSoundEffectDownloaded.value = true;
        }
      }
    });
    ref.listen(
        sessionAllRoundsGroupDataGamePhraseProvider(teacher.formatEightSession),
        (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadSessionGamePhrase(next.asData!.value);
        } else {
          isSessionGamePhraseDownloaded.value = true;
        }
      }
    });
    ref.listen(sessionAllRoundsGroupDataCTPProvider(teacher.formatEightSession),
        (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadSessionCTP(next.asData!.value);
        } else {
          isSessionCTPDownloaded.value = true;
        }
      }
    });
    ref.listen(
        sessionRoundsDataWithSessionNumberProvider(teacher.formatEightSession),
        (previous, next) {
      if (next.asData?.value != null) {
        if (next.asData!.value.isNotEmpty) {
          downloadRoundsData(next.asData!.value);
        } else {
          isSessionRoundsDownloaded.value = true;
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
      Future.microtask(() {
        if (roundsList.asData?.value != null) {
          final list = roundsList.asData!.value;
          if (list.isNotEmpty) {
            final res = list.firstWhereOrNull(
                (element) => element.round == teacher.format_eight_round);
            if (res != null) {
              selectedRound.value = res;
              selectedGroup.value = "A";
              ref.refresh(sessionCurrentRoundsDataWithSessionNumberProvider(
                  Format8FilterClass(
                      sessionId: teacher.formatEightSession,
                      roundId: selectedRound.value?.id ?? 0,
                      group: selectedGroup.value)));
            } else {
              selectedRound.value = null;
            }
          }
        }
      });
      if (specialLanguage.asData?.value != null) {
        if (specialLanguage.asData!.value.isNotEmpty) {
          downloadSpecialLanguage(specialLanguage.asData!.value);
        } else {
          isSpecialLanguageDownloaded.value = true;
        }
      }
      if (teacherPhrasesDownload.asData?.value != null) {
        if (teacherPhrasesDownload.asData!.value.isNotEmpty) {
          downloadTeacherPhrase(teacherPhrasesDownload.asData!.value);
        } else {
          isTeacherPhraseDownloaded.value = true;
        }
      }
      if (sessionGamePhrases.asData?.value != null) {
        if (sessionGamePhrases.asData!.value.isNotEmpty) {
          downloadSessionGamePhrase(sessionGamePhrases.asData!.value);
        } else {
          isSessionGamePhraseDownloaded.value = true;
        }
      }
      if (sessionSoundEffects.asData?.value != null) {
        if (sessionSoundEffects.asData!.value.isNotEmpty) {
          downloadSessionSoundEffect(sessionSoundEffects.asData!.value);
        } else {
          isSessionSoundEffectDownloaded.value = true;
        }
      }
      if (sessionCTP.asData?.value != null) {
        if (sessionCTP.asData?.value != null) {
          if (sessionCTP.asData!.value.isNotEmpty) {
            downloadSessionCTP(sessionCTP.asData!.value);
          } else {
            isSessionCTPDownloaded.value = true;
          }
        }
      }
      if (roundsData.asData?.value != null) {
        if (roundsData.asData?.value != null) {
          if (roundsData.asData!.value.isNotEmpty) {
            downloadRoundsData(roundsData.asData!.value);
          } else {
            isSessionRoundsDownloaded.value = true;
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
    return WillPopScope(
      onWillPop: () async {
        NavManager().goBack();
        return false;
      },
      child: FocusDetector(
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
                                    LocaleKeys.stem.tr(),
                                    style: TextStyle(
                                        color: AppColors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "${LocaleKeys.session.tr()} ${teacher.formatEightSession}",
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
                              if (roundsList.asData?.value == null) {
                                return;
                              }
                              // if (last == null) {
                              //   return;
                              // }
                              if (selectedRound.value != null &&
                                  roundsList.asData!.value.isNotEmpty) {
                                final last = roundsList.asData!.value.last;
                                if (selectedRound.value!.round <= last.round) {
                                  DialogHelper.showError(context.tr(LocaleKeys
                                      .finish_all_rounds_confirmation));
                                  return;
                                }
                              }

                              if (teacher.levelId == 1 &&
                                  teacher.formatEightSession > 59) {
                                DialogHelper.showError(context
                                    .tr(LocaleKeys.cannot_create_new_session));
                                return;
                              }
                              if (teacher.levelId == 2 &&
                                  teacher.formatEightSession > 179) {
                                DialogHelper.showError(context
                                    .tr(LocaleKeys.cannot_create_new_session));
                                return;
                              }
                              if (teacher.levelId == 3 &&
                                  teacher.formatEightSession < 299) {
                                DialogHelper.showError(context
                                    .tr(LocaleKeys.cannot_create_new_session));
                                return;
                              }
                              DialogHelper.showConfirmationDialog(
                                  LocaleKeys.start_next_session.tr(),
                                  (p0) async {
                                if (p0) {
                                  await ref
                                      .read(teacherServiceProvider)
                                      .updateFormat8Session(
                                          (teacher.formatEightSession ?? 1) + 1,
                                          teacher.id ?? 0);
                                  await ref
                                      .read(teacherServiceProvider)
                                      .getTeacherProfile(Supabase.instance
                                          .client.auth.currentUser!.id);
                                  ref.refresh(sessionManagerProvider);
                                  ref.refresh(classStudentsProvider(FilterClass(
                                      classId: teacher?.classId ?? 0,
                                      schoolId: teacher?.schoolId ?? 0,
                                      teacherId: teacher?.id ?? 0)));
                                  ref.refresh(
                                      sessionRoundsWithSessionNumberProvider(
                                          teacher.formatEightSession));
                                  ref.refresh(
                                      sessionRoundsWithSessionNumberProvider(
                                          teacher.formatEightSession));
                                  ref.refresh(
                                      sessionCurrentRoundsDataWithSessionNumberProvider(
                                          Format8FilterClass(
                                              sessionId:
                                                  teacher.formatEightSession,
                                              roundId:
                                                  selectedRound.value?.id ?? 0,
                                              group: selectedGroup.value)));
                                  ref.refresh(sessionRoundsGroupDataCTPProvider(
                                      roundDataItem.asData?.value?.id ?? 0));
                                  ref.refresh(
                                      sessionRoundsGroupDataGamePhraseProvider(
                                          roundDataItem.asData?.value?.id ??
                                              0));

                                  ref.refresh(sessionGroupSoundProvider(
                                    FilterClass(
                                        classId: 0,
                                        schoolId: 0,
                                        session: teacher.formatEightSession,
                                        format: selectedGroup.value),
                                  ));
                                  selectedGroup.value = "A";
                                  selectedColor.value =
                                      getGroupColor(selectedGroup.value);
                                  ref.refresh(
                                      classStudentsFormat8SortedProvider(
                                          FilterClass(
                                              classId: teacher?.classId ?? 0,
                                              schoolId: teacher?.schoolId ?? 0,
                                              teacherId: teacher?.id ?? 0,
                                              groupColor:
                                                  selectedColor.value)));
                                  isFirstTime.value = true;
                                  sessionCTPComboPlay.value = 0;
                                }
                              });
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
                                    NavManager().goTo(const Format8GroupScreen(
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
                                                              .saveFormat8AudioMode(
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
                                                              .saveFormat8TextInterval(int.parse(
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
                                                              .saveFormat8ENGCHNInterval(int.parse(
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
                          // GestureDetector(
                          //   onTap: () {
                          //     NavManager().goTo(const Format8SettingScreen());
                          //   },
                          //   child: Image.asset(
                          //     Assets.imagesSetting,
                          //     height: 24,
                          //     width: 24,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: ListView(
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
                                  width: 10,
                                ),
                                TopItem(
                                    image: Assets.imagesIcons8LanguageSkill,
                                    title: LocaleKeys.special_language.tr(),
                                    isSelected: isSpecialLanguageShown.value,
                                    callback: () {
                                      isSpecialLanguageShown.value =
                                          !isSpecialLanguageShown.value;
                                      // NavManager().goTo(Format8SpecialLanguage(
                                      //     sessionModel?.id ?? 0,
                                      //     selectedGroup.value));
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
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final item = items[index];
                                                return SpecialLanguageItem(
                                                  languageModel: item,
                                                  closeTapped: () {},
                                                  isLoop: false,
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
                                                            .getForma8tAudioMode() ==
                                                        AudioMode.chinese) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ch_audio);
                                                    } else if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode.english) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.en_audio);
                                                    } else if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode
                                                            .englishAndChinese) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.en_audio);
                                                      Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormat8ENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ch_audio);
                                                    } else if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode
                                                            .chineseAndEnglish) {
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.ch_audio);
                                                      Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormat8ENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.en_audio);
                                                    }
                                                  },
                                                  studentTapped: () async {
                                                    reset();
                                                    if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode.chinese) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .ch_std_audio);
                                                    } else if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode.english) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .en_std_audio);
                                                    } else if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode
                                                            .englishAndChinese) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .en_std_audio);
                                                      Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormat8ENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .ch_std_audio);
                                                    } else if (session
                                                            .getForma8tAudioMode() ==
                                                        AudioMode
                                                            .chineseAndEnglish) {
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .ch_std_audio);
                                                      Future.delayed(Duration(
                                                          seconds: session
                                                              .getFormat8ENGCHNInterval()));
                                                      await audioPlayer
                                                          .playAndCache(item
                                                              .en_std_audio);
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
                                                              .getForma8tAudioMode() ==
                                                          AudioMode.english) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .action_en_audio);
                                                      } else if (session
                                                              .getForma8tAudioMode() ==
                                                          AudioMode.chinese) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .action_ch_audio);
                                                      } else if (session
                                                              .getForma8tAudioMode() ==
                                                          AudioMode
                                                              .englishAndChinese) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .action_en_audio);
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .action_ch_audio);
                                                      } else if (session
                                                              .getForma8tAudioMode() ==
                                                          AudioMode
                                                              .chineseAndEnglish) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .action_ch_audio);
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
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
                                                              .getForma8tAudioMode() ==
                                                          AudioMode.english) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .ad_en_audio);
                                                      } else if (session
                                                              .getForma8tAudioMode() ==
                                                          AudioMode.chinese) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .ad_ch_audio);
                                                      } else if (session
                                                              .getForma8tAudioMode() ==
                                                          AudioMode
                                                              .englishAndChinese) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .ad_en_audio);
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .ad_ch_audio);
                                                      } else if (session
                                                              .getForma8tAudioMode() ==
                                                          AudioMode
                                                              .chineseAndEnglish) {
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .ad_ch_audio);
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                        await audioPlayer
                                                            .playAndCache(item
                                                                .ad_en_audio);
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
                            SizedBox(
                              height: 40,
                              child: Container(
                                child: teacherPhrases.when(data: (items) {
                                  return items.isEmpty
                                      ? CenterErrorView(
                                          errorMsg: context
                                              .tr(LocaleKeys.no_sentence_found),
                                        )
                                      : ListView.separated(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          itemCount: items.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final item = items[index];
                                            return _TeacherPhraseItem(
                                                model: item,
                                                isSelected: false,
                                                callback: () async {
                                                  updateTeacherPhraseCount(
                                                      item.is_start);
                                                  if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode.english) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode.chinese) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_audio);
                                                  } else if (session
                                                          .getFormatAudioMode() ==
                                                      AudioMode
                                                          .englishAndChinese) {
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.en_audio);
                                                    await Future.delayed(Duration(
                                                        seconds: session
                                                            .getFormatENGCHNInterval()));
                                                    await audioPlayer
                                                        .playAndCache(
                                                            item.ch_audio);
                                                  }
                                                });
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return const SizedBox(width: 10);
                                          },
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
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 44,
                              child: studentList.when(data: (items) {
                                checkFirstSelectedGroup();
                                return ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _GroupSelectedItem(
                                        title: selectedGroup.value,
                                        bg: getGroupColor(selectedGroup.value),
                                        callback: () {}),
                                    Visibility(
                                      visible:
                                          studentListGroupA.asData?.value !=
                                                  null &&
                                              studentListGroupA
                                                  .asData!.value.isNotEmpty,
                                      child: studentListGroupA.when(
                                          data: (items) {
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            _GroupItem(
                                                title: "A",
                                                bg: getGroupColor("A"),
                                                isSelected:
                                                    selectedGroup.value == "A",
                                                callback: () {
                                                  sessionCTPComboPlay.value = 0;
                                                  selectedGroup.value = "A";
                                                  selectedColor.value =
                                                      getGroupColor("A");
                                                }),
                                          ],
                                        );
                                      }, error: (Object error,
                                              StackTrace stackTrace) {
                                        return const Text("");
                                      }, loading: () {
                                        return const Text("");
                                      }),
                                    ),
                                    Visibility(
                                      visible:
                                          studentListGroupB.asData?.value !=
                                                  null &&
                                              studentListGroupB
                                                  .asData!.value.isNotEmpty,
                                      child: studentListGroupB.when(
                                          data: (items) {
                                        // if (studentListGroupA.asData?.value !=
                                        //         null &&
                                        //     studentListGroupA
                                        //         .asData!.value.isEmpty) {
                                        //   selectedGroup.value = "B";
                                        //   selectedColor.value =
                                        //       getGroupColor("B");
                                        // }
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            _GroupItem(
                                                title: "B",
                                                bg: getGroupColor("B"),
                                                isSelected:
                                                    selectedGroup.value == "B",
                                                callback: () {
                                                  sessionCTPComboPlay.value = 0;
                                                  selectedGroup.value = "B";
                                                  selectedColor.value =
                                                      getGroupColor("B");
                                                }),
                                          ],
                                        );
                                      }, error: (Object error,
                                              StackTrace stackTrace) {
                                        return const Text("");
                                      }, loading: () {
                                        return const Text("");
                                      }),
                                    ),
                                    Visibility(
                                      visible:
                                          studentListGroupC.asData?.value !=
                                                  null &&
                                              studentListGroupC
                                                  .asData!.value.isNotEmpty,
                                      child: studentListGroupC.when(
                                          data: (items) {
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            _GroupItem(
                                                title: "C",
                                                bg: getGroupColor("C"),
                                                isSelected:
                                                    selectedGroup.value == "C",
                                                callback: () {
                                                  sessionCTPComboPlay.value = 0;
                                                  selectedGroup.value = "C";
                                                  selectedColor.value =
                                                      getGroupColor("C");
                                                }),
                                          ],
                                        );
                                      }, error: (Object error,
                                              StackTrace stackTrace) {
                                        return const Text("");
                                      }, loading: () {
                                        return const Text("");
                                      }),
                                    ),
                                    Visibility(
                                      visible:
                                          studentListGroupD.asData?.value !=
                                                  null &&
                                              studentListGroupD
                                                  .asData!.value.isNotEmpty,
                                      child: studentListGroupD.when(
                                          data: (items) {
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            _GroupItem(
                                                title: "D",
                                                bg: getGroupColor("D"),
                                                isSelected:
                                                    selectedGroup.value == "D",
                                                callback: () {
                                                  sessionCTPComboPlay.value = 0;
                                                  selectedGroup.value = "D";
                                                  selectedColor.value =
                                                      getGroupColor("D");
                                                }),
                                          ],
                                        );
                                      }, error: (Object error,
                                              StackTrace stackTrace) {
                                        return const Text("");
                                      }, loading: () {
                                        return const Text("");
                                      }),
                                    ),
                                    Visibility(
                                      visible:
                                          studentListGroupE.asData?.value !=
                                                  null &&
                                              studentListGroupE
                                                  .asData!.value.isNotEmpty,
                                      child: studentListGroupE.when(
                                          data: (items) {
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            _GroupItem(
                                                title: "E",
                                                bg: getGroupColor("E"),
                                                isSelected:
                                                    selectedGroup.value == "E",
                                                callback: () {
                                                  sessionCTPComboPlay.value = 0;
                                                  selectedGroup.value = "E";
                                                  selectedColor.value =
                                                      getGroupColor("E");
                                                }),
                                          ],
                                        );
                                      }, error: (Object error,
                                              StackTrace stackTrace) {
                                        return const Text("");
                                      }, loading: () {
                                        return const Text("");
                                      }),
                                    ),
                                    Visibility(
                                      visible:
                                          studentListGroupF.asData?.value !=
                                                  null &&
                                              studentListGroupF
                                                  .asData!.value.isNotEmpty,
                                      child: studentListGroupF.when(
                                          data: (items) {
                                        return Row(
                                          children: [
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            _GroupItem(
                                                title: "F",
                                                bg: getGroupColor("F"),
                                                isSelected:
                                                    selectedGroup.value == "F",
                                                callback: () {
                                                  sessionCTPComboPlay.value = 0;
                                                  selectedGroup.value = "F";
                                                  selectedColor.value =
                                                      getGroupColor("F");
                                                }),
                                          ],
                                        );
                                      }, error: (Object error,
                                              StackTrace stackTrace) {
                                        return const Text("");
                                      }, loading: () {
                                        return const Text("");
                                      }),
                                    ),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // _GroupItem(
                                    //     title: "B",
                                    //     bg: getGroupColor("B"),
                                    //     isSelected: selectedGroup.value == "B",
                                    //     callback: () {
                                    //       sessionCTPComboPlay.value = 0;
                                    //       selectedGroup.value = "B";
                                    //       selectedColor.value =
                                    //           getGroupColor("B");
                                    //     }),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // _GroupItem(
                                    //     title: "C",
                                    //     bg: getGroupColor("C"),
                                    //     isSelected: selectedGroup.value == "C",
                                    //     callback: () {
                                    //       sessionCTPComboPlay.value = 0;
                                    //       selectedGroup.value = "C";
                                    //       selectedColor.value =
                                    //           getGroupColor("C");
                                    //     }),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // _GroupItem(
                                    //     title: "D",
                                    //     bg: getGroupColor("D"),
                                    //     isSelected: selectedGroup.value == "D",
                                    //     callback: () {
                                    //       sessionCTPComboPlay.value = 0;
                                    //       selectedGroup.value = "D";
                                    //       selectedColor.value =
                                    //           getGroupColor("D");
                                    //     }),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // _GroupItem(
                                    //     title: "E",
                                    //     bg: getGroupColor("E"),
                                    //     isSelected: selectedGroup.value == "E",
                                    //     callback: () {
                                    //       sessionCTPComboPlay.value = 0;
                                    //       selectedGroup.value = "E";
                                    //       selectedColor.value =
                                    //           getGroupColor("E");
                                    //     }),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    // _GroupItem(
                                    //     title: "F",
                                    //     bg: getGroupColor("F"),
                                    //     isSelected: selectedGroup.value == "F",
                                    //     callback: () {
                                    //       sessionCTPComboPlay.value = 0;
                                    //       selectedGroup.value = "F";
                                    //       selectedColor.value =
                                    //           getGroupColor("F");
                                    //     }),
                                  ],
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
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF251404),
                                      width: 1)),
                              child: roundDataItem.when(data: (item) {
                                return item == null
                                    ? CenterErrorView(
                                        errorMsg: context
                                            .tr(LocaleKeys.no_sentence_found),
                                      )
                                    : Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    _TeacherPhraseSimpleItem(
                                                        title: item.ctp_text,
                                                        callback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .ctp_ch_audio);
                                                        }),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    _TeacherPhrasePreButtonSimpleItem(
                                                        title: item.etp_text,
                                                        preCallback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .etp_pre_audio);
                                                        },
                                                        sufCallback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .etp_suf_audio);
                                                        },
                                                        callback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .etp_en_audio);
                                                        }),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                height: 86,
                                                child: _ComboItem(
                                                    title: context
                                                        .tr(LocaleKeys.combo),
                                                    callback: () async {
                                                      reset();
                                                      if (sessionCTPList.asData
                                                                  ?.value !=
                                                              null &&
                                                          sessionCTPList
                                                              .asData!
                                                              .value
                                                              .isNotEmpty) {
                                                        var list =
                                                            sessionCTPList
                                                                .asData!.value;
                                                        var item =
                                                            sessionCTPComboPlay
                                                                    .value %
                                                                list.length;
                                                        var element =
                                                            list[item];
                                                        await audioPlayer
                                                            .playAndCache(element
                                                                .audio_link);
                                                        // for (var element
                                                        //     in list) {
                                                        //   await audioPlayer
                                                        //       .playAndCache(element
                                                        //           .audio_link);
                                                        // }
                                                        sessionCTPComboPlay
                                                            .value += 1;
                                                      } else {
                                                        DialogHelper.showError(
                                                            context.tr(LocaleKeys
                                                                .no_audio_found));
                                                      }
                                                    }),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    _TeacherPhrasePreButtonSimpleItem(
                                                        title: item.eti_text,
                                                        preCallback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .eti_pre_audio);
                                                        },
                                                        sufCallback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .eti_suf_audio);
                                                        },
                                                        callback: () async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(item
                                                                  .eti_en_audio);
                                                        }),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child:
                                                    _TeacherPhrasePreButtonSimpleItem(
                                                        title: item.std_text,
                                                        preCallback: () async {
                                                          reset();
                                                          if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .english) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_pre);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chinese) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_pre);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chineseAndEnglish) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_pre);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_pre);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .englishAndChinese) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_pre);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_pre);
                                                          }
                                                        },
                                                        sufCallback: () async {
                                                          reset();
                                                          if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .english) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_suf);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chinese) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_suf);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chineseAndEnglish) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_suf);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_suf);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .englishAndChinese) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_suf);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_suf);
                                                          }
                                                        },
                                                        callback: () async {
                                                          reset();
                                                          if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .english) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_audio);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chinese) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_audio);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chineseAndEnglish) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_audio);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_audio);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .englishAndChinese) {
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_en_audio);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(item
                                                                    .std_ch_audio);
                                                          }
                                                        }),
                                              ),
                                            ],
                                          )
                                        ],
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
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 36,
                              child: Container(
                                child: roundsList.when(data: (items) {
                                  return items.isEmpty
                                      ? CenterErrorView(
                                          errorMsg: context
                                              .tr(LocaleKeys.no_round_found),
                                        )
                                      : Stack(
                                          children: [
                                            Visibility(
                                              visible: items.length > 1,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: selectedRound.value ==
                                                            items.first
                                                        ? 17.0
                                                        : 17),
                                                child: SizedBox(
                                                  width:
                                                      ((items.length - 1) * 56),
                                                  child: const Divider(
                                                    color: Color(0xFF4F3422),
                                                    thickness: 4,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ListView.separated(
                                              itemCount: items.length,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                final item = items[index];
                                                return _RoundItem(
                                                    title:
                                                        item.round.toString(),
                                                    isCompleted:
                                                        selectedRound.value ==
                                                                null
                                                            ? true
                                                            : selectedRound
                                                                    .value!
                                                                    .round >
                                                                item.round,
                                                    isCurrent: item ==
                                                        selectedRound.value,
                                                    callback: () async {
                                                      DialogHelper
                                                          .showConfirmationDialog(
                                                              context.tr(LocaleKeys
                                                                  .finish_round_confirmation),
                                                              (p0) async {
                                                        if (p0) {
                                                          if (items.length >
                                                              index + 1) {
                                                            selectedRound
                                                                    .value =
                                                                items[
                                                                    index + 1];
                                                          } else {
                                                            selectedRound
                                                                .value = null;
                                                          }
                                                          await ref
                                                              .read(
                                                                  teacherServiceProvider)
                                                              .updateFormat8SessionRound(
                                                                  item.round +
                                                                      1,
                                                                  teacher.id);
                                                          await ref
                                                              .read(
                                                                  teacherServiceProvider)
                                                              .getTeacherProfile(
                                                                  teacher.uid);
                                                          ref.refresh(
                                                              sessionManagerProvider);
                                                          sessionCTPComboPlay
                                                              .value = 0;
                                                        }
                                                      });
                                                    });
                                              },
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return const SizedBox(
                                                  width: 20,
                                                );
                                              },
                                            ),
                                          ],
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
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onHorizontalDragEnd: (dragDetail) {
                                if (dragDetail.velocity.pixelsPerSecond.dx >
                                    0) {
                                  // User swiped Left
                                  isGameMode.value = false;
                                } else if (dragDetail
                                        .velocity.pixelsPerSecond.dx <
                                    0) {
                                  // User swiped Right
                                  isGameMode.value = true;
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            MenuItem1(
                                                isPlaying: isPlayNames.value,
                                                image: isPlayNames.value
                                                    ? Assets.imagesStop
                                                    : Assets.imagesName,
                                                title:
                                                    LocaleKeys.play_name.tr(),
                                                title1: LocaleKeys.play_in_order
                                                    .tr(),
                                                title2:
                                                    LocaleKeys.random_play.tr(),
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
                                              width: 5,
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
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            if (isGameMode.value)
                                              Expanded(
                                                child: SizedBox(
                                                  height: 25,
                                                  child: sessionGamePhrase.when(
                                                      data: (items) {
                                                    return items.isEmpty
                                                        ? CenterErrorView(
                                                            errorMsg: context
                                                                .tr(LocaleKeys
                                                                    .no_sentence_found),
                                                          )
                                                        : ListView.separated(
                                                            primary: true,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount:
                                                                items.length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              final item =
                                                                  items[index];

                                                              return _WordItem(
                                                                  verticalPadding:
                                                                      4,
                                                                  title:
                                                                      item.text,
                                                                  callback:
                                                                      () async {
                                                                    reset();
                                                                    await audioPlayer
                                                                        .playAndCache(
                                                                            item.pre_audio);
                                                                    await audioPlayer
                                                                        .playAndCache(
                                                                            item.audio_link);
                                                                    await audioPlayer
                                                                        .playAndCache(
                                                                            item.suf_audio);
                                                                  });
                                                            },
                                                            separatorBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              return const SizedBox(
                                                                width: 10,
                                                              );
                                                            },
                                                          );
                                                  }, error: (err, trace) {
                                                    debugPrint(
                                                        "Error occurred while fetching elements: $err");
                                                    return CenterErrorView(
                                                      errorMsg: context.tr(
                                                          LocaleKeys
                                                              .error_fetching_element),
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
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          child:
                                              studentList.when(data: (items) {
                                            return items.isEmpty
                                                ? CenterErrorView(
                                                    errorMsg: context.tr(
                                                        LocaleKeys
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

                                                      return _StudentItem(
                                                        isSelected: selectedUser
                                                                .value ==
                                                            item,
                                                        studentModel: item,
                                                        round: selectedRound
                                                                .value?.round ??
                                                            0,
                                                        session: teacher
                                                            .formatEightSession,
                                                        nameTapped: () async {
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
                                                        comboTapped:
                                                            (EightBoxExplodedAudioModel
                                                                value) async {
                                                          reset();
                                                          await audioPlayer
                                                              .playAndCache(value
                                                                  .audio_link);
                                                          // for (var element
                                                          //     in value) {
                                                          //   await audioPlayer
                                                          //       .playAndCache(
                                                          //           element
                                                          //               .audio_link);
                                                          // }
                                                        },
                                                        cardTapped:
                                                            (BoxCardModel
                                                                value) async {
                                                          reset();
                                                          if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .english) {
                                                            await audioPlayer
                                                                .playAndCache(value
                                                                    .englishAudioLink);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chinese) {
                                                            await audioPlayer
                                                                .playAndCache(value
                                                                    .chineseAudioLink);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .englishAndChinese) {
                                                            await audioPlayer
                                                                .playAndCache(value
                                                                    .englishAudioLink);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(value
                                                                    .chineseAudioLink);
                                                          } else if (session
                                                                  .getForma8tAudioMode() ==
                                                              AudioMode
                                                                  .chineseAndEnglish) {
                                                            await audioPlayer
                                                                .playAndCache(value
                                                                    .chineseAudioLink);
                                                            Future.delayed(Duration(
                                                                seconds: session
                                                                    .getFormat8ENGCHNInterval()));
                                                            await audioPlayer
                                                                .playAndCache(value
                                                                    .englishAudioLink);
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: isGameMode.value,
                                    child: const SizedBox(
                                      width: 10,
                                    ),
                                  ),
                                  if (isGameMode.value)
                                    Container(
                                      width: 40,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.brown,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: soundEffect.when(data: (items) {
                                        return items.isEmpty
                                            ? const CenterErrorView(
                                                errorMsg: "",
                                              )
                                            : ListView.separated(
                                                primary: false,
                                                shrinkWrap: true,
                                                itemCount: items.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  final item = items[index];
                                                  return GestureDetector(
                                                    onTap: () async {
                                                      reset();
                                                      await audioPlayer
                                                          .playAndCache(
                                                              item.audio_link);
                                                    },
                                                    child: Container(
                                                      height: 24,
                                                      width: 24,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.lightBlue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return const SizedBox(
                                                    height: 10,
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
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
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
                visible: showImage.value && imageLink.value.isNotEmpty,
                child: ImageView(
                  imageUrl: imageLink.value,
                  callback: () {
                    showImage.value = false;
                    imageLink.value = "";
                  },
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
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherPhraseItem extends StatelessWidget {
  final TeacherPhraseModel model;
  final bool isSelected;
  final VoidCallback callback;
  const _TeacherPhraseItem(
      {super.key,
      required this.model,
      required this.isSelected,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.brown),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 1.4,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            model.is_start
                ? context.tr(LocaleKeys.beginning_language)
                : context.tr(LocaleKeys.ending_language),
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupSelectedItem extends StatelessWidget {
  final String title;
  final Color bg;
  final VoidCallback callback;
  const _GroupSelectedItem(
      {super.key,
      required this.title,
      required this.callback,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: const Color(0xFF251404), width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 1.4,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: const Icon(
        Icons.play_circle,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  final String title;
  final Color bg;
  final VoidCallback callback;
  final bool isSelected;
  const _GroupItem(
      {super.key,
      required this.title,
      required this.callback,
      required this.bg,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: const Color(0xFF251404), width: 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              spreadRadius: 0,
              blurRadius: 1.4,
              offset: const Offset(0, 4), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.play_circle,
              size: 20,
              color: Colors.white,
            ),
            const VerticalDivider(
              thickness: 1,
              color: Colors.white,
            ),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : null),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherPhraseSimpleItem extends StatelessWidget {
  final String title;
  final VoidCallback callback;
  final double? height;
  const _TeacherPhraseSimpleItem(
      {super.key, required this.title, required this.callback, this.height});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF251404), width: 1),
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
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherPhrasePreButtonSimpleItem extends StatelessWidget {
  final String title;
  final VoidCallback callback;
  final VoidCallback preCallback;
  final VoidCallback sufCallback;
  final double? height;

  const _TeacherPhrasePreButtonSimpleItem(
      {super.key,
      required this.title,
      required this.callback,
      this.height,
      required this.preCallback,
      required this.sufCallback});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF251404), width: 1),
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
            ImageButton(
              image: Assets.imagesPlay,
              callback: preCallback,
              btnSize: 24,
              iconSize: 24,
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ImageButton(
              image: Assets.imagesPlay,
              callback: sufCallback,
              btnSize: 24,
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboItem extends StatelessWidget {
  final String title;
  final VoidCallback callback;
  const _ComboItem({super.key, required this.title, required this.callback});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.yellow,
          border: Border.all(color: const Color(0xFF251404), width: 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE4B97D),
              spreadRadius: 0,
              blurRadius: 0,
              offset: Offset(0, 4), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.play_circle,
              size: 20,
              color: Color(0xFF251404),
            ),
            const VerticalDivider(
              thickness: 1,
              color: Color(0xFF4F3422),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF4F3422),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundItem extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback callback;
  const _RoundItem(
      {super.key,
      required this.title,
      required this.isCompleted,
      required this.isCurrent,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF88D7DE)
                    : isCurrent
                        ? const Color(0xFFFFCF8C)
                        : Colors.white,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF251404)
                      : isCurrent
                          ? const Color(0xFFFABC74)
                          : const Color(0xFFBBBBBB),
                )),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white,
                    )
                  : Text(
                      title,
                      style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : const Color(0xFFBBBBBB),
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
            ),
          ),
          Visibility(
              visible: isCurrent,
              child: Column(
                children: [
                  const SizedBox(
                    height: 2,
                  ),
                  GestureDetector(
                    onTap: callback,
                    child: Container(
                        height: 13,
                        width: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFABC74),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            context.tr(LocaleKeys.done),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400),
                          ),
                        )),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

class _StudentItem extends HookConsumerWidget {
  final StudentModel studentModel;
  final int session;
  // final BoxD? cardModel;
  final ValueSetter<BoxCardModel> cardTapped;
  final ValueSetter<EightBoxExplodedAudioModel> comboTapped;
  final VoidCallback nameTapped;
  final int round;
  final bool isSelected;
  const _StudentItem({
    super.key,
    required this.studentModel,
    required this.session,
    required this.nameTapped,
    required this.comboTapped,
    required this.cardTapped,
    required this.round,
    required this.isSelected,
    // required this.cardTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxItem = ref
        .watch(boxRoundProvider(FilterClass(
            classId: round, schoolId: studentModel.getFormat8BoxId(session))))
        .asData
        ?.value;
    //box data from box id
    //studentModel.getFormat8BoxId(session)
    final AsyncValue<List<BoxCardModel>> boxData =
        ref.watch(boxCardsProvider(boxItem?.id ?? 0));
    // //box from session
    // final box = ref
    //     .watch(boxProvider(studentModel.getFormat8BoxId(session)))
    //     .asData
    //     ?.value;
    //exploded audio from box id
    //studentModel.getFormat8BoxId(session)
    final List<EightBoxExplodedAudioModel>? explodedAudio = ref
        .watch(sessionBoxExplodedAudioProvider(boxItem?.id ?? 0))
        .asData
        ?.value;
    final comboPlayCount = useState(0);
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 60,
              width: 60,
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // box != null ? box.title : "-",
                      // ${boxItem != null ? boxItem.title : "-"}
                      "${studentModel.getBoxTitle(session)}",
                      style: TextStyle(
                          color: AppColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            ButtonAnimationWidget(
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
            ),
          ],
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
            child: boxData.when(data: (items) {
              var sentences =
                  items.where((element) => !element.is_word).toList();
              var words = items.where((element) => element.is_word).toList();
              return items.isEmpty
                  ? CenterErrorView(
                      errorMsg: context.tr(LocaleKeys.no_sentence_found),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 60,
                          child: Row(
                            // scrollDirection: Axis.horizontal,
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  primary: true,
                                  shrinkWrap: false,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: sentences.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final item = sentences[index];
                                    return _TeacherPhraseSimpleItem(
                                        title: item.text,
                                        height: 60,
                                        callback: () {
                                          cardTapped(item);
                                        });
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return const SizedBox(
                                      width: 10,
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible: sentences.isNotEmpty,
                                child: const SizedBox(
                                  width: 10,
                                ),
                              ),
                              _ComboItem(
                                  title: context.tr(LocaleKeys.combo),
                                  callback: () {
                                    if (explodedAudio != null &&
                                        explodedAudio.isNotEmpty) {
                                      var index = comboPlayCount.value %
                                          explodedAudio.length;
                                      var element = explodedAudio[index];
                                      comboTapped(element);
                                      comboPlayCount.value += 1;
                                    } else {
                                      DialogHelper.showError(context
                                          .tr(LocaleKeys.no_audio_found));
                                    }
                                  }),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            primary: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: words.length,
                            itemBuilder: (BuildContext context, int index) {
                              final item = words[index];
                              return _WordItem(
                                  verticalPadding: 2,
                                  title: item.text,
                                  callback: () {
                                    cardTapped(item);
                                  });
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                width: 10,
                              );
                            },
                          ),
                        ),
                      ],
                    );
            }, error: (err, trace) {
              debugPrint("Error occurred while fetching elements: $err");
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
        // Text("box number ${studentModel.getFormat8BoxId(session)}")
      ],
    );
  }
}

class _WordItem extends StatelessWidget {
  final String title;
  final VoidCallback callback;
  final double verticalPadding;
  const _WordItem(
      {super.key,
      required this.title,
      required this.callback,
      this.verticalPadding = 12});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF251404), width: 1),
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
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
