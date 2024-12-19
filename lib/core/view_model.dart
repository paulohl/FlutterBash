import 'package:easy_nav/easy_nav.dart';
import 'package:flutter/material.dart';

/// A base ViewModel class for all screens and independent widgets to implement.
abstract class ViewModel extends ChangeNotifier {
  final snackbarManager = SnackBarManager();
  final dialogManager = DialogManager();
  final navManager = NavManager();
  final bottomSheetManager = BottomSheetManager();

  bool loading = false;

  void showLoading() {
    loading = true;
    notifyListeners();
  }

  void hideLoading() {
    loading = false;
    notifyListeners();
  }
}
