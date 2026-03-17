import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Set window size constraints
    self.minSize = NSSize(width: 800, height: 600)
    self.maxSize = NSSize(width: 2560, height: 1600)

    // Set a reasonable default size
    let screenFrame = NSScreen.main?.visibleFrame ?? windowFrame
    let defaultWidth: CGFloat = 1200
    let defaultHeight: CGFloat = 800
    let originX = (screenFrame.width - defaultWidth) / 2 + screenFrame.origin.x
    let originY = (screenFrame.height - defaultHeight) / 2 + screenFrame.origin.y
    self.setFrame(NSRect(x: originX, y: originY, width: defaultWidth, height: defaultHeight), display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
