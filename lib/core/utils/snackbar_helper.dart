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

  // show success snackbar
  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    CustomSnackbar.show(
      context,
      message: message,
      type: SnackbarType.success,
    );
  }

  // show info snackbar
  static void showInfo(
    BuildContext context, {
    required String message,
  }) {
    CustomSnackbar.show(
      context,
      message: message,
      type: SnackbarType.info,
    );
  }
}