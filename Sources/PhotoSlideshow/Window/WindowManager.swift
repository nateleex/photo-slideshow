import AppKit
import SwiftUI

final class WindowManager {
    private var panel: FloatingPanel?
    private let state: SlideshowState
    private let settings = AppSettings.shared
    private var closeObserver: Any?

    init(state: SlideshowState) {
        self.state = state
    }

    func showWindow() {
        if let panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let width: CGFloat = min(800, screenFrame.width * 0.6)
        let height: CGFloat = width * 9.0 / 16.0
        let x = screenFrame.midX - width / 2
        let y = screenFrame.midY - height / 2
        let rect = NSRect(x: x, y: y, width: width, height: height)

        let panel = FloatingPanel(contentRect: rect)

        let rootView = SlideshowView(state: state)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.sizingOptions = []
        panel.contentView = hostingView

        closeObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if let observer = self.closeObserver {
                NotificationCenter.default.removeObserver(observer)
            }
            self.panel = nil
            self.closeObserver = nil
        }

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    func updateWindowAppearance() {
        panel?.updateWindowBehavior()
    }

    func close() {
        panel?.close()
    }

    var window: NSWindow? { panel }
}
