import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/gyazo_access_token.dart';
import 'package:scrapbox_diary_app/provider/gyazo_token_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String authorizationEndpoint = 'https://api.gyazo.com/oauth/authorize';

class GyazoLoginScreen extends ConsumerWidget {
  const GyazoLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gyazoToken = ref.watch(gyazoTokenProvider);
    final gyazoTokenNotifier = ref.watch(gyazoTokenProvider.notifier);

    return MaterialApp(
      title: 'Gyazoログイン',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gyazo Login'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: gyazoToken.gyazoToken.isNotEmpty
              ? ElevatedButton(
                  onPressed: () async {
                    await gyazoTokenNotifier.deleteToken();
                  },
                  child: const Text('Gyazoからログアウト'),
                )
              : ElevatedButton(
                  onPressed: () async {
                    await openGyazoAuthPage(context);
                  },
                  child: const Text('Gyazoにログイン'),
                ),
        ),
      ),
    );
  }

  Future<void> openGyazoAuthPage(BuildContext context) async {
    const String clientId = GyazoAccessToken.clientId;
    const String redirectUrl = GyazoAccessToken.redirectUrl;

    const String authorizationUrl =
        '$authorizationEndpoint?client_id=$clientId&redirect_uri=$redirectUrl&response_type=code';

    final Uri url = Uri.parse(authorizationUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
