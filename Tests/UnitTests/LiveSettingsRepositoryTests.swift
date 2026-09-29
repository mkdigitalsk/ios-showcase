import Foundation
@testable import TemplateIOS
import Testing

/// The real store: defaults in a throwaway suite, the photo in a temporary directory.
struct LiveSettingsRepositoryTests {
    private func makeRepository() -> (LiveSettingsRepository, UserDefaults) {
        let suite = "LiveSettingsRepositoryTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let directory = URL.temporaryDirectory.appending(path: suite)
        return (LiveSettingsRepository(defaults: defaults, directory: directory), defaults)
    }

    @Test
    func `the appearance defaults to system and round-trips`() async {
        let (repository, _) = makeRepository()
        #expect(await repository.loadAppearance() == .system)

        await repository.saveAppearance(.dark)

        #expect(await repository.loadAppearance() == .dark)
    }

    @Test
    func `the photo is a file that a nil save removes`() async throws {
        let (repository, _) = makeRepository()
        #expect(try await repository.loadProfilePhoto() == nil)

        try await repository.saveProfilePhoto(Data([7, 7, 7]))
        #expect(try await repository.loadProfilePhoto() == Data([7, 7, 7]))

        try await repository.saveProfilePhoto(nil)
        #expect(try await repository.loadProfilePhoto() == nil)
    }
}
