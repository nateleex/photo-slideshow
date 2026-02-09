import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let state = SlideshowState()
    private(set) var windowManager: WindowManager!
    private(set) var menuBarManager: MenuBarManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowManager = WindowManager(state: state)
        menuBarManager = MenuBarManager(state: state, windowManager: windowManager)

        menuBarManager.setupMainMenu()
        windowManager.showWindow()

        state.checkAuthorization()
        if state.isAuthorized {
            state.play()
        }

        // Monitor for Escape key
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // Escape
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
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
