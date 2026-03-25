import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    self.setContentSize(NSSize(width: 800, height: 600))
    self.minSize = NSSize(width: 480, height: 500)

    super.awakeFromNib()
  }
}
