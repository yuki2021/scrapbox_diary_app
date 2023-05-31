import 'package:scrapbox_diary_app/config/config.dart';

class DateUtils {
  DateUtils(this._scrapboxProject);
  final String _scrapboxProject;
  
  // 時間の差分
  DateTime diffDate(DateTime date, int diffDays,
      {int diffMonths = 0, int diffYears = 0}) {
    return date
        .add(Duration(days: diffDays))
        .add(Duration(days: diffMonths * 30))
        .add(Duration(days: diffYears * 365));
  }

  // 日付をフォーマット
  String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // Tag生成
  String generateTag(String title, DateTime date,
      {int diffDays = 0, int diffMonths = 0, int diffYears = 0}) {
    String projectUrl = '${AppConfig.initialUrl}$_scrapboxProject/';
    return '[$title $projectUrl${Uri.encodeComponent(formatDate(diffDate(date, diffDays, diffMonths: diffMonths, diffYears: diffYears)))}]';
  }
}