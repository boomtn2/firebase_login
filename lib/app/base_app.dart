import 'package:flutter/material.dart';

import '../utils/utils.dart';

class BaseApp {
  final BuildContext context;

  BaseApp(this.context);
}

class AppPresenter extends BaseApp {
  String? textError;
  AppContact? view;
  AppPresenter(super.context);
  void hanldeError(e, {bool showToast = false}) async {
    try {
      String message = e.message;
      if (showToast) {
        Utils.showToast(context, message);
      } else {
        textError = message;
        if (view != null) view?.updateState();
      }
    } catch (e, stack) {
      debugPrint('$e - $stack');
    }
  }
}

abstract class AppContact {
  void updateState();
}
