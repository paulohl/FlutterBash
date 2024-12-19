import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xueli/generated/assets.dart';

import '../../constants/app_colors.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            placeholder: (context, item) {
              return SvgPicture.asset(
                Assets.imagesPlaceHolder,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16),
              child: GestureDetector(
                onTap: () {
                  NavManager().goBack();
                },
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: AppColors.black,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
