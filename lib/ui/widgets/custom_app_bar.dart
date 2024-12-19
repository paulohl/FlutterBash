import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:xueli/generated/assets.dart';

import '../../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.mustard,
      title: Text(
        title,
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar2 extends StatelessWidget {
  final String title;
  final bool showBack;
  final bool showSetting;
  final VoidCallback? settingCallback;
  const CustomAppBar2({
    super.key,
    required this.title,
    this.showBack = true,
    this.showSetting = false,
    this.settingCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: showBack,
          child: Row(
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
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
                color: AppColors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        Visibility(
          visible: showSetting,
          child: Row(
            children: [
              GestureDetector(
                  onTap: settingCallback,
                  child: Image.asset(
                    Assets.imagesSetting,
                    height: 24,
                    width: 24,
                  )),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool isFromNotification;
//   const CustomAppBar({
//     super.key,
//     required this.title,
//     this.isFromNotification = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20.0),
//           bottomRight: Radius.circular(20.0),
//         ),
//         color: AppColors.white, // Customize the background color
//       ),
//       child: AppBar(
//         title: Text(
//           title,
//           style:
//               TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         // backgroundColor: AppColors.white,
//         leading: IconButton(
//           icon: Image.asset(
//             Assets.imagesBack,
//             height: 30,
//             width: 30,
//           ),
//           onPressed: () {
//             if (isFromNotification) {
//               NavManager().goToAndRemoveUntil(MainScreen(), (route) => false);
//             } else {
//               Navigator.pop(context);
//             }
//           },
//         ),
//         elevation: 0,
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
// class CustomAppBar2 extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final VoidCallback trailingCallback;
//   final bool showTrailing;
//   final Color trailingIconColor;
//   final bool isFromNotification;
//   const CustomAppBar2({
//     super.key,
//     required this.title,
//     required this.trailingCallback,
//     this.showTrailing = true,
//     this.isFromNotification = false,
//     this.trailingIconColor = Colors.white,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(
//         title,
//         style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
//       ),
//       centerTitle: true,
//       backgroundColor: AppColors.blue,
//       leading: IconButton(
//         icon: Image.asset(
//           Assets.imagesBack,
//           height: 30,
//           width: 30,
//         ),
//         onPressed: () {
//           if (isFromNotification) {
//             NavManager().goToAndRemoveUntil(MainScreen(), (route) => false);
//           } else {
//             Navigator.pop(context);
//           }
//         },
//       ),
//       actions: [
//         Visibility(
//           visible: showTrailing,
//           child: IconButton(
//             onPressed: trailingCallback,
//             icon: Icon(
//               Icons.star,
//               size: 24,
//               color: trailingIconColor,
//             ),
//           ),
//         )
//       ],
//       elevation: 0,
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
