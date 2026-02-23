import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let state = SlideshowState()
    private(set) var windowManager: WindowManager!
    private(set) var menuBarManager: MenuBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Show in menu bar on launch; switches to .accessory when window loses focus
        NSApp.setActivationPolicy(.regular)

        windowManager = WindowManager(state: state)
        menuBarManager = MenuBarManager(state: state, windowManager: windowManager)

        menuBarManager.setupMainMenu()
        menuBarManager.setupStatusBar()
        windowManager.showWindow()

        state.loadInitialSource()

        NotificationCenter.default.addObserver(
            self, selector: #selector(openSettings(_:)),
            name: .openSettings, object: nil
        )

        // Escape closes window (not quit)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.windowManager.close()
                return nil
            }
            return event
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        // Re-check Photos permission in case user granted it in System Settings
        if state.needsAuthorization {
            state.checkAuthorization()
            if state.isAuthorized && !state.isPlaying {
                state.play()
            }
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc func showSlideshow(_ sender: Any?) {
        windowManager.showWindow()
    }

    @objc func openSettings(_ sender: Any?) {
        menuBarManager.showSettings()
    }

    @objc func togglePlayPause(_ sender: Any?) {
        state.togglePlayPause()
    }

    @objc func nextPhoto(_ sender: Any?) {
        state.showNext()
        state.restartTimerIfPlaying()
    }

    @objc func previousPhoto(_ sender: Any?) {
        state.showPrevious()
        state.restartTimerIfPlaying()
    }
}
