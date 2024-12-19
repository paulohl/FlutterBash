import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../constants/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/main_text_field.dart';
import '../../widgets/primary_button.dart';
import 'forget_password_vm.dart';

class ForgetPasswordScreen extends HookConsumerWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final loading = ref.watch(forgetPasswordVMProvider).loading;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Reset Password",
      ),
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "Forget Password",
                    style: TextStyle(
                        color: Color(0xFF131F4F),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // NavButton(
                      //     image: Assets.imagesBack,
                      //     count: 0,
                      //     callback: () {
                      //       NavManager().goBack();
                      //     }),
                    ],
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    MainTextField(
                      hintText: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryButton(
                      label: 'Continue',
                      loading: loading,
                      onPressed: () {
                        ref
                            .read(forgetPasswordVMProvider)
                            .resetEmail(email: emailController.text);
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
