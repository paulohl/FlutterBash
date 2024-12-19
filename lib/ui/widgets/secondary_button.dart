import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'center_loading_view.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double width;
  final bool loading;
  final bool invert;

  const SecondaryButton({
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
        padding: EdgeInsets.all(15),
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
          border:
              Border.all(color: invert ? AppColors.mustard : AppColors.white),
        ),
        duration: Duration(milliseconds: 200),
        child: loading
            ? CenterLoadingView(
                size: 20,
                color: invert ? AppColors.white : AppColors.black,
              )
            : Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: invert ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }
}
