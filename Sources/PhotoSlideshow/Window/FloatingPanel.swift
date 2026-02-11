import AppKit

extension Notification.Name {
    static let updateWindowBehavior = Notification.Name("updateWindowBehavior")
}

final class FloatingPanel: NSPanel {
    private var trackingArea: NSTrackingArea?

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        isMovableByWindowBackground = true
        isFloatingPanel = true
        hidesOnDeactivate = false
        animationBehavior = .utilityWindow
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        minSize = NSSize(width: 200, height: 150)

        // Start with buttons invisible, show on hover
        for type: NSWindow.ButtonType in [.closeButton, .miniaturizeButton, .zoomButton] {
            standardWindowButton(type)?.alphaValue = 0
        }

        updateWindowBehavior()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleUpdateBehavior),
            name: .updateWindowBehavior, object: nil
        )
    }

    @objc private func handleUpdateBehavior() {
        updateWindowBehavior()
    }

    override var contentView: NSView? {
        didSet { setupTrackingArea() }
    }

    private func setupTrackingArea() {
        guard let contentView else { return }
        if let old = trackingArea {
            contentView.removeTrackingArea(old)
        }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        contentView.addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        setWindowButtonsVisible(true)
    }

    override func mouseExited(with event: NSEvent) {
        setWindowButtonsVisible(false)
    }

    private func setWindowButtonsVisible(_ visible: Bool) {
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            for type: NSWindow.ButtonType in [.closeButton, .miniaturizeButton, .zoomButton] {
                standardWindowButton(type)?.animator().alphaValue = visible ? 1 : 0
            }
        }
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

    override func becomeKey() {
        super.becomeKey()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    override func resignKey() {
        super.resignKey()
        NSApp.setActivationPolicy(.accessory)
    }

    override func keyDown(with event: NSEvent) {
        nextResponder?.keyDown(with: event)
    }
}
