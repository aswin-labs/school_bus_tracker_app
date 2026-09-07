import 'package:flutter/material.dart';
import 'package:school_bus_tracker/core/utils/custom_snackbar.dart';

class SnackbarHelper {
  // show error snackbar
  static void showError(
    BuildContext context, {
    required String message,
  }) {
    CustomSnackbar.show(
      context,
      message: message,
      type: SnackbarType.error,
    );
  }
}