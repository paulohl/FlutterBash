import 'package:easy_localization/easy_localization.dart';
import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xueli/generated/assets.dart';
import 'package:xueli/generated/locale_keys.g.dart';
import 'package:xueli/ui/registration/signin/signin_vm.dart';

import '../../../constants/app_colors.dart';
import '../../widgets/main_text_field.dart';
import '../../widgets/primary_button.dart';
import '../forget_password/forget_password_screen.dart';

class SigninScreen extends HookConsumerWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final loading = ref.watch(signinVMProvider).loading;
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.imagesAppLogo,
                        height: 120,
                        width: 120,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(LocaleKeys.login),
                          style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                        Text(
                          context.tr(LocaleKeys.enter_your_phone),
                          style: const TextStyle(
                              color: Color(0xFF616161), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MainTextFieldDark(
                    icon: Assets.imagesPhone,
                    controller: emailController,
                    hintText: context.tr(LocaleKeys.phone),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  PasswordTextField(
                    icon: Assets.imagesLock,
                    controller: passwordController,
                    hintText: context.tr(LocaleKeys.password),
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     InkWell(
                  //       onTap: () {
                  //         NavManager().goTo(const ForgetPasswordScreen());
                  //       },
                  //       child: Text(
                  //         "Forget password?",
                  //         style: TextStyle(
                  //             color: AppColors.black,
                  //             fontSize: 14,
                  //             decoration: TextDecoration.underline),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  CoreButton(
                    label: context.tr(LocaleKeys.login),
                    loading: loading,
                    invert: false,
                    onPressed: () {
                      ref.read(signinVMProvider).login(
                          email: emailController.text,
                          password: passwordController.text);
                    },
                  ),
                  // const SizedBox(
                  //   height: 20,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "or",
                  //       style: TextStyle(color: AppColors.white),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Don’t have an account?  ",
                  //       style: TextStyle(color: AppColors.white),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         NavManager().goTo(SignupScreen());
                  //       },
                  //       child: Text(
                  //         "Sign Up",
                  //         style: TextStyle(
                  //             color: AppColors.white,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
    this.align,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
        textAlign: align,
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator(
      {Key? key, this.height = 0.5, this.color = const Color(0xFF888888)})
      : super(key: key);
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final String image;
  final Color bgColor;
  final String title;
  final VoidCallback callback;
  const SocialLoginButton(
      {super.key,
      required this.image,
      required this.bgColor,
      required this.title,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black,
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            image,
            height: 25,
            width: 25,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
