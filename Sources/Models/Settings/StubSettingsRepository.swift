#if DEBUG
import Foundation

actor StubSettingsRepository: SettingsRepository {
    private(set) var appearance: AppearanceMode
    private(set) var photo: Data?

    init(appearance: AppearanceMode = .system, photo: Data? = nil) {
        self.appearance = appearance
        self.photo = photo
    }

    func loadAppearance() async -> AppearanceMode {
        appearance
    }

    func saveAppearance(_ mode: AppearanceMode) async {
        appearance = mode
    }

    func loadProfilePhoto() async throws -> Data? {
        photo
    }

    func saveProfilePhoto(_ data: Data?) async throws {
        photo = data
    }
}
#endif
