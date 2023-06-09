import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:scrapbox_diary_app/provider/imge_file_provider.dart';
import 'package:scrapbox_diary_app/provider/loading_state_provider.dart';
import 'package:scrapbox_diary_app/provider/set_diary_page_provider.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';

class CameraBottomSheet extends ConsumerWidget {
  const CameraBottomSheet({super.key});

  Future<void> _pickImageAndUpload(
      BuildContext context, WidgetRef ref, bool isCamera) async {
    final webViewController = ref.watch(webViewControllerProvider);
    Navigator.of(context).pop();
    try {
      if (webViewController != null) {
        // タップされたらローディングを開始
        ref.read(loadingStateProvider.notifier).setLoading(true);
        var scrapboxUrl = '';
        final currentUrl = (await webViewController.getUrl())?.toString() ?? '';
        final setDiaryPage = ref.read(setDiaryPageProvider(currentUrl));
        if (isCamera) {
          // カメラへアクセスする処理
          final imageUrl =
              await ref.read(imageNotifierProvider.notifier).pickImage();
          // 画像URLを整形して返す
          scrapboxUrl = await setDiaryPage.setDiaryPageWithImage(imageUrl);
        } else {
          // ギャラリーへアクセスする処理
          final List<String> imageUrlList = await ref
              .read(imageNotifierProvider.notifier)
              .pickImages(context);
          // 画像URLを整形して返す
          scrapboxUrl = await setDiaryPage.setDiaryPageWithImages(imageUrlList);
        }
        // ScrapboxのURLを開く
        webViewController.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(scrapboxUrl)));
      }
    } catch (e) {
      logger.e(e);
    } finally {
      // ローディングを終了
      ref.read(loadingStateProvider.notifier).setLoading(false);
    }
  }

  Future<void> showCameraBottomSheet(
      BuildContext context, WidgetRef ref) async {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (builder) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: OutlinedButton(
                  onPressed: () => _pickImageAndUpload(context, ref, true),
                  style: _buttonStyle(context),
                  child: const Text('カメラ'),
                ),
              ),
              OutlinedButton(
                onPressed: () => _pickImageAndUpload(context, ref, false),
                style: _buttonStyle(context),
                child: const Text('ギャラリー'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text('キャンセル'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      side: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      minimumSize: const Size(double.infinity, 0),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Do nothing for now. You can return an empty Container() or any other widget.
    return Container();
  }
}

