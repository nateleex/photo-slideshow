import SwiftUI

struct ControlsOverlay: View {
    let state: SlideshowState
    let isHovering: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                Button(action: { state.showPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)

                Button(action: { state.togglePlayPause() }) {
                    Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                }
                .buttonStyle(.plain)

                Button(action: { state.showNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.bottom, 16)
        }
        .opacity(isHovering ? 1 : 0)
    }
}
