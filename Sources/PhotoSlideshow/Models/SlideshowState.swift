import AppKit
import Photos

@Observable
final class SlideshowState {
    var currentImage: NSImage?
    var nextImage: NSImage?
    var isPlaying = false
    var photoCount = 0
    var currentIndex = -1
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    var isLoading = false
    var errorMessage: String?

    private var assets: PHFetchResult<PHAsset>?
    private var usedIndices = Set<Int>()
    private var timer: Timer?
    private let settings = AppSettings.shared
    private let loader = PhotoLoader()
    private var preloadedNext: NSImage?
    private var preloadedNextIndex: Int?

    var hasPhotos: Bool { photoCount > 0 }
    var isAuthorized: Bool { authorizationStatus == .authorized || authorizationStatus == .limited }

    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized || status == .limited {
                    self?.loadLibrary()
                }
            }
        }
    }

    func checkAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        authorizationStatus = status
        if status == .authorized || status == .limited {
            loadLibrary()
        }
    }

    func loadLibrary() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let result = PHAsset.fetchAssets(with: options)
        assets = result
        photoCount = result.count
        if photoCount > 0 && currentImage == nil {
            showNext()
        }
    }

    func play() {
        guard hasPhotos else { return }
        isPlaying = true
        startTimer()
    }

    func pause() {
        isPlaying = false
        stopTimer()
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    func showNext() {
        guard let assets, photoCount > 0 else { return }

        if let preloaded = preloadedNext, let idx = preloadedNextIndex {
            currentImage = preloaded
            currentIndex = idx
            preloadedNext = nil
            preloadedNextIndex = nil
            preloadNext()
            return
        }

        let index = pickNextIndex()
        currentIndex = index
        isLoading = true

        let asset = assets.object(at: index)
        loader.loadImage(for: asset, targetSize: CGSize(width: 1920, height: 1080)) { [weak self] image in
            DispatchQueue.main.async {
                guard let self else { return }
                if let image {
                    self.currentImage = image
                } else {
                    // iCloud download failed, skip to next
                    self.showNext()
                    return
                }
                self.isLoading = false
                self.preloadNext()
            }
        }
    }

    func showPrevious() {
        guard let assets, photoCount > 0 else { return }
        var index = currentIndex - 1
        if index < 0 { index = photoCount - 1 }
        currentIndex = index
        isLoading = true

        let asset = assets.object(at: index)
        loader.loadImage(for: asset, targetSize: CGSize(width: 1920, height: 1080)) { [weak self] image in
            DispatchQueue.main.async {
                guard let self else { return }
                if let image {
                    self.currentImage = image
                }
                self.isLoading = false
            }
        }
    }

    private func pickNextIndex() -> Int {
        guard photoCount > 0 else { return 0 }

        if settings.shuffle {
            if usedIndices.count >= photoCount {
                usedIndices.removeAll()
            }
            var index: Int
            repeat {
                index = Int.random(in: 0..<photoCount)
            } while usedIndices.contains(index) && usedIndices.count < photoCount
            usedIndices.insert(index)
            return index
        } else {
            let next = (currentIndex + 1) % photoCount
            return next
        }
    }

    private func preloadNext() {
        guard let assets, photoCount > 0 else { return }
        let index = pickNextIndex()
        let asset = assets.object(at: index)
        loader.loadImage(for: asset, targetSize: CGSize(width: 1920, height: 1080)) { [weak self] image in
            DispatchQueue.main.async {
                self?.preloadedNext = image
                self?.preloadedNextIndex = index
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: settings.interval, repeats: true) { [weak self] _ in
            self?.showNext()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func restartTimerIfPlaying() {
        if isPlaying {
            startTimer()
        }
    }
}
