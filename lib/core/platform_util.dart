import 'dart:io' show Platform;

class PlatformUtil {
  static bool get isDesktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
}
