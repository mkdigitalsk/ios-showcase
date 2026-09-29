import Foundation
import Observation

/// What this device remembers regardless of who is signed in: the appearance and the profile photo.
@MainActor
@Observable
final class SettingsModel {
    struct TestCrash: Error {}

    private(set) var appearance = AppearanceMode.system
    private(set) var profilePhoto: Data?
    private(set) var photoSaveFailed = false
    private let repository: any SettingsRepository
    private let crashReporter: any CrashReporter

    init(repository: any SettingsRepository, crashReporter: any CrashReporter) {
        self.repository = repository
        self.crashReporter = crashReporter
    }

    func load() async {
        let mode = await repository.loadAppearance()
        let photo = try? await repository.loadProfilePhoto()
        guard !Task.isCancelled else { return }
        appearance = mode
        profilePhoto = photo
    }

    func setAppearance(_ mode: AppearanceMode) async {
        appearance = mode
        await repository.saveAppearance(mode)
    }

    func setProfilePhoto(_ data: Data?) async {
        do {
            try await repository.saveProfilePhoto(data)
            guard !Task.isCancelled else { return }
            profilePhoto = data
            photoSaveFailed = false
        } catch where error.isCancellation {
            return
        } catch {
            guard !Task.isCancelled else { return }
            photoSaveFailed = true
        }
    }

    /// Records a handled error first, then crashes — both paths of a crash reporter in one tap.
    func triggerTestCrash() -> Never {
        crashReporter.record(TestCrash())
        fatalError("Test crash for the crash reporter")
    }
}
