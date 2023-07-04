import 'package:flutter/material.dart';
import 'package:scrapbox_diary_app/screen/my_home_page_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'gyazo_login_utils/gyazo_login_get_token.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    checkForInitialLink();
    listenForLinks();
  }

  @override
  void dispose() {
    stopListening();
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
