import 'package:no_screenshot/no_screenshot.dart';
import 'package:root_jailbreak_sniffer/rjsniffer.dart';

class DeviceSecurityService {
  static final _noScreenshot = NoScreenshot.instance;

  static Future<bool> isDeviceCompromised() async {
    try {
      return await Rjsniffer.amICompromised() ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> enableSecureScreen() async {
    await _noScreenshot.screenshotOff();
  }

  static Future<void> disableSecureScreen() async {
    await _noScreenshot.screenshotOn();
  }
}
