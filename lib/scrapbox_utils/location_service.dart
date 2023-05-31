
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrapbox_diary_app/common/date_utils.dart';
import 'package:scrapbox_diary_app/config/logger.dart';
import 'package:scrapbox_diary_app/scrapbox_utils/scrapbox_url.dart';

final locationServiceProvider =
    Provider.family<LocationService, String>((ref, currentUrl) {
  return LocationService(currentUrl);
});

class LocationService {
  final String _scrapboxProject;
  late final DateUtils dateUtils;
  late final ScrapboxUrlGenerator scrapboxUrlGenerator;

  LocationService(String currentUrl)
      : _scrapboxProject =
            (RegExp(r"scrapbox\.io/([^/.]*)").firstMatch(currentUrl)?[1]) ?? '' {
    dateUtils = DateUtils(_scrapboxProject);
    scrapboxUrlGenerator = ScrapboxUrlGenerator(_scrapboxProject);
  }

  Future<String> getCurrentLocation() async {
    try {
      // 位置情報の許可を確認
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // 許可されていない場合は許可を求める
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.i("Location permissions are denied");
          return "";
        }
      }

      // 現在の位置情報を取得
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      logger.i("Position is ${position.latitude}, ${position.longitude}");

      // 緯度経度から住所を取得
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        // 現在時刻を取得
        final now = DateTime.now();
        final date = dateUtils.formatDate(now);
        // 住所と現在時刻をページに追記
        final body = Uri.encodeComponent('''
\t$date ${now.hour}:${now.minute}:${now.second}
\t\t${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}
\t\t\t[Google Map https://www.google.com/maps/?q=${position.latitude},${position.longitude}]
''');
        final scrapboxUrl = '${scrapboxUrlGenerator.generatePageUrl(date)}?body=$body';
        return scrapboxUrl;
      } else {
        logger.i("No placemark associated with the location");
        return "";
      }
    } catch (e) {
      logger.e("An error occurred: $e", e);
      return "";
    }
  }
}
