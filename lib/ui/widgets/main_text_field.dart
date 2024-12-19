import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/app_colors.dart';

class MainTextField extends HookConsumerWidget {
  final String hintText;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final Icon? prefixIcon;
  final String icon;
  final ValueSetter<String?>? onTextChanged;

  const MainTextField({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onTextChanged,
    this.prefixIcon,
    this.icon = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.textFieldBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textFieldBorder),
      ),
      child: Row(
        children: [
          Visibility(
              visible: icon.isNotEmpty,
              child: Row(
                children: [
                  Image.asset(
                    icon,
                    height: 24,
                    width: 24,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    height: 30,
                    child: VerticalDivider(
                      thickness: 0.5,
                      width: 0.5,
                      color: AppColors.textFieldLine,
                    ),
                  ),
                ],
              )),
          Expanded(
            child: TextField(
              onChanged: onTextChanged,
              enabled: enabled,
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(color: AppColors.textFieldText),
              decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: prefixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.textFieldHint,
                    fontWeight: FontWeight.w400,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: true),
            ),
          ),
        ],
      ),
    );
  }
}

class MainTextFieldLight extends HookConsumerWidget {
  final String hintText;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final Icon? prefixIcon;
  final String icon;
  final ValueSetter<String?>? onTextChanged;

  const MainTextFieldLight({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onTextChanged,
    this.prefixIcon,
    this.icon = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: onTextChanged,
      enabled: enabled,
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textFieldText),
      decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          hintStyle: TextStyle(
            color: AppColors.textFieldHint,
            fontWeight: FontWeight.w400,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          fillColor: Colors.transparent,
          filled: false),
    );
  }
}

class MainTextFieldDark extends HookConsumerWidget {
  final String hintText;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final Icon? prefixIcon;
  final String icon;
  final ValueSetter<String?>? onTextChanged;

  const MainTextFieldDark({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onTextChanged,
    this.prefixIcon,
    this.icon = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE6E6E6), width: 0.5)),
      child: Row(
        children: [
          Visibility(
              visible: icon.isNotEmpty,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFEBD6), shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        icon,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              )),
          Expanded(
            child: TextField(
              onChanged: onTextChanged,
              enabled: enabled,
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(color: AppColors.textFieldTextDark),
              decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: prefixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.textFieldHint,
                    fontWeight: FontWeight.w400,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: false),
            ),
          ),
        ],
      ),
    );
  }
}

class MainTextFieldTitle extends HookConsumerWidget {
  final String hintText;
  final String title;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final Icon? prefixIcon;
  final String icon;
  final ValueSetter<String?>? onTextChanged;

  const MainTextFieldTitle({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onTextChanged,
    this.prefixIcon,
    this.icon = "",
    this.title = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Color(0xFF5F5F5F),
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textFieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.textFieldBorder),
          ),
          child: Row(
            children: [
              Visibility(
                  visible: icon.isNotEmpty,
                  child: Row(
                    children: [
                      Image.asset(
                        icon,
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 30,
                        child: VerticalDivider(
                          thickness: 0.5,
                          width: 0.5,
                          color: AppColors.textFieldLine,
                        ),
                      ),
                    ],
                  )),
              Expanded(
                child: TextField(
                  onChanged: onTextChanged,
                  enabled: enabled,
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  style: TextStyle(color: AppColors.textFieldTextDark),
                  decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon: prefixIcon,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.textFieldHint,
                        fontWeight: FontWeight.w400,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        ),
                      ),
                      fillColor: Colors.transparent,
                      filled: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PasswordTextField extends HookConsumerWidget {
  final String hintText;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final Icon? prefixIcon;
  final String icon;
  final ValueSetter<String?>? onTextChanged;

  const PasswordTextField({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onTextChanged,
    this.prefixIcon,
    this.icon = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _obscureText = useState(true);
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE6E6E6), width: 0.5)),
      child: Row(
        children: [
          Visibility(
              visible: icon.isNotEmpty,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFEBD6), shape: BoxShape.circle),
                    child: Center(
                      child: Image.asset(
                        icon,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              )),
          Expanded(
            child: TextField(
              obscureText: _obscureText.value,
              onChanged: onTextChanged,
              enabled: enabled,
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(color: AppColors.textFieldTextDark),
              decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: prefixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  hintStyle: TextStyle(
                      color: AppColors.textFieldHint,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _obscureText.value = !_obscureText.value;
                    },
                    child: Icon(
                      _obscureText.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.textFieldHint,
                    ),
                  ),
                  fillColor: Colors.transparent,
                  filled: false),
            ),
          ),
        ],
      ),
    );
  }
}

