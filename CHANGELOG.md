# Changelog

## [2026-02-12]

### Added
- Ken Burns effect toggle — photos slowly zoom and pan during display
- Slide Down and Zoom transition effects
- Interval slider now restarts timer immediately when changed

### Changed
- Minimum interval increased from 1s to 3s for better viewing experience
- Transition duration proportional to interval: `min(1.0, interval × 0.3)`
- Two-layer alternating architecture for seamless photo transitions
  - Each layer has independent Ken Burns and transition animations
  - Eliminates jitter and jumps during photo switches

### Fixed
- Slide transitions now properly animate both incoming and outgoing photos
- Ken Burns no longer jumps or reverses direction mid-animation

## [2026-02-10] v1.0.0 — Open Source Release

### Added
- Always-on-top pin toggle button in hover controls (circle button next to playback controls)
- Window activates app on focus, showing menu bar; hides from Dock when unfocused
- README.md with feature overview, install/build instructions, and usage guide
- MIT License
- App icon (mountain/sun design, generated via CoreGraphics)

### Changed
- Photos now display with 26pt continuous rounded corners (macOS widget style)
- Hover border matches photo rounded corners
- Bundle identifier changed to `com.liziran.photoslideshow`
- Removed conflicting `setActivationPolicy(.regular)` from main.swift
- build.sh now copies AppIcon.icns into app bundle Resources

### Added (earlier)
- Custom folder photo source: select any folder to use as photo source (recursive scan)
- Photo source picker in Settings (Photos Library / Custom Folder)
- Menu bar (status bar) app mode: app runs as a status bar icon instead of Dock app
- Status bar menu with Show Slideshow, Settings, and Quit options
- Click-to-toggle play/pause on the slideshow window
- Hover to reveal window controls: traffic light buttons, border outline, bottom controls bar
- Window close observer for proper cleanup when closing via traffic light button

### Changed
- Window background is now transparent (no black letterboxing around photos)
- Window buttons (close/minimize/zoom) hidden by default, fade in on hover
- Escape key now closes the window instead of quitting the app
- Initial window size increased to 800x450 (16:9), centered on screen
- Settings window height increased to accommodate new Photo Source section
- Opacity slider changed to continuous (no step) to allow precise 100% setting

### Fixed
- Closing the settings window no longer quits the main app
- Title bar black strip removed via `.ignoresSafeArea()` and hidden window buttons

## [2026-02-09]

### Added
- Initial implementation of PhotoSlideshow app
- Floating window (NSPanel) with always-on-top, cross-desktop support
- PhotoKit integration for accessing system Photos library
- Random shuffle without repeats, with preloading
- Transition animations (fade, slide left/right/up, none)
- Hover controls overlay (play/pause, next, previous)
- Settings panel (interval, transition, opacity, fit mode, etc.)
- Keyboard shortcuts (Space, arrows, Cmd+,, Cmd+Q, Esc)
- Menu bar with app menu, controls menu, window menu
- Permission flow with system settings redirect
- iCloud photo support with auto-skip on failure
- build.sh for swiftc compilation + .app bundle packaging
