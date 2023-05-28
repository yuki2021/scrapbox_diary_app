import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/get_location_utils/get_location_widget.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/set_diary_page.dart';

class SpeedDialState extends ConsumerWidget {
  final ProviderRef ref;

  const SpeedDialState(this.ref, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // webViewControllerを取得
    final webViewController = ref.watch(webViewControllerProvider);

    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add),
          label: '入力',
          onTap: () async {
            if (webViewController != null) {
              // SetDiaryPageを使ってScrapboxのURLを取得
              final currentUrl =
                  (await webViewController.getUrl())?.toString() ?? '';
              final setDiaryPage = ref.read(setDiaryPageProvider(currentUrl));
              final scrapboxUrl = await setDiaryPage.getTodayPageUrl();

              // ScrapboxのURLを開く
              webViewController.loadUrl(
                  urlRequest: URLRequest(url: Uri.parse(scrapboxUrl)));
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.my_location),
          label: '現在地',
          onTap: () async {
            if (webViewController != null) {
              // SetDiaryPageを使ってScrapboxのURLを取得
              final currentUrl =
                  (await webViewController.getUrl())?.toString() ?? '';
              final setDiaryPage = ref.read(setDiaryPageProvider(currentUrl));
              final scrapboxUrl = await setDiaryPage.getCurrentLocation();

              // ScrapboxのURLを開く
              webViewController.loadUrl(
                  urlRequest: URLRequest(url: Uri.parse(scrapboxUrl)));
            }
          },
        ),
      ],
    );
  }
}
