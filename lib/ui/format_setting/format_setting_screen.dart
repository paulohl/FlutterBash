import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/constants/app_constants.dart';
import 'package:xueli/data/session_manager/session_manager.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/ui/widgets/custom_app_bar.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

class FormatSettingScreen extends HookConsumerWidget {
  const FormatSettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionManagerProvider);
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
                  CustomAppBar2(title: context.tr(LocaleKeys.settings)),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.audio_mode.tr(),
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
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
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
                                color: AppColors.black,
                              ),
                              elevation: 16,
                              selectedItemBuilder: (BuildContext context) {
                                return audioModeList.map<Widget>((String item) {
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    constraints:
                                        const BoxConstraints(minWidth: 100),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList();
                              },
                              style: TextStyle(color: AppColors.textFieldText),
                              value: selectedAudioMode.value,
                              onChanged: (String? Value) {
                                if (Value != null) {
                                  selectedAudioMode.value = Value;
                                }
                              },
                              items: audioModeList.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.text_interval.tr(),
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
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
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
                                color: AppColors.black,
                              ),
                              elevation: 16,
                              selectedItemBuilder: (BuildContext context) {
                                return timeIntervalList
                                    .map<Widget>((String item) {
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    constraints:
                                        const BoxConstraints(minWidth: 100),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList();
                              },
                              style: TextStyle(color: AppColors.textFieldText),
                              value: selectedTextInterval.value,
                              onChanged: (String? Value) {
                                if (Value != null) {
                                  selectedTextInterval.value = Value;
                                }
                              },
                              items: timeIntervalList.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "ENG&CHN ${LocaleKeys.interval.tr()}",
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
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
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
                                color: AppColors.black,
                              ),
                              elevation: 16,
                              selectedItemBuilder: (BuildContext context) {
                                return timeIntervalList
                                    .map<Widget>((String item) {
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    constraints:
                                        const BoxConstraints(minWidth: 100),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList();
                              },
                              style: TextStyle(color: AppColors.textFieldText),
                              value: selectedENGCHNInterval.value,
                              onChanged: (String? Value) {
                                if (Value != null) {
                                  selectedENGCHNInterval.value = Value;
                                }
                              },
                              items: timeIntervalList.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(
                                    type,
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
                  const SizedBox(
                    height: 20,
                  ),
                  CoreButton(
                    label: context.tr(LocaleKeys.update),
                    onPressed: () async {
                      await ref
                          .read(sessionManagerProvider)
                          .saveFormatAudioMode(selectedAudioMode.value);
                      await ref
                          .read(sessionManagerProvider)
                          .saveFormatENGCHNInterval(int.parse(
                              selectedENGCHNInterval.value
                                  .replaceAll("s", "")));
                      await ref
                          .read(sessionManagerProvider)
                          .saveFormatTextInterval(int.parse(
                              selectedTextInterval.value.replaceAll("s", "")));
                      ref.refresh(sessionManagerProvider);
                      NavManager().goBack();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
