import 'dart:async';
import 'dart:convert';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/common/date_utils.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/scrapbox_url.dart';

final setDiaryPageProvider = Provider.family<SetDiaryPage, String>(
    (ref, currentUrl) => SetDiaryPage(ref, currentUrl));

class SetDiaryPage {
  final ProviderRef ref;
  final String _scrapboxProject;
  final List<String> days = ["月", "火", "水", "木", "金", "土", "日"];
  late final DateUtils dateUtils;
  late final ScrapboxUrlGenerator scrapboxUrlGenerator;

  SetDiaryPage(this.ref, String currentUrl)
      : _scrapboxProject =
            (RegExp(r"scrapbox\.io/([^/.]*)").firstMatch(currentUrl)?[1]) ??
                '' {
    dateUtils = DateUtils(_scrapboxProject);
    scrapboxUrlGenerator = ScrapboxUrlGenerator(_scrapboxProject);
  }

  // 今日の日付のページを作成する
  Future<String> setDiaryPage() async {
    DateTime d = DateTime.now();
    String title = dateUtils.formatDate(d);
    List<String> tags = [
      dateUtils.generateTag('←', d, diffDays: -1),
      '#${d.year}',
      '#${d.month}月',
      '#${days[d.weekday - 1]}曜日',
      dateUtils.generateTag('1ヶ月前', d, diffMonths: -1),
      dateUtils.generateTag('3ヶ月前', d, diffMonths: -3),
      dateUtils.generateTag('1年前', d, diffYears: -1),
      dateUtils.generateTag('→', d, diffDays: 1),
    ];
    String body = Uri.encodeComponent(tags.join(' '));
    String scrapboxUrl = scrapboxUrlGenerator.generatePageUrl(title);

    return '$scrapboxUrl?body=$body';
  }

  // その日の日付を打刻して開く
  Future<String> setNowTimePage() async {
    final now = DateTime.now();
    final date = dateUtils.formatDate(now);
    final body =
        Uri.encodeComponent('\t$date ${now.hour}:${now.minute}:${now.second}');
    final scrapboxUrl = '${scrapboxUrlGenerator.generatePageUrl(date)}?body=$body';

    return scrapboxUrl;
  }

  // データピッカーから渡された日付のページのURLを生成する
  Future<String> setDatePickerPage(DateTime dateObj) async {
    final title = dateUtils.formatDate(dateObj);
    final scrapboxUrl = scrapboxUrlGenerator.generatePageUrl(title);

    return scrapboxUrl;
  }

  // その日の日付のページが存在するかどうか
  Future<bool> pageExists(String title) async {
    try {
      // webViewContrllerを取得
      final webViewController = ref.watch(webViewControllerProvider);

      final url = scrapboxUrlGenerator.generateApiPageUrl(title);

      if (webViewController == null) return false;

      // Completerの作成
      final completer = Completer<bool>();

      // JavaScriptハンドラの追加
      webViewController.addJavaScriptHandler(
        handlerName: 'myHandler',
        callback: (args) {
          // 受け取ったデータを解析
          final result = args[0] as String;
          final data = jsonDecode(result);

          if (data.containsKey('error')) {
            logger.e('JavaScript error: ${data['error']}');
            completer.complete(false);
          } else {
            completer.complete(data['descriptions'] != null &&
                (data['descriptions'] as List).isNotEmpty);
          }
        },
      );

      // JavaScriptの非同期処理の開始
      webViewController.evaluateJavascript(source: """
        (async () => {
            try {
                const response = await fetch(`$url`);
                const data = await response.json();
                window.flutter_inappwebview.callHandler('myHandler', JSON.stringify(data));
            } catch (error) {
                window.flutter_inappwebview.callHandler('myHandler', JSON.stringify({ error: error.message }));
            }
        })()
      """);

      // 結果が戻るまで待つ
      return completer.future;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  // その日の日付のタイトルを作成し、ページが存在するか確認する
  Future<String> getTodayPageUrl() async {
    final todayTitle = dateUtils.formatDate(DateTime.now());

    if (await pageExists(todayTitle)) {
      return setNowTimePage();
    } else {
      return setDiaryPage();
    }
  }
}
