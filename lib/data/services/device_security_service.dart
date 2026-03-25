import 'package:no_screenshot/no_screenshot.dart';
import 'package:root_jailbreak_sniffer/rjsniffer.dart';
import '../../core/platform_util.dart';

class DeviceSecurityService {
  static final _noScreenshot = NoScreenshot.instance;

  static Future<bool> isDeviceCompromised() async {
    if (PlatformUtil.isDesktop) return false;
    try {
      return await Rjsniffer.amICompromised() ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> enableSecureScreen() async {
    if (PlatformUtil.isDesktop) return;
    await _noScreenshot.screenshotOff();
  }

  static Future<void> disableSecureScreen() async {
    if (PlatformUtil.isDesktop) return;
    await _noScreenshot.screenshotOn();
  }
}
