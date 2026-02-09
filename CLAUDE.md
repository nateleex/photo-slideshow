# PhotoSlideshow

macOS native photo slideshow app - floating window that randomly displays photos from the system Photos library.

## Tech Stack

- Swift 6 / SwiftUI + AppKit (NSPanel)
- PhotoKit (Photos framework)
- swiftc direct compilation + build.sh packaging

## Project Structure

```
Sources/PhotoSlideshow/
  App/          - main.swift, AppDelegate, MenuBarManager
  PhotoKit/     - PhotoLibraryManager (auth), PhotoLoader (image loading)
  Window/       - FloatingPanel (NSPanel subclass), WindowManager
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

- FloatingPanel: NSPanel subclass, always-on-top, draggable, cross-desktop
- Random shuffle without repeats until all photos shown
- Preloads next photo for instant transitions
- iCloud photos: network access allowed, failures auto-skipped
- Settings persisted via UserDefaults

## Notes

- Requires Photos permission (prompted on first launch)
- No Xcode needed - builds with swiftc from Command Line Tools
- Uses `-Xfrontend -disable-deserialization-safety` to work around compiler/SDK version mismatch
