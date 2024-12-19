import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:xueli/generated/locale_keys.g.dart';

import '../../constants/app_colors.dart';
import 'center_loading_view.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final bool loading;
  final bool invert;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.width = double.infinity,
    this.invert = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        padding: padding,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(42),
          color: invert ? AppColors.mustard : AppColors.lightBlue,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        duration: const Duration(milliseconds: 200),
        child: loading
            ? CenterLoadingView(
                size: 20,
                color: invert ? AppColors.white : AppColors.white,
              )
            : Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: invert ? AppColors.white : AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final bool loading;
  final bool invert;

  const NextButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.width = double.infinity,
    this.invert = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        padding: EdgeInsets.all(12),
        width: width,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: invert ? AppColors.mustard : AppColors.white,
        ),
        duration: Duration(milliseconds: 200),
        child: loading
            ? CenterLoadingView(
                size: 20,
                color: invert ? AppColors.white : AppColors.black,
              )
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CoreButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final bool loading;
  final bool invert;
  final EdgeInsetsGeometry? padding;

  const CoreButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.width = double.infinity,
    this.invert = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
  });

  @override
  _CoreButtonState createState() => _CoreButtonState();
}

class _CoreButtonState extends State<CoreButton>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;

  double _scaleTransformValue = 1;

  // needed for the "click" tap effect
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    animationController.forward();
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.loading) {
        } else {
          Future.delayed(
            const Duration(milliseconds: clickAnimationDurationMillis * 2),
            () => widget.onPressed?.call(),
          );
          // widget.onPressed?.call();
          _shrinkButtonSize();
          _restoreButtonSize();
        }
      },
      onTapDown: (_) => _shrinkButtonSize(),
      onTapCancel: _restoreButtonSize,
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: Container(
          padding: widget.padding,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            color: widget.invert ? AppColors.mustard : AppColors.lightBlue,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            // boxShadow: [
            //   BoxShadow(
            //     color: AppColors.black.withOpacity(0.15),
            //     spreadRadius: 0,
            //     blurRadius: 20,
            //     offset: const Offset(0, 0), // changes position of shadow
            //   ),
            // ],
          ),
          child: widget.loading
              ? CenterLoadingView(
                  size: 20,
                  color: widget.invert ? AppColors.white : AppColors.white,
                )
              : Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.invert ? AppColors.white : AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class ButtonAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const ButtonAnimationWidget({
    required this.child,
    required this.onTap,
  });

  @override
  _ButtonAnimationWidgetState createState() => _ButtonAnimationWidgetState();
}

class _ButtonAnimationWidgetState extends State<ButtonAnimationWidget>
    with SingleTickerProviderStateMixin {
  static const clickAnimationDurationMillis = 100;

  double _scaleTransformValue = 1;

  // needed for the "click" tap effect
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: clickAnimationDurationMillis),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() => _scaleTransformValue = 1 - animationController.value);
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _shrinkButtonSize() {
    animationController.forward();
  }

  void _restoreButtonSize() {
    Future.delayed(
      const Duration(milliseconds: clickAnimationDurationMillis),
      () => animationController.reverse(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Future.delayed(
          const Duration(milliseconds: clickAnimationDurationMillis * 2),
          () => widget.onTap.call(),
        );
        // widget.onPressed?.call();
        _shrinkButtonSize();
        _restoreButtonSize();
      },
      onTapDown: (_) => _shrinkButtonSize(),
      onTapCancel: _restoreButtonSize,
      child: Transform.scale(
        scale: _scaleTransformValue,
        child: widget.child,
      ),
    );
  }
}

class ImageButton extends StatelessWidget {
  final String image;
  final VoidCallback callback;
  final Color bg;
  final double iconSize;
  final double btnSize;
  const ImageButton(
      {super.key,
      required this.image,
      required this.callback,
      this.bg = Colors.white,
      this.iconSize = 32,
      this.btnSize = 50});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        height: btnSize,
        width: btnSize,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            image,
            height: iconSize,
            width: iconSize,
          ),
        ),
      ),
    );
  }
}

