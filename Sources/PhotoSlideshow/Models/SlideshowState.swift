import AppKit
import Photos

@Observable
final class SlideshowState {
    var previousImage: NSImage?
    var currentImage: NSImage?
    var nextImage: NSImage?
    var isPlaying = false
    var photoCount = 0
    var currentIndex = -1
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    var isLoading = false
    var errorMessage: String?

    private var assets: PHFetchResult<PHAsset>?
    private var folderImageURLs: [URL] = []
    private var usedIndices = Set<Int>()
    private var history: [Int] = []
    private var historyPosition = -1
    private var timer: Timer?
    private let settings = AppSettings.shared
    private let loader = PhotoLoader()
    private var preloadedNext: NSImage?
    private var preloadedNextIndex: Int?
    private var loadGeneration = 0
    private var consecutiveFailures = 0

    var hasPhotos: Bool { photoCount > 0 }
    var isAuthorized: Bool { authorizationStatus == .authorized || authorizationStatus == .limited }

    var needsAuthorization: Bool {
        settings.photoSource == .photosLibrary && !isAuthorized
    }

    var noPhotosMessage: String {
        if settings.photoSource == .customFolder && settings.customFolderPath == nil {
            return "Select a folder in Settings (⌘,)"
        }
        return "No photos found"
    }

    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }
                self.authorizationStatus = status
                // Only load Photos library if still on that source
                if (status == .authorized || status == .limited)
                    && self.settings.photoSource == .photosLibrary {
                    self.loadLibrary()
                    self.play()
                }
                // Bring window back to front after authorization dialog
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
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

    func loadInitialSource() {
        if settings.photoSource == .customFolder {
            if let path = settings.customFolderPath {
                loadFolder(path: path)
                if hasPhotos { play() }
            }
        } else {
            checkAuthorization()
            if isAuthorized { play() }
        }
    }

    func reload() {
        pause()
        loadGeneration += 1
        currentImage = nil
        previousImage = nil
        currentIndex = -1
        photoCount = 0
        usedIndices.removeAll()
        history.removeAll()
        historyPosition = -1
        preloadedNext = nil
        preloadedNextIndex = nil
        consecutiveFailures = 0
        assets = nil
        folderImageURLs = []
        loadInitialSource()
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

    func loadFolder(path: String) {
        isLoading = true
        let gen = loadGeneration
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let url = URL(fileURLWithPath: path)
            let fm = FileManager.default
            guard let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }

            let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "heic", "heif", "tiff", "tif", "bmp", "gif", "webp"]
            var urls: [URL] = []
            for case let fileURL as URL in enumerator {
                if imageExtensions.contains(fileURL.pathExtension.lowercased()) {
                    urls.append(fileURL)
                }
            }
            urls.sort { $0.path < $1.path }

            DispatchQueue.main.async {
                guard let self, self.loadGeneration == gen else { return }
                self.folderImageURLs = urls
                self.photoCount = urls.count
                self.isLoading = false
                if self.photoCount > 0 && self.currentImage == nil {
                    self.showNext()
                }
            }
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
        guard photoCount > 0 else { return }

        // If we're browsing back in history, step forward through it
        if historyPosition >= 0 && historyPosition < history.count - 1 {
            historyPosition += 1
            let index = history[historyPosition]
            currentIndex = index
            // Invalidate preloaded image since we're navigating history
            preloadedNext = nil
            preloadedNextIndex = nil
            isLoading = true
            let gen = loadGeneration
            loadImage(at: index) { [weak self] image in
                DispatchQueue.main.async {
                    guard let self, self.loadGeneration == gen else { return }
                    if let image {
                        self.previousImage = self.currentImage
                        self.currentImage = image
                    }
                    self.isLoading = false
                }
            }
            return
        }

        if let preloaded = preloadedNext, let idx = preloadedNextIndex {
            previousImage = currentImage
            currentImage = preloaded
            currentIndex = idx
            appendToHistory(idx)
            preloadedNext = nil
            preloadedNextIndex = nil
            consecutiveFailures = 0
            preloadNext()
            return
        }

        let index = pickNextIndex()
        currentIndex = index
        isLoading = true
        let gen = loadGeneration

        loadImage(at: index) { [weak self] image in
            DispatchQueue.main.async {
                guard let self, self.loadGeneration == gen else { return }
                if let image {
                    self.previousImage = self.currentImage
                    self.currentImage = image
                    self.appendToHistory(index)
                    self.consecutiveFailures = 0
                } else {
                    self.consecutiveFailures += 1
                    if self.consecutiveFailures < 10 {
                        self.showNext()
                    } else {
                        self.isLoading = false
                    }
                    return
                }
                self.isLoading = false
                self.preloadNext()
            }
        }
    }

    func showPrevious() {
        guard photoCount > 0 else { return }
        guard historyPosition > 0 else { return }

        historyPosition -= 1
        let index = history[historyPosition]
        currentIndex = index
        // Invalidate preloaded image since we're navigating history
        preloadedNext = nil
        preloadedNextIndex = nil
        isLoading = true
        let gen = loadGeneration

        loadImage(at: index) { [weak self] image in
            DispatchQueue.main.async {
                guard let self, self.loadGeneration == gen else { return }
                if let image {
                    self.previousImage = self.currentImage
                    self.currentImage = image
                }
                self.isLoading = false
            }
        }
    }

    private func loadImage(at index: Int, completion: @escaping (NSImage?) -> Void) {
        if settings.photoSource == .customFolder {
            guard index < folderImageURLs.count else { completion(nil); return }
            let url = folderImageURLs[index]
            DispatchQueue.global(qos: .userInitiated).async {
                let image = NSImage(contentsOf: url)
                completion(image)
            }
        } else {
            guard let assets, index < assets.count else { completion(nil); return }
            let asset = assets.object(at: index)
            loader.loadImage(for: asset, targetSize: CGSize(width: 1920, height: 1080), completion: completion)
        }
    }

    private func appendToHistory(_ index: Int) {
        // If we navigated back and then went forward with a new photo,
        // discard the forward history beyond current position
        if historyPosition < history.count - 1 {
            history.removeSubrange((historyPosition + 1)...)
        }
        history.append(index)
        historyPosition = history.count - 1
        // Cap history size to avoid unbounded memory growth
        if history.count > 500 {
            history.removeFirst(100)
            historyPosition -= 100
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
        guard photoCount > 0 else { return }
        let index = pickNextIndex()
        let gen = loadGeneration
        loadImage(at: index) { [weak self] image in
            DispatchQueue.main.async {
                guard let self, self.loadGeneration == gen else { return }
                self.preloadedNext = image
                self.preloadedNextIndex = index
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
