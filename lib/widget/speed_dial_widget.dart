import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/provider/loading_state_provider.dart';
import 'package:scrapbox_diary_app/provider/set_diary_page_provider.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/get_location_utils/location_service.dart';
import 'package:scrapbox_diary_app/widget/camera_bottom_sheet_widget.dart';

class SpeedDialState extends ConsumerWidget {
  final ProviderRef ref;

  const SpeedDialState(this.ref, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // webViewControllerを取得
    final webViewController = ref.watch(webViewControllerProvider);

    return SpeedDial(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      animatedIcon: AnimatedIcons.menu_close,
      children: [
        SpeedDialChild(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
          label: '入力',
          onTap: () async {
            if (webViewController != null) {
              // タップされたらローディングを開始
              ref.read(loadingStateProvider.notifier).setLoading(true);
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
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.my_location),
          label: '現在地',
          onTap: () async {
            if (webViewController != null) {
              // タップされたらローディングを開始
              ref.read(loadingStateProvider.notifier).setLoading(true);
              // SetDiaryPageを使ってScrapboxのURLを取得
              final currentUrl =
                  (await webViewController.getUrl())?.toString() ?? '';
              final setLocation = ref.read(locationServiceProvider(currentUrl));
              final scrapboxUrl = await setLocation.getCurrentLocation();

              // ScrapboxのURLを開く
              webViewController.loadUrl(
                  urlRequest: URLRequest(url: Uri.parse(scrapboxUrl)));
            }
          },
        ),
        SpeedDialChild(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.camera_alt),
            label: '写真撮影',
            onTap: () {
              const CameraBottomSheet().showCameraBottomSheet(context, ref);
            }            
            ),
      ],
    );
  }
}
