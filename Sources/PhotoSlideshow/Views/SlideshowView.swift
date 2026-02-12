import SwiftUI

struct SlideshowView: View {
    let state: SlideshowState
    private let settings = AppSettings.shared
    @State private var isHovering = false
    @State private var progress: Double = 1.0

    // Two alternating layers for seamless Ken Burns
    @State private var useLayerA = true
    @State private var imageA: NSImage?
    @State private var imageB: NSImage?
    @State private var kbA = KenBurnsValues()
    @State private var kbB = KenBurnsValues()
    @State private var transA = LayerTransition()
    @State private var transB = LayerTransition()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if state.currentImage == nil {
                    Color.black.opacity(0.7)
                }

                if state.needsAuthorization {
                    PermissionView(state: state)
                } else if state.currentImage != nil {
                    // Layer A
                    if let img = imageA {
                        photoView(img)
                            .scaleEffect(settings.kenBurns ? kbA.scale : 1)
                            .offset(x: settings.kenBurns ? kbA.offsetX : 0,
                                    y: settings.kenBurns ? kbA.offsetY : 0)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .scaleEffect(transA.scale)
                            .offset(x: transA.offsetX * geo.size.width,
                                    y: transA.offsetY * geo.size.height)
                            .opacity(progress)
                    }
                    // Layer B
                    if let img = imageB {
                        photoView(img)
                            .scaleEffect(settings.kenBurns ? kbB.scale : 1)
                            .offset(x: settings.kenBurns ? kbB.offsetX : 0,
                                    y: settings.kenBurns ? kbB.offsetY : 0)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .scaleEffect(transB.scale)
                            .offset(x: transB.offsetX * geo.size.width,
                                    y: transB.offsetY * geo.size.height)
                            .opacity(1.0 - progress)
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
        }
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
            guard let newImage else { return }

            let transitionDuration = settings.transition == .none
                ? 0.0
                : min(1.0, settings.interval * 0.3)

            // Place new image on the inactive layer
            let target = KenBurnsValues.random()
            if useLayerA {
                imageA = newImage
                // Set start position immediately
                kbA = KenBurnsValues.start(for: target)
            } else {
                imageB = newImage
                kbB = KenBurnsValues.start(for: target)
            }

            // Ken Burns: animate the new layer over 8 seconds
            if settings.kenBurns {
                withAnimation(.linear(duration: 16.0)) {
                    if useLayerA {
                        kbA = target
                    } else {
                        kbB = target
                    }
                }
            }

            // Set incoming layer start position (immediate, layer is invisible)
            let incoming = LayerTransition.incoming(for: settings.transition)
            if useLayerA {
                transA = incoming
            } else {
                transB = incoming
            }

            // Transition
            let outgoing = LayerTransition.outgoing(for: settings.transition)
            if transitionDuration == 0 {
                progress = useLayerA ? 1 : 0
                if useLayerA {
                    transA = LayerTransition()
                    transB = outgoing
                } else {
                    transB = LayerTransition()
                    transA = outgoing
                }
            } else {
                progress = useLayerA ? 0 : 1
                withAnimation(.easeInOut(duration: transitionDuration)) {
                    progress = useLayerA ? 1 : 0
                    if useLayerA {
                        transA = LayerTransition()
                        transB = outgoing
                    } else {
                        transB = LayerTransition()
                        transA = outgoing
                    }
                }
            }

            // Alternate for next time
            useLayerA.toggle()
        }
        .onChange(of: settings.interval) { _, _ in
            state.restartTimerIfPlaying()
        }
    }


    @ViewBuilder
    private func photoView(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: settings.fitMode == .fit ? .fit : .fill)
    }
}

// MARK: - Layer Transition

private struct LayerTransition: Equatable {
    var offsetX: CGFloat = 0  // fraction of width (-1, 0, 1)
    var offsetY: CGFloat = 0  // fraction of height
    var scale: CGFloat = 1.0

    static func incoming(for style: TransitionStyle) -> LayerTransition {
        switch style {
        case .slideLeft:  return LayerTransition(offsetX: 1)
        case .slideRight: return LayerTransition(offsetX: -1)
        case .slideUp:    return LayerTransition(offsetY: 1)
        case .slideDown:  return LayerTransition(offsetY: -1)
        case .zoom:       return LayerTransition(scale: 0.7)
        default:          return LayerTransition()
        }
    }

    static func outgoing(for style: TransitionStyle) -> LayerTransition {
        switch style {
        case .slideLeft:  return LayerTransition(offsetX: -1)
        case .slideRight: return LayerTransition(offsetX: 1)
        case .slideUp:    return LayerTransition(offsetY: -1)
        case .slideDown:  return LayerTransition(offsetY: 1)
        case .zoom:       return LayerTransition(scale: 0.7)
        default:          return LayerTransition()
        }
    }
}

// MARK: - Ken Burns

private struct KenBurnsValues: Equatable {
    var scale: Double = 1.0
    var offsetX: Double = 0
    var offsetY: Double = 0

    static func random() -> KenBurnsValues {
        let scale = Double.random(in: 1.05...1.14)
        let ox = Double.random(in: -12...12)
        let oy = Double.random(in: -8...8)
        if Bool.random() {
            // Zoom in: normal → zoomed
            return KenBurnsValues(scale: scale, offsetX: ox, offsetY: oy)
        } else {
            // Zoom out: zoomed → normal
            return KenBurnsValues(scale: 1.0, offsetX: 0, offsetY: 0)
        }
    }

    static func start(for target: KenBurnsValues) -> KenBurnsValues {
        if target.scale > 1.02 {
            // Target is zoomed in, so start from normal
            return KenBurnsValues(scale: 1.0, offsetX: 0, offsetY: 0)
        } else {
            // Target is normal, so start zoomed in (zoom out effect)
            let scale = Double.random(in: 1.05...1.14)
            let ox = Double.random(in: -12...12)
            let oy = Double.random(in: -8...8)
            return KenBurnsValues(scale: scale, offsetX: ox, offsetY: oy)
        }
    }
}

