import Foundation
@testable import TemplateIOS
import Testing

@MainActor
struct SettingsModelTests {
    @Test
    func `load reads the appearance and the photo`() async {
        let repository = StubSettingsRepository(appearance: .dark, photo: Data([1, 2, 3]))
        let model = SettingsModel(repository: repository, crashReporter: StubCrashReporter())

        await model.load()

        #expect(model.appearance == .dark)
        #expect(model.profilePhoto == Data([1, 2, 3]))
    }

    @Test
    func `the appearance shows at once and is saved`() async {
        let repository = StubSettingsRepository()
        let model = SettingsModel(repository: repository, crashReporter: StubCrashReporter())

        await model.setAppearance(.light)

        #expect(model.appearance == .light)
        #expect(await repository.appearance == .light)
    }

    @Test
    func `a photo is saved before it shows, and nil removes it`() async {
        let repository = StubSettingsRepository(photo: Data([9]))
        let model = SettingsModel(repository: repository, crashReporter: StubCrashReporter())
        await model.load()

        await model.setProfilePhoto(Data([4, 5]))
        #expect(model.profilePhoto == Data([4, 5]))
        #expect(await repository.photo == Data([4, 5]))

        await model.setProfilePhoto(nil)
        #expect(model.profilePhoto == nil)
        #expect(await repository.photo == nil)
    }
}
