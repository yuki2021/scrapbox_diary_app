import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/gyazo_access_token.dart';
import 'package:scrapbox_diary_app/provider/gyazo_token_provider.dart';
import 'package:scrapbox_diary_app/secure_storage_utils/secure_strage_controller.dart';
import 'package:url_launcher/url_launcher.dart';

const String authorizationEndpoint = 'https://api.gyazo.com/oauth/authorize';
const String tokenEndpoint = 'https://api.gyazo.com/oauth/token';

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
                    await getGyazoAccessToken(context);
                  },
                  child: const Text('Gyazoにログイン'),
                ),
        ),
      ),
    );
  }

  Future<void> getGyazoAccessToken(BuildContext context) async {
    final redirectUri = Uri.parse(GyazoAccessToken.redirectUrl);
    final oauth2.AuthorizationCodeGrant grant = oauth2.AuthorizationCodeGrant(
      GyazoAccessToken.clientId,
      Uri.parse(authorizationEndpoint),
      Uri.parse(tokenEndpoint),
      secret: GyazoAccessToken.clientSecret,
    );
    final authorizationUrl = grant.getAuthorizationUrl(
      redirectUri,
      scopes: <String>['public'],
    );
    final Uri url = Uri.parse(authorizationUrl.toString());
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
