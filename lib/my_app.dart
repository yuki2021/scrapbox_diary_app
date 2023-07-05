import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/provider/app_lifecycle_provider.dart';
import 'package:scrapbox_diary_app/screen/my_home_page_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'gyazo_login_utils/gyazo_login_get_token.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    checkForInitialLink();
    listenForLinks();

    // アプリのライフサイクル状態を監視するためにNotifierを登録
    WidgetsBinding.instance
        .addObserver(ref.read(appLifecycleStateProvider.notifier));
  }

  @override
  void dispose() {
    stopListening();

    // アプリのライフサイクル状態を監視するNotifierを削除
    WidgetsBinding.instance
        .removeObserver(ref.read(appLifecycleStateProvider.notifier));

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScrapDiary',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(),
      // 日本語対応
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        // 日本語のロケールを追加
        Locale('ja', 'JP'),
      ],
    );
  }
}
