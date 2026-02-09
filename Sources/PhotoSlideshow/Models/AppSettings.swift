import Foundation

enum TransitionStyle: String, CaseIterable, Identifiable {
    case fade = "Fade"
    case slideLeft = "Slide Left"
    case slideRight = "Slide Right"
    case slideUp = "Slide Up"
    case none = "None"

    var id: String { rawValue }
}

enum PhotoFitMode: String, CaseIterable, Identifiable {
    case fit = "Fit"
    case fill = "Fill"

    var id: String { rawValue }
}

@Observable
final class AppSettings {
    static let shared = AppSettings()

    var interval: Double {
        didSet { UserDefaults.standard.set(interval, forKey: "interval") }
    }
    var transition: TransitionStyle {
        didSet { UserDefaults.standard.set(transition.rawValue, forKey: "transition") }
    }
    var alwaysOnTop: Bool {
        didSet { UserDefaults.standard.set(alwaysOnTop, forKey: "alwaysOnTop") }
    }
    var showOnAllDesktops: Bool {
        didSet { UserDefaults.standard.set(showOnAllDesktops, forKey: "showOnAllDesktops") }
    }
    var windowOpacity: Double {
        didSet { UserDefaults.standard.set(windowOpacity, forKey: "windowOpacity") }
    }
    var fitMode: PhotoFitMode {
        didSet { UserDefaults.standard.set(fitMode.rawValue, forKey: "fitMode") }
    }
    var shuffle: Bool {
        didSet { UserDefaults.standard.set(shuffle, forKey: "shuffle") }
    }

    private init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            "interval": 5.0,
            "transition": TransitionStyle.fade.rawValue,
            "alwaysOnTop": true,
            "showOnAllDesktops": true,
            "windowOpacity": 1.0,
            "fitMode": PhotoFitMode.fit.rawValue,
            "shuffle": true,
        ])

        interval = defaults.double(forKey: "interval")
        transition = TransitionStyle(rawValue: defaults.string(forKey: "transition") ?? "") ?? .fade
        alwaysOnTop = defaults.bool(forKey: "alwaysOnTop")
        showOnAllDesktops = defaults.bool(forKey: "showOnAllDesktops")
        windowOpacity = defaults.double(forKey: "windowOpacity")
        fitMode = PhotoFitMode(rawValue: defaults.string(forKey: "fitMode") ?? "") ?? .fit
        shuffle = defaults.bool(forKey: "shuffle")
    }
}
