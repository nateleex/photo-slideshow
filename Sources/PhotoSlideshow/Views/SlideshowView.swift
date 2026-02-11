import SwiftUI

struct SlideshowView: View {
    let state: SlideshowState
    private let settings = AppSettings.shared
    @State private var isHovering = false
    @State private var crossfade: Double = 1.0 // 0 = showing previous, 1 = showing current

    var body: some View {
        ZStack {
            if state.currentImage == nil {
                Color.black.opacity(0.7)
            }

            if state.needsAuthorization {
                PermissionView(state: state)
            } else if state.currentImage != nil {
                // Dual-layer crossfade: previous underneath, current on top
                if let prev = state.previousImage {
                    photoView(prev)
                        .opacity(1.0 - crossfade)
                }
                if let current = state.currentImage {
                    photoView(current)
                        .opacity(crossfade)
                }
            } else if state.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .colorScheme(.dark)
            } else if !state.hasPhotos {
                Text(state.noPhotosMessage)
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }

            if !state.needsAuthorization && state.hasPhotos {
                ControlsOverlay(state: state, isHovering: isHovering)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .opacity(isHovering ? 1 : 0)
        )
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            guard state.hasPhotos else { return }
            state.togglePlayPause()
            state.restartTimerIfPlaying()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onChange(of: state.currentImage) { _, newImage in
            guard newImage != nil else { return }
            switch settings.transition {
            case .fade:
                crossfade = 0
                withAnimation(.easeInOut(duration: 1.0)) {
                    crossfade = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.05) {
                    state.previousImage = nil
                }
            default:
                crossfade = 1
                state.previousImage = nil
            }
        }
    }

    @ViewBuilder
    private func photoView(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: settings.fitMode == .fit ? .fit : .fill)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .clipped()
    }
}
