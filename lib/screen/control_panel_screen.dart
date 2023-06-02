import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenInputPage extends StatefulWidget {
  const TokenInputPage({super.key});

  @override
  TokenInputPageState createState() => TokenInputPageState();
}

class TokenInputPageState extends State<TokenInputPage> {
  final storage = const FlutterSecureStorage();
  final tokenController = TextEditingController();

  @override
  void dispose() {
    tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Gyazo Token'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Gyazo Token',
              ),
            ),
            ElevatedButton(
              onPressed: _onSaveButtonPressed,
              child: const Text('Save Token'),
            ),
          ],
        ),
      ),
    );
  }

  // 非同期処理をするメソッド
  Future<void> _saveToken() async {
    await storage.write(key: 'gyazoToken', value: tokenController.text);
  }

  // SnackBarを表示するメソッド
  void _showSnackBar(BuildContext context) {
    const snackBar = SnackBar(content: Text('Saved Gyazo token.'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onSaveButtonPressed() {
    _saveToken();
    _showSnackBar(context);
  }

}
