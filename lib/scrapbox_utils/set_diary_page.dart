import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final setDiaryPageProvider = Provider.family<SetDiaryPage, String>(
    (ref, currentUrl) => SetDiaryPage(currentUrl));

class SetDiaryPage {
  final String _scrapboxProject;
  final List<String> days = ["日", "月", "火", "水", "木", "金", "土"];

  SetDiaryPage(String currentUrl)
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
      '#${days[d.weekday]}曜日',
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
  Future<String> getScrapboxUrl() async {
    final now = DateTime.now();
    final date = _formatDate(now);
    final title = Uri.encodeComponent(date);
    final body =
        Uri.encodeComponent('\t$date ${now.hour}:${now.minute}:${now.second}');
    final scrapboxUrl =
        'https://scrapbox.io/$_scrapboxProject/$title?body=$body';

    return scrapboxUrl;
  }

  // その日の日付のページが存在するかどうか
  Future<bool> pageExists(String title) async {
    final response = await http.get(Uri.parse(
        'https://scrapbox.io/api/pages/$_scrapboxProject/${Uri.encodeComponent(title)}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['descriptions'] != null &&
          (data['descriptions'] as List).isNotEmpty;
    } else {
      throw Exception('Failed to load page');
    }
  }
}