import SwiftUI

struct PermissionView: View {
    let state: SlideshowState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            if state.authorizationStatus == .notDetermined {
                Text("Photo Slideshow needs access to your photos")
                    .font(.headline)
                    .foregroundStyle(.white)

                Button("Grant Access") {
                    state.requestAuthorization()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Photo access denied")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Open System Settings to grant access")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Open Settings") {
                    PhotoLibraryManager.openSystemSettings()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
    }
}
