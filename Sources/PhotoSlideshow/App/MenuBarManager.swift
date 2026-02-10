import AppKit
import SwiftUI

final class MenuBarManager {
    private let state: SlideshowState
    private let windowManager: WindowManager
    private var settingsWindow: NSWindow?
    private var statusItem: NSStatusItem?

    init(state: SlideshowState, windowManager: WindowManager) {
        self.state = state
        self.windowManager = windowManager
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "photo.fill", accessibilityDescription: "Photo Slideshow")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Show Slideshow", action: #selector(AppDelegate.showSlideshow(_:)), keyEquivalent: "")
        menu.addItem(withTitle: "Settings...", action: #selector(AppDelegate.openSettings(_:)), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Photo Slideshow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
    }

    func setupMainMenu() {
        let mainMenu = NSMenu()

        // App menu
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Photo Slideshow", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(AppDelegate.openSettings(_:)), keyEquivalent: ",")
        appMenu.addItem(settingsItem)
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Photo Slideshow", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // Controls menu
        let controlsMenu = NSMenu(title: "Controls")
        let playPauseItem = NSMenuItem(title: "Play/Pause", action: #selector(AppDelegate.togglePlayPause(_:)), keyEquivalent: " ")
        playPauseItem.keyEquivalentModifierMask = []
        controlsMenu.addItem(playPauseItem)

        let nextItem = NSMenuItem(title: "Next", action: #selector(AppDelegate.nextPhoto(_:)), keyEquivalent: String(Character(UnicodeScalar(NSRightArrowFunctionKey)!)))
        nextItem.keyEquivalentModifierMask = []
        controlsMenu.addItem(nextItem)

        let prevItem = NSMenuItem(title: "Previous", action: #selector(AppDelegate.previousPhoto(_:)), keyEquivalent: String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!)))
        prevItem.keyEquivalentModifierMask = []
        controlsMenu.addItem(prevItem)

        let controlsMenuItem = NSMenuItem()
        controlsMenuItem.submenu = controlsMenu
        mainMenu.addItem(controlsMenuItem)

        // Window menu
        let windowMenu = NSMenu(title: "Window")
        windowMenu.addItem(withTitle: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "Close", action: #selector(NSWindow.close), keyEquivalent: "w")

        let windowMenuItem = NSMenuItem()
        windowMenuItem.submenu = windowMenu
        mainMenu.addItem(windowMenuItem)

        NSApp.mainMenu = mainMenu
        NSApp.windowsMenu = windowMenu
    }

    func showSettings() {
        if let settingsWindow, settingsWindow.isVisible {
            settingsWindow.makeKeyAndOrderFront(nil)
            return
        }

        let view = SettingsView(
            onWindowUpdate: { [weak self] in
                self?.windowManager.updateWindowAppearance()
            },
            onSourceChange: { [weak self] in
                self?.state.reload()
            }
        )
        let hostingView = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.contentView = hostingView
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.settingsWindow = window
    }
}