class MainTextFieldTap extends HookConsumerWidget {
  final String hintText;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final VoidCallback? onPressed;
  final String icon;
  final ValueSetter<String?>? onTextChanged;
  final Icon? prefixIcon;
  final String title;

  const MainTextFieldTap({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = false,
    this.onPressed,
    this.icon = "",
    this.onTextChanged,
    this.prefixIcon,
    this.title = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Color(0xFF5F5F5F),
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 5,
        ),
        InkWell(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              color: AppColors.textFieldBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textFieldBorder),
            ),
            child: Row(
              children: [
                Visibility(
                    visible: icon.isNotEmpty,
                    child: Row(
                      children: [
                        Image.asset(
                          icon,
                          height: 24,
                          width: 24,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 30,
                          child: VerticalDivider(
                            thickness: 0.5,
                            width: 0.5,
                            color: AppColors.textFieldLine,
                          ),
                        ),
                      ],
                    )),
                Expanded(
                  child: TextField(
                    onChanged: onTextChanged,
                    enabled: enabled,
                    controller: controller,
                    maxLines: maxLines,
                    keyboardType: keyboardType,
                    style: TextStyle(color: AppColors.textFieldTextDark),
                    decoration: InputDecoration(
                        hintText: hintText,
                        prefixIcon: prefixIcon,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        hintStyle: TextStyle(
                          color: AppColors.textFieldHint,
                          fontWeight: FontWeight.w400,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        fillColor: Colors.transparent,
                        filled: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MainTextView extends HookConsumerWidget {
  final String hintText;
  final String? leadingIconSrc;
  final int? maxLines;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final Icon? prefixIcon;
  final String icon;
  final ValueSetter<String?>? onTextChanged;

  const MainTextView({
    Key? key,
    this.hintText = "",
    this.leadingIconSrc,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.enabled = true,
    this.onTextChanged,
    this.prefixIcon,
    this.icon = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: AppColors.textFieldBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textFieldBorder),
      ),
      child: TextField(
        onChanged: onTextChanged,
        enabled: enabled,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: null,
        style: TextStyle(color: AppColors.textFieldText),
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            hintStyle: TextStyle(
              color: AppColors.textFieldHint,
              fontWeight: FontWeight.w400,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            fillColor: Colors.transparent,
            filled: true),
      ),
    );
  }
}

// class PickerView extends StatelessWidget {
//   const PickerView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonHideUnderline(
//       child: DropdownButton<String>(
//         dropdownColor: AppColors.white,
//         hint: Text(
//           "",
//           style: TextStyle(
//               color: AppColors.textFieldHint,
//               fontWeight: FontWeight.w400,
//               fontSize: 17),
//         ),
//         icon: Icon(
//           Icons.arrow_drop_down_outlined,
//           color: AppColors.white,
//         ),
//         elevation: 16,
//         selectedItemBuilder: (BuildContext context) {
//           return activityList.map<Widget>((String item) {
//             return Container(
//               alignment: Alignment.centerLeft,
//               constraints: const BoxConstraints(minWidth: 100),
//               child: Text(
//                 item,
//                 style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500),
//               ),
//             );
//           }).toList();
//         },
//         style: TextStyle(color: AppColors.textFieldText),
//         value: selectedActivity.value,
//         onChanged: (String? Value) {
//           if (Value != null) {
//             selectedActivity.value = Value;
//           }
//         },
//         items: activityList.map((String type) {
//           return DropdownMenuItem<String>(
//             value: type,
//             child: Text(
//               type,
//               maxLines: 1,
//               style: TextStyle(
//                   color: AppColors.black,
//                   fontSize: 17,
//                   fontWeight: FontWeight.w400),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
