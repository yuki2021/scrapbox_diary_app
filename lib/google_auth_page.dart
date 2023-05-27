import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// stateful widget
class GoogleAuthPage extends StatefulWidget {
  const GoogleAuthPage({Key? key}) : super(key: key);
  @override
  GoogleAuthPageState createState() => GoogleAuthPageState();
}

class GoogleAuthPageState extends State<GoogleAuthPage> {
  // Googleアカウントの表示名
  String _displayName = "";
  static final googleLogin = GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Hello $_displayName", style: const TextStyle(fontSize: 50)),
        TextButton(
          // ボタンを押した時のイベント
          onPressed: () async {
            // Google認証
            GoogleSignInAccount? signinAccount = await googleLogin.signIn();
            if (signinAccount == null) return;
            GoogleSignInAuthentication auth =
                await signinAccount.authentication;
            final OAuthCredential credential = GoogleAuthProvider.credential(
              idToken: auth.idToken,
              accessToken: auth.accessToken,
            );
            // 認証情報をFirebaseに登録
            User? user =
                (await FirebaseAuth.instance.signInWithCredential(credential))
                    .user;
            if (user != null) {
              setState(() {
                // 画面を更新
                _displayName = user.displayName!;
              });
            }
          },
          child: const Text(
            'login',
            style: TextStyle(fontSize: 50),
          ),
        ),
      ]),
    ));
  }
}