import AppKit

final class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        isFloatingPanel = true
        hidesOnDeactivate = false
        animationBehavior = .utilityWindow
        backgroundColor = .black
        hasShadow = true
        minSize = NSSize(width: 200, height: 150)

        updateWindowBehavior()
    }

    func updateWindowBehavior() {
        let settings = AppSettings.shared
        level = settings.alwaysOnTop ? .floating : .normal
        collectionBehavior = settings.showOnAllDesktops
            ? [.canJoinAllSpaces, .fullScreenAuxiliary]
            : [.fullScreenAuxiliary]
        alphaValue = settings.windowOpacity
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func keyDown(with event: NSEvent) {
        // Let the responder chain handle it
        nextResponder?.keyDown(with: event)
    }
}
