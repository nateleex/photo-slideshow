# PhotoSlideshow - Development Progress

## Status: Functional

### Completed
- [x] Project structure and build system
- [x] AppDelegate + NSApplication entry point
- [x] FloatingPanel (NSPanel subclass, transparent, hover tracking)
- [x] WindowManager (window lifecycle, close observer)
- [x] PhotoLibraryManager (authorization)
- [x] PhotoLoader (PHCachingImageManager)
- [x] SlideshowState (@Observable, timer, shuffle, preload)
- [x] SlideshowView (SwiftUI, transitions, click-to-toggle)
- [x] ControlsOverlay (hover controls)
- [x] PermissionView (auth flow)
- [x] SettingsView (Form, photo source picker, folder chooser)
- [x] AppSettings (UserDefaults, photo source, custom folder)
- [x] MenuBarManager (main menu + status bar item)
- [x] Menu bar app mode (no Dock icon, status bar icon)
- [x] Custom folder photo source
- [x] Transparent window background
- [x] Hover-reveal traffic light buttons
- [x] build.sh + run.sh scripts

### Pending
- [ ] PHPhotoLibraryChangeObserver for live library updates
- [ ] Remember window position/size across launches
- [ ] Drag-and-drop folder onto window
