import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'apk_download_helper_stub.dart'
    if (dart.library.html) 'apk_download_helper_web.dart' as platform;

/// Helper to trigger direct release APK download when running on Web.
class ApkDownloadHelper {
  static const String apkFileName = 'balloon_kingdom.apk';
  static const String apkDisplayName = 'Balloon Kingdom (Release APK)';
  static const String fileSize = '51.3 MB';
  static const String version = 'v1.0.0 (Release)';

  /// Triggers a direct browser download of the release APK when on Web.
  static Future<bool> downloadReleaseApk() async {
    if (!kIsWeb) return false;
    try {
      // 1. Direct HTML <a> element download with 'download' attribute
      platform.triggerWebDownload(apkFileName, apkFileName);
      return true;
    } catch (_) {
      // 2. Fallback: resolve absolute URI against current page location and launch
      try {
        final uri = Uri.base.resolve(apkFileName);
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        return false;
      }
    }
  }
}
