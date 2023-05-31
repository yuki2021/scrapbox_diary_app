import 'package:scrapbox_diary_app/config/config.dart';

class ScrapboxUrlGenerator {
  final String _scrapboxProject;

  ScrapboxUrlGenerator(this._scrapboxProject);

  String generatePageUrl(String title) {
    return '${AppConfig.initialUrl}$_scrapboxProject/${Uri.encodeComponent(title)}';
  }

  String generateApiPageUrl(String title) {
    return '${AppConfig.initialUrl}api/pages/$_scrapboxProject/${Uri.encodeComponent(title)}';
  }
}
