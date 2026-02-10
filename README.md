# Photo Slideshow

A lightweight macOS menu bar app that displays a floating photo slideshow on your desktop.

![macOS 14.0+](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

<!-- TODO: Add screenshot or GIF here -->

## Why

We all have thousands of photos but rarely revisit them. Photo Slideshow puts a floating window on your desktop that quietly cycles through your memories — no need to open an album or set aside time. Just glance over while you work.

## Features

- **Floating window** — Always-on-top transparent panel, visible across all desktops
- **Two photo sources** — System Photos Library (via PhotoKit) or any custom folder
- **Smart shuffle** — Random playback without repeats until all photos are shown
- **Smooth transitions** — Fade, slide (left/right/up), or instant switch
- **Menu bar app** — Lives in the status bar, no Dock icon clutter
- **Hover controls** — Window buttons and playback controls appear on mouse hover
- **Customizable** — Interval, opacity, fit mode, transition style, and more
- **iCloud support** — Loads iCloud photos with automatic skip on failure
- **Lightweight** — No Xcode required, compiles with `swiftc` directly

## Install

### Download

Grab the latest `.zip` from the [Releases](https://github.com/nateleex/photo-slideshow/releases) page, unzip, and drag `PhotoSlideshow.app` to your Applications folder.

### Build from Source

Requires macOS 14.0+ with Apple Silicon and Xcode Command Line Tools.

```bash
git clone https://github.com/nateleex/photo-slideshow.git
cd photo-slideshow
bash scripts/build.sh
open build/PhotoSlideshow.app
```

> **Note:** The build script currently targets `arm64` (Apple Silicon) only.

## Usage

The app runs as a **menu bar icon** (camera icon in the status bar).

### Controls

| Action | How |
|--------|-----|
| Play / Pause | Click on the slideshow window |
| Next photo | → or click Next in hover controls |
| Previous photo | ← or click Previous in hover controls |
| Settings | ⌘, or status bar menu → Settings |
| Close window | Esc or hover → close button |
| Quit | ⌘Q or status bar menu → Quit |

### Settings

- **Photo Source** — Photos Library or Custom Folder
- **Interval** — Time between photos (seconds)
- **Transition** — Fade, Slide Left/Right/Up, None
- **Opacity** — Window transparency
- **Fit Mode** — Fit (letterbox) or Fill (crop)
- **Always on Top** — Keep window above other windows
- **Show on All Desktops** — Visible on every Space
- **Shuffle** — Random order vs sequential

### Permissions

- **Photos Library mode**: macOS will prompt for Photos access on first launch
- **Custom Folder mode**: No special permissions needed

> **Note:** The app uses ad-hoc code signing. If you rebuild from source, macOS will treat it as a new app and re-prompt for Photos permission.

## Technical Highlights

- Built with **Swift 6 / SwiftUI + AppKit** — no Xcode project needed
- Compiled directly with `swiftc` via a simple shell script
- Uses `NSPanel` for proper floating window behavior (key window without activation)
- Preloads next photo for instant transitions
- Ad-hoc code signing (no Apple Developer account required)

## License

[MIT](LICENSE)
