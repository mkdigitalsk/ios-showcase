import Foundation

/// The appearance in user defaults, the photo as one file in Application Support.
struct LiveSettingsRepository: SettingsRepository {
    private static let appearanceKey = "settings.appearance"
    private static let photoFile = "profile-photo.jpg"
    private nonisolated(unsafe) let defaults: UserDefaults
    private let directory: URL

    init(defaults: UserDefaults, directory: URL = URL.applicationSupportDirectory) {
        self.defaults = defaults
        self.directory = directory
    }

    func loadAppearance() async -> AppearanceMode {
        defaults.string(forKey: Self.appearanceKey).flatMap(AppearanceMode.init) ?? .system
    }

    func saveAppearance(_ mode: AppearanceMode) async {
        defaults.set(mode.rawValue, forKey: Self.appearanceKey)
    }

    func loadProfilePhoto() async throws -> Data? {
        let url = photoURL
        guard FileManager.default.fileExists(atPath: url.path()) else { return nil }
        return try Data(contentsOf: url)
    }

    func saveProfilePhoto(_ data: Data?) async throws {
        let url = photoURL
        guard let data else {
            if FileManager.default.fileExists(atPath: url.path()) {
                try FileManager.default.removeItem(at: url)
            }
            return
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }

    private var photoURL: URL {
        directory.appending(path: Self.photoFile)
    }
}
