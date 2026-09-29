import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct SettingsScreenViewSnapshotTests {
    @Test
    func `demo account`() async {
        let settings = SettingsModel(repository: StubSettingsRepository(appearance: .dark), crashReporter: StubCrashReporter())
        await settings.load()
        let account = AccountModel(repository: StubUserRepository())
        await account.load()

        assertScreenSnapshots(of: screen(settings: settings, account: account))
    }

    @Test
    func `deletable account`() async {
        let settings = SettingsModel(repository: StubSettingsRepository(), crashReporter: StubCrashReporter())
        let account = AccountModel(repository: StubUserRepository(user: User(id: 5, email: "someone@example.com", isDemo: false)))
        await account.load()

        assertScreenSnapshots(of: screen(settings: settings, account: account), variants: [.light])
    }

    private func screen(settings: SettingsModel, account: AccountModel) -> some View {
        NavigationStack {
            SettingsScreenView(version: "1.0", build: "1", buildType: "debug", apiHost: "api.showcase.mkdigital.sk")
        }
        .environment(settings)
        .environment(account)
        .environment(SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore()))
        .environment(NotesModel(repository: StubNotesRepository()))
        .environment(StorageModel(repository: StubStorageRepository()))
    }
}
