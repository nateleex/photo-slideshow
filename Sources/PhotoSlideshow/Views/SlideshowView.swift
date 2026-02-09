import SwiftUI

struct SlideshowView: View {
    let state: SlideshowState
    private let settings = AppSettings.shared
    @State private var isHovering = false
    @State private var imageID = UUID()

    var body: some View {
        ZStack {
            Color.black

            if !state.isAuthorized {
                PermissionView(state: state)
            } else if let image = state.currentImage {
                photoView(image)
            } else if state.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .colorScheme(.dark)
            } else if !state.hasPhotos {
                Text("No photos found")
                    .foregroundStyle(.secondary)
                    .font(.title2)
            }

            if state.isAuthorized && state.hasPhotos {
                ControlsOverlay(state: state, isHovering: isHovering)
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onChange(of: state.currentImage) { _, _ in
            withAnimation(transitionAnimation) {
                imageID = UUID()
            }
        }
    }

    @ViewBuilder
    private func photoView(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: settings.fitMode == .fit ? .fit : .fill)
            .id(imageID)
            .transition(makeTransition())
            .clipped()
    }

    private var transitionAnimation: Animation? {
        settings.transition == .none ? nil : .easeInOut(duration: 0.5)
    }

    private func makeTransition() -> AnyTransition {
        switch settings.transition {
        case .fade:
            return .opacity
        case .slideLeft:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .slideRight:
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        case .slideUp:
            return .asymmetric(
                insertion: .move(edge: .bottom),
                removal: .move(edge: .top)
            )
        case .none:
            return .identity
        }
    }
}
