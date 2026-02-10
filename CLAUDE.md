# PhotoSlideshow

macOS native photo slideshow app - floating transparent window that displays photos from the system Photos library or a custom folder. Runs as a menu bar app.

## Tech Stack

- Swift 6 / SwiftUI + AppKit (NSPanel)
- PhotoKit (Photos framework)
- swiftc direct compilation + build.sh packaging

## Project Structure

```
Sources/PhotoSlideshow/
  App/          - main.swift, AppDelegate, MenuBarManager (main menu + status bar)
  PhotoKit/     - PhotoLibraryManager (auth), PhotoLoader (image loading)
  Window/       - FloatingPanel (NSPanel, hover tracking), WindowManager
  Views/        - SlideshowView, ControlsOverlay, PermissionView, SettingsView
  Models/       - SlideshowState (@Observable), AppSettings (UserDefaults)
scripts/        - build.sh (compile + .app bundle), run.sh
resources/      - Info.plist, entitlements
```

## Commands

- `bash scripts/build.sh` - compile and package .app bundle
- `bash scripts/run.sh` - build + launch
- `open build/PhotoSlideshow.app` - run built app

## Key Design

- Menu bar app: runs as status bar icon, no Dock presence
- FloatingPanel: NSPanel subclass, transparent background, always-on-top, draggable, cross-desktop
- Photo sources: system Photos library (PhotoKit) or custom folder (recursive file scan)
- Random shuffle without repeats until all photos shown
- Preloads next photo for instant transitions
- Hover reveals: traffic light buttons (fade animation), window border, bottom controls
- Click anywhere to toggle play/pause
- iCloud photos: network access allowed, failures auto-skipped
- Settings persisted via UserDefaults

## Notes

- Requires Photos permission when using Photos Library source (prompted on first launch)
- Custom folder mode requires no special permissions
- Ad-hoc signing: Photos permission resets on each rebuild (limitation of ad-hoc codesign)
- No Xcode needed - builds with swiftc from Command Line Tools
- Uses `-Xfrontend -disable-deserialization-safety` to work around compiler/SDK version mismatch
