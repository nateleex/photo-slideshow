import SwiftUI

struct ControlsOverlay: View {
    let state: SlideshowState
    let isHovering: Bool
    private let settings = AppSettings.shared

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                HStack(spacing: 20) {
                    Button(action: {
                        state.showPrevious()
                        state.restartTimerIfPlaying()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)

                    Button(action: { state.togglePlayPause() }) {
                        Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        state.showNext()
                        state.restartTimerIfPlaying()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())

                Button(action: {
                    settings.alwaysOnTop.toggle()
                    NotificationCenter.default.post(name: .updateWindowBehavior, object: nil)
                }) {
                    Image(systemName: settings.alwaysOnTop ? "pin.fill" : "pin.slash")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)

                Button(action: {
                    NotificationCenter.default.post(name: .openSettings, object: nil)
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 16)
        }
        .opacity(isHovering ? 1 : 0)
    }
}
