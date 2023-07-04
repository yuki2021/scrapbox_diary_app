import 'package:flutter/material.dart';
import 'package:scrapbox_diary_app/gyazo_login_utils/gyazo_login_get_token.dart';

class AppLifecycleManager with WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  AppLifecycleManager._internal();

  factory AppLifecycleManager() => _instance;

  void Function()? onAppResumed;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        listenForLinks();
        onAppResumed?.call();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        stopListening();
        break;
    }
  }
}
