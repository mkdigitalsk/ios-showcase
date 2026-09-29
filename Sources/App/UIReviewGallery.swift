#if DEBUG
import SwiftUI

/// Every screen on stub data — `-UIReviewGallery` at launch opens this instead of the app, and
/// `-UIReviewGalleryCase <case>` opens one case directly. The floating menu switches cases in place.
struct UIReviewGallery: View {
    static let launchArgument = "-UIReviewGallery"
    static let caseArgument = "-UIReviewGalleryCase"

    enum Case: String, CaseIterable, Identifiable {
        case signIn = "Sign in"
        case signInRejected = "Sign in · rejected"
        case signUp = "Sign up"
        case home = "Home"
        case networking = "Networking"
        case networkingOffline = "Networking · offline"
        case storage = "Storage"
        case apis = "APIs"
        case scanner = "Scanner"
        case database = "Database"
        case databaseEmpty = "Database · empty"
        case calendar = "Calendar"
        case notifications = "Notifications"
        case settings = "Settings"
        case components = "UI components"

        var id: Self {
            self
        }

        static func fromLaunchArguments() -> Case? {
            let arguments = CommandLine.arguments
            guard let index = arguments.firstIndex(of: caseArgument), index + 1 < arguments.count else { return nil }
            return allCases.first { String(describing: $0) == arguments[index + 1] }
        }
    }

    @State private var selected = Case.fromLaunchArguments() ?? .signIn
    @State private var models = GalleryModels()

    var body: some View {
        NavigationStack {
            GalleryCase(selected: selected, models: models)
        }
        .id(selected)
        .overlay(alignment: .bottomTrailing) {
            CaseMenu(selected: $selected)
        }
        .environment(models.session)
        .environment(models.deepLinks)
        .environment(models.remoteNotes)
        .environment(models.storage)
        .environment(models.apis)
        .environment(models.notes)
        .environment(models.notifications)
        .environment(models.settings)
        .environment(models.account)
        .task {
            await models.load()
        }
    }
}

private struct GalleryCase: View {
    let selected: UIReviewGallery.Case
    let models: GalleryModels

    var body: some View {
        switch selected {
        case .signIn:
            SignInScreenView {}
        case .signInRejected:
            SignInScreenView(viewModel: models.rejectedSignIn) {}
        case .signUp:
            SignUpScreenView {}
        case .home:
            HomeScreenView(features: HomeFeature.allCases) { _ in }
        case .networking:
            NetworkingScreenView()
        case .networkingOffline:
            NetworkingScreenView()
                .environment(models.offlineRemoteNotes)
        case .storage:
            StorageScreenView()
        case .apis:
            ApisScreenView()
        case .scanner:
            ScannerScreenView()
        case .database:
            DatabaseScreenView()
        case .databaseEmpty:
            DatabaseScreenView()
                .environment(models.emptyNotes)
        case .calendar:
            CalendarScreenView(viewModel: CalendarViewModel(today: .stubDay, calendar: .stub))
        case .notifications:
            NotificationsScreenView()
        case .settings:
            SettingsScreenView(version: "1.0", build: "1", buildType: "gallery", apiHost: "api.showcase.mkdigital.sk")
        case .components:
            UiComponentsScreenView()
        }
    }
}

private struct CaseMenu: View {
    @Binding var selected: UIReviewGallery.Case

    var body: some View {
        Menu {
            Picker("Case", selection: $selected) {
                ForEach(UIReviewGallery.Case.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
        } label: {
            Image(systemName: "square.grid.2x2")
                .font(.title3)
                .foregroundStyle(.white)
                .padding(12)
                .background(.black.opacity(0.55), in: .circle)
        }
        .accessibilityLabel("Gallery case")
        .padding(.trailing, 16)
        .padding(.bottom, 24)
    }
}

/// The stub-backed models the gallery's screens read — the same stubs the previews use.
@MainActor
@Observable
private final class GalleryModels {
    let session = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore())
    let deepLinks = DeepLinkModel(parser: DeepLinkParser(scheme: "gallery"))
    let remoteNotes = RemoteNotesModel(repository: StubRemoteNotesRepository())
    let offlineRemoteNotes = RemoteNotesModel(repository: StubRemoteNotesRepository(failure: .offline))
    let storage = StorageModel(repository: StubStorageRepository())
    let apis = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())
    let notes = NotesModel(repository: StubNotesRepository())
    let emptyNotes = NotesModel(repository: StubNotesRepository(notes: []))
    let notifications = NotificationsModel(localClient: StubLocalNotificationClient(permission: .granted), pushClient: StubPushClient())
    let settings = SettingsModel(repository: StubSettingsRepository(), crashReporter: StubCrashReporter())
    let account = AccountModel(repository: StubUserRepository())
    let rejectedSignIn = SignInViewModel(email: "test01@mkdigital.sk", password: "Wrong1@@")

    func load() async {
        await session.restore()
        await settings.load()
        await rejectedSignIn.submit { _, _ in throw AuthError.invalidCredentials }
    }
}
#endif
