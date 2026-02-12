import SwiftUI
import AppKit

struct SettingsView: View {
    @Bindable var settings = AppSettings.shared
    var onWindowUpdate: (() -> Void)?
    var onSourceChange: (() -> Void)?

    var body: some View {
        Form {
            Section("Photo Source") {
                Picker("Source", selection: $settings.photoSource) {
                    ForEach(PhotoSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .onChange(of: settings.photoSource) { _, _ in onSourceChange?() }

                if settings.photoSource == .customFolder {
                    HStack {
                        Text(settings.customFolderPath ?? "No folder selected")
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Spacer()
                        Button("Choose...") {
                            chooseFolder()
                        }
                    }
                }
            }

            Section("Playback") {
                HStack {
                    Text("Interval")
                    Slider(value: $settings.interval, in: 3...60, step: 1)
                    Text("\(Int(settings.interval))s")
                        .monospacedDigit()
                        .frame(width: 30, alignment: .trailing)
                }

                Picker("Transition", selection: $settings.transition) {
                    ForEach(TransitionStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }

                Toggle("Shuffle", isOn: $settings.shuffle)
                Toggle("Ken Burns effect", isOn: $settings.kenBurns)
            }

            Section("Display") {
                Picker("Photo fit", selection: $settings.fitMode) {
                    ForEach(PhotoFitMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }

                HStack {
                    Text("Opacity")
                    Slider(value: $settings.windowOpacity, in: 0.3...1.0)
                    Text("\(Int(settings.windowOpacity * 100))%")
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }
                .onChange(of: settings.windowOpacity) { _, _ in onWindowUpdate?() }
            }

            Section("Window") {
                Toggle("Always on top", isOn: $settings.alwaysOnTop)
                    .onChange(of: settings.alwaysOnTop) { _, _ in onWindowUpdate?() }

                Toggle("Show on all desktops", isOn: $settings.showOnAllDesktops)
                    .onChange(of: settings.showOnAllDesktops) { _, _ in onWindowUpdate?() }
            }
        }
        .formStyle(.grouped)
        .frame(width: 320, height: 480)
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose a folder containing photos"

        if panel.runModal() == .OK, let url = panel.url {
            settings.customFolderPath = url.path
            onSourceChange?()
        }
    }
}
