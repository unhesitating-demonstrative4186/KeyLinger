import Foundation

enum AppLanguage: String, CaseIterable, Sendable {
    case system
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"

    var resourceName: String {
        switch self {
        case .simplifiedChinese:
            return "zh-Hans"
        case .traditionalChinese:
            return "zh-Hant"
        case .english:
            return "en"
        case .system:
            let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
            if preferred.hasPrefix("zh-hant") ||
                preferred.hasPrefix("zh-tw") ||
                preferred.hasPrefix("zh-hk") ||
                preferred.hasPrefix("zh-mo") {
                return "zh-Hant"
            }
            return preferred.hasPrefix("zh") ? "zh-Hans" : "en"
        }
    }
}

enum PollingFrequency: Int, CaseIterable, Identifiable, Sendable {
    case veryLow = 2
    case efficient = 5
    case balanced = 10
    case responsive = 20
    case high = 30

    var id: Int { rawValue }
}

@MainActor
final class AppSettings: ObservableObject {
    private enum Keys {
        static let language = "language"
        static let compactMode = "compactMode"
        static let pollingFrequency = "pollingFrequency"
        static let accentTheme = "accentTheme"
    }

    @Published var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }

    @Published var compactMode: Bool {
        didSet { defaults.set(compactMode, forKey: Keys.compactMode) }
    }

    @Published var pollingFrequency: PollingFrequency {
        didSet { defaults.set(pollingFrequency.rawValue, forKey: Keys.pollingFrequency) }
    }

    @Published var accentTheme: AccentTheme {
        didSet { defaults.set(accentTheme.rawValue, forKey: Keys.accentTheme) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let legacyDefaults = UserDefaults(suiteName: "local.keyboard-status")

        let storedLanguage = defaults.string(forKey: Keys.language)
            ?? legacyDefaults?.string(forKey: Keys.language)
        language = storedLanguage.flatMap(AppLanguage.init(rawValue:)) ?? .system

        if let storedCompactMode = defaults.object(forKey: Keys.compactMode) as? Bool {
            compactMode = storedCompactMode
        } else {
            compactMode = legacyDefaults?.bool(forKey: Keys.compactMode) ?? false
        }

        let storedFrequency = defaults.object(forKey: Keys.pollingFrequency) as? Int
            ?? legacyDefaults?.object(forKey: Keys.pollingFrequency) as? Int
        pollingFrequency = storedFrequency.flatMap(PollingFrequency.init(rawValue:)) ?? .balanced

        let storedAccentTheme = defaults.string(forKey: Keys.accentTheme)
        accentTheme = storedAccentTheme.flatMap(AccentTheme.init(rawValue:)) ?? .system

        // Preserve preferences when upgrading from the former local.keyboard-status bundle ID.
        defaults.set(language.rawValue, forKey: Keys.language)
        defaults.set(compactMode, forKey: Keys.compactMode)
        defaults.set(pollingFrequency.rawValue, forKey: Keys.pollingFrequency)
        defaults.set(accentTheme.rawValue, forKey: Keys.accentTheme)
    }
}

enum L10n {
    static func text(_ key: String, language: AppLanguage) -> String {
        bundle(for: language).localizedString(forKey: key, value: key, table: nil)
    }

    static func format(_ key: String, language: AppLanguage, _ arguments: CVarArg...) -> String {
        let format = text(key, language: language)
        return String(
            format: format,
            locale: Locale(identifier: language.resourceName),
            arguments: arguments
        )
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        let resourceName = language.resourceName

        if let path = Bundle.main.path(forResource: resourceName, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        if let path = Bundle.module.path(forResource: resourceName, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }

        return .main
    }
}
