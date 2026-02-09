import AppKit
import SwiftUI

final class WindowManager {
    private var panel: FloatingPanel?
    private let state: SlideshowState
    private let settings = AppSettings.shared

    init(state: SlideshowState) {
        self.state = state
    }

    func showWindow() {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let width: CGFloat = 480
        let height: CGFloat = 360
        let x = screenFrame.maxX - width - 40
        let y = screenFrame.maxY - height - 40
        let rect = NSRect(x: x, y: y, width: width, height: height)

        let panel = FloatingPanel(contentRect: rect)

        let rootView = SlideshowView(state: state)
        let hostingView = NSHostingView(rootView: rootView)
        panel.contentView = hostingView

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    func updateWindowAppearance() {
        panel?.updateWindowBehavior()
    }

    func close() {
        panel?.close()
        panel = nil
    }

    var window: NSWindow? { panel }
}
