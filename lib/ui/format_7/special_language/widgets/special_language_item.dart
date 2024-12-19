import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xueli/constants/app_colors.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/models/special_language.dart';
import 'package:xueli/ui/widgets/primary_button.dart';

class SpecialLanguageItem extends StatelessWidget {
  final SpecialLanguageModel languageModel;
  final VoidCallback closeTapped;
  final VoidCallback playTapped;
  final VoidCallback studentTapped;
  final VoidCallback imageTapped;
  final VoidCallback actionTapped;
  final VoidCallback descriptionTapped;
  final VoidCallback cardLoopTapped;
  final bool isLoop;
  const SpecialLanguageItem(
      {super.key,
      required this.languageModel,
      required this.closeTapped,
      required this.playTapped,
      required this.studentTapped,
      required this.imageTapped,
      required this.descriptionTapped,
      required this.actionTapped,
      required this.cardLoopTapped,
      required this.isLoop});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          children: [
            ButtonAnimationWidget(
              onTap: playTapped,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        style: TextStyle(color: AppColors.brown),
                        maxLines: 1,
                      ),
                    ),
                    // const SizedBox(
                    //   width: 5,
                    // ),
                    // ImageButton(
                    //     image: isLoop ? Assets.imagesStop : Assets.imagesLoop,
                    //     bg: AppColors.white,
                    //     btnSize: 34,
                    //     iconSize: 22,
                    //     callback: cardLoopTapped),
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
