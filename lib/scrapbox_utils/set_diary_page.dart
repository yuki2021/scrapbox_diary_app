import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/provider/webview_controller_provider.dart';

final setDiaryPageProvider = Provider.family<SetDiaryPage, String>(
    (ref, currentUrl) => SetDiaryPage(ref, currentUrl));

class SetDiaryPage {
  final ProviderRef ref;
  final String _scrapboxProject;
  final List<String> days = ["月", "火", "水", "木", "金", "土", "日"];

  SetDiaryPage(this.ref, String currentUrl)
      : _scrapboxProject =
            (RegExp(r"scrapbox\.io/([^/.]*)").firstMatch(currentUrl)?[1]) ?? '';

  // 時間の差分
  DateTime _diffDate(DateTime date, int diffDays,
      {int diffMonths = 0, int diffYears = 0}) {
    return date
        .add(Duration(days: diffDays))
        .add(Duration(days: diffMonths * 30))
        .add(Duration(days: diffYears * 365));
  }

  // 日付をフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // Tag生成
  String _generateTag(String title, DateTime date,
      {int diffDays = 0, int diffMonths = 0, int diffYears = 0}) {
    String projectUrl = 'https://scrapbox.io/$_scrapboxProject/';
    return '[$title $projectUrl${Uri.encodeComponent(_formatDate(_diffDate(date, diffDays, diffMonths: diffMonths, diffYears: diffYears)))}]';
  }

  // 今日の日付のページを作成する
  Future<String> setDiaryPage() async {
    DateTime d = DateTime.now();
    String title = _formatDate(d);
    List<String> tags = [
      _generateTag('←', d, diffDays: -1),
      '#${d.year}',
      '#${d.month}月',
      '#${days[d.weekday -1]}曜日',
      _generateTag('1ヶ月前', d, diffMonths: -1),
      _generateTag('3ヶ月前', d, diffMonths: -3),
      _generateTag('1年前', d, diffYears: -1),
      _generateTag('→', d, diffDays: 1),
    ];
    String body = Uri.encodeComponent(tags.join(' '));
    String scrapboxUrl =
        'https://scrapbox.io/$_scrapboxProject/${Uri.encodeComponent(title)}';

    return '$scrapboxUrl?body=$body';
  }

  // その日の日付を打刻して開く
  Future<String> setNowTimePage() async {
    final now = DateTime.now();
    final date = _formatDate(now);
    final title = Uri.encodeComponent(date);
    final body =
        Uri.encodeComponent('\t$date ${now.hour}:${now.minute}:${now.second}');
    final scrapboxUrl =
        'https://scrapbox.io/$_scrapboxProject/$title?body=$body';

    return scrapboxUrl;
  }

  // データピッカーから渡された日付のページのURLを生成する
  Future<String> setDatePickerPage(DateTime dateObj) async {
    final title = _formatDate(dateObj);
    final scrapboxUrl =
        'https://scrapbox.io/$_scrapboxProject/${Uri.encodeComponent(title)}';

    return scrapboxUrl;
  }

  // その日の日付のページが存在するかどうか
  // TODO: この関数は動作しない。denoの方の処理を確認して代替案を検討する
  Future<bool> pageExists(String title) async {
    try {
      // webViewContrllerを取得
      final webViewController = ref.watch(webViewControllerProvider);

      final url =
          'https://scrapbox.io/api/pages/$_scrapboxProject/${Uri.encodeComponent(title)}';

      if (webViewController == null) return false;
      // Javascriptのfetch APIを用いてHTTPリクエストを送り、レスポンスを取得する
      final result = await webViewController.evaluateJavascript(source: """
    (async () => {
        try {
            const response = await fetch('${url.toString()}');
            const data = await response.json();
            return JSON.stringify(data);
        } catch (error) {
            return JSON.stringify({ error: error.message });
        }
    })()
""") ?? '{}'; 

      final data = jsonDecode(result);
      if (data.containsKey('error')) {
        print('JavaScript error: ${data['error']}');
        return false;
      }
      return data['descriptions'] != null &&
          (data['descriptions'] as List).isNotEmpty;
    } catch (e) {
      // Exception handling. You may want to handle different types of exceptions differently.
      print(e);
      return false;
    }
  }

  // その日の日付のタイトルを作成し、ページが存在するか確認する
  Future<String> getTodayPageUrl() async {
    final todayTitle = _formatDate(DateTime.now());

    if (await pageExists(todayTitle)) {
      return setNowTimePage();
    } else {
      return setDiaryPage();
    }
  }
}
