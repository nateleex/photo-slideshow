import SwiftUI

struct SettingsView: View {
    @Bindable var settings = AppSettings.shared
    var onWindowUpdate: (() -> Void)?

    var body: some View {
        Form {
            Section("Playback") {
                HStack {
                    Text("Interval")
                    Slider(value: $settings.interval, in: 1...60, step: 1)
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
            }

            Section("Display") {
                Picker("Photo fit", selection: $settings.fitMode) {
                    ForEach(PhotoFitMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }

                HStack {
                    Text("Opacity")
                    Slider(value: $settings.windowOpacity, in: 0.3...1.0, step: 0.05)
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
        .frame(width: 320, height: 360)
    }
}
