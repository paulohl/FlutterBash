import 'package:flutter/material.dart';

class CenterErrorView extends StatelessWidget {
  final String errorMsg;
  final Color textColor;
  final VoidCallback? onRetry;

  const CenterErrorView(
      {required this.errorMsg, this.onRetry, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMsg,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
