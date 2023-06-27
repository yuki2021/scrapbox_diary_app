import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:scrapbox_diary_app/config/gyazo_access_token.dart';
import 'package:url_launcher/url_launcher.dart';

const String authorizationEndpoint = 'https://api.gyazo.com/oauth/authorize';
const String tokenEndpoint = 'https://api.gyazo.com/oauth/token';

class GyazoLoginScreen extends StatelessWidget {
  const GyazoLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyazo Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gyazo Login Demo'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await getGyazoAccessToken(context);
            },
            child: const Text('Login with Gyazo'),
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
        // アプリのデフォルトブラウザでGyazoの認証ページを開きます
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