//Format buttons
class TopItem extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback callback;
  final bool notify;
  final bool isSelected;
  const TopItem(
      {super.key,
      required this.image,
      required this.title,
      this.notify = false,
      this.isSelected = false,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return ButtonAnimationWidget(
      onTap: callback,
      child: Container(
        height: 40,
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: notify ? AppColors.red : AppColors.brown, width: 1),
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
            title,
            style: TextStyle(
                color: notify ? AppColors.red : AppColors.brown,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ImageButtonItem extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback callback;
  const ImageButtonItem(
      {super.key,
      required this.image,
      required this.title,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 24,
        // padding: const EdgeInsets.symmetric(horizontal: 6),
        // decoration: BoxDecoration(
        //     color: AppColors.mustard,
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(
        //         color: AppColors.mustard.withOpacity(0.4), width: 0.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              height: 24,
              width: 24,
            ),
            // const SizedBox(
            //   width: 2,
            // ),
            // Expanded(
            //   child: Text(
            //     title,
            //     style: TextStyle(
            //         color: AppColors.white,
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500),
            //     maxLines: 2,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class ImageTextItem extends StatelessWidget {
  final String image;
  final String title;
  final bool isPlaying;
  final VoidCallback callback;
  const ImageTextItem(
      {super.key,
      required this.image,
      required this.title,
      required this.callback,
      required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback();
      },
      child: SizedBox(
        height: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              image,
              height: 24,
              width: 24,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              !isPlaying ? title : context.tr(LocaleKeys.stop),
              style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String image;
  final String title;
  final String title1;
  final String title2;
  final bool isPlaying;
  final ValueSetter<String> callback;
  const MenuItem(
      {super.key,
      required this.image,
      required this.title,
      required this.callback,
      required this.title1,
      required this.title2,
      required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return isPlaying
        ? ButtonAnimationWidget(
            onTap: () {
              callback("3");
            },
            child: Container(
              height: 24,
              // padding: const EdgeInsets.symmetric(horizontal: 6),
              // decoration: BoxDecoration(
              //     color: AppColors.mustard.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //         color: AppColors.mustard.withOpacity(0.4), width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    image,
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    context.tr(LocaleKeys.stop),
                    style: TextStyle(
                        color: AppColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          )
        : PopupMenuButton<String>(
            elevation: 12,
            color: AppColors.white,
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) async {
              callback(val);
            },
            child: Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              // decoration: BoxDecoration(
              //     color: AppColors.mustard.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //         color: AppColors.mustard.withOpacity(0.4), width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    image,
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        color: AppColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
                  PopupMenuItem(
                    height: 30,
                    value: "1",
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            title1,
                            style:
                                TextStyle(color: AppColors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    height: 30,
                    value: "2",
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            title2,
                            style:
                                TextStyle(color: AppColors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]);
  }
}

class MenuItem1 extends StatelessWidget {
  final String image;
  final String title;
  final String title1;
  final String title2;
  final bool isPlaying;
  final ValueSetter<String> callback;
  const MenuItem1(
      {super.key,
      required this.image,
      required this.title,
      required this.callback,
      required this.title1,
      required this.title2,
      required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return isPlaying
        ? ButtonAnimationWidget(
            onTap: () {
              callback("3");
            },
            child: Container(
              height: 24,
              // padding: const EdgeInsets.symmetric(horizontal: 6),
              // decoration: BoxDecoration(
              //     color: AppColors.mustard,
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //         color: AppColors.mustard.withOpacity(0.4), width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    image,
                    height: 24,
                    width: 24,
                  ),
                  // const SizedBox(
                  //   width: 2,
                  // ),
                  // Expanded(
                  //   child: Text(
                  //     context.tr(LocaleKeys.stop),
                  //     style: TextStyle(
                  //         color: AppColors.white,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w500),
                  //     maxLines: 2,
                  //   ),
                  // ),
                ],
              ),
            ),
          )
        : PopupMenuButton<String>(
            elevation: 12,
            color: AppColors.white,
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) async {
              callback(val);
            },
            child: Container(
              height: 24,
              // padding: const EdgeInsets.symmetric(horizontal: 6),
              // decoration: BoxDecoration(
              //     color: AppColors.mustard,
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //         color: AppColors.mustard.withOpacity(0.4), width: 0.5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    image,
                    height: 24,
                    width: 24,
                  ),
                  // const SizedBox(
                  //   width: 2,
                  // ),
                  // Expanded(
                  //   child: Text(
                  //     title,
                  //     style: TextStyle(
                  //         color: AppColors.white,
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w500),
                  //     maxLines: 2,
                  //   ),
                  // ),
                ],
              ),
            ),
            itemBuilder: (context) => [
                  PopupMenuItem(
                    height: 30,
                    value: "1",
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            title1,
                            style:
                                TextStyle(color: AppColors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    height: 30,
                    value: "2",
                    padding: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            title2,
                            style:
                                TextStyle(color: AppColors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]);
  }
}
