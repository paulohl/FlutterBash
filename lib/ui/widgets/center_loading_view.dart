import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CenterLoadingView extends StatelessWidget {
  final Color color;
  final double size;

  const CenterLoadingView({Key? key, this.color = Colors.white, this.size = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFoldingCube(
        color: color,
        size: size,
      ),
    );
  }
}
