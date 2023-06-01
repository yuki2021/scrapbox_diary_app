import 'package:scrapbox_diary_app/config/config.dart';

class ScrapboxUrlGenerator {
  final String _scrapboxProject;

  ScrapboxUrlGenerator(this._scrapboxProject);

  String generatePageUrl(String title, [String? body]) {
    if (body != null) {
      // bodyが指定されている場合、URLにbodyを追加
      return '${AppConfig.initialUrl}$_scrapboxProject/${Uri.encodeComponent(title)}?body=${Uri.encodeComponent(body)}';
    } else {
      // bodyが指定されていない場合、URLのみ
      return '${AppConfig.initialUrl}$_scrapboxProject/${Uri.encodeComponent(title)}';
    }
  }


  String generateApiPageUrl(String title) {
    return '${AppConfig.initialUrl}api/pages/$_scrapboxProject/${Uri.encodeComponent(title)}';
  }
}
