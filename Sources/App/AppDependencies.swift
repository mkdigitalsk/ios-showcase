import Foundation
import SwiftData
import TemplateAPI

@MainActor
struct AppDependencies {
    let sessionModel: SessionModel
    let deepLinkModel: DeepLinkModel
    let settingsModel: SettingsModel
    let storageModel: StorageModel
    let notesModel: NotesModel
    let apisModel: ApisModel
    let notificationsModel: NotificationsModel
    /// The one place the session's own `Live*` repositories are built; the root calls it per session.
    let makeAuthenticated: @MainActor (Session) -> AuthenticatedModels

    /// The push client is the app delegate's — it is fed by delegate callbacks, so it is born there.
    static func makeLive(pushClient: any PushClient) -> AppDependencies {
        let baseURL = AppConfiguration.apiBaseURL
        return AppDependencies(
            sessionModel: SessionModel(
                repository: LiveAuthRepository(client: UnauthenticatedClient(baseURL: baseURL)),
                tokenStore: KeychainTokenStore(defaults: .standard),
            ),
            deepLinkModel: DeepLinkModel(parser: DeepLinkParser(scheme: AppConfiguration.urlScheme)),
            settingsModel: SettingsModel(repository: LiveSettingsRepository(defaults: .standard), crashReporter: LiveCrashReporter()),
            storageModel: StorageModel(repository: LiveStorageRepository(defaults: .standard)),
            notesModel: NotesModel(repository: LiveNotesRepository(modelContainer: makeNotesContainer())),
            apisModel: ApisModel(locationClient: LiveLocationClient(), biometricClient: LiveBiometricClient()),
            notificationsModel: NotificationsModel(localClient: LiveLocalNotificationClient(), pushClient: pushClient),
            makeAuthenticated: { session in
                let client = AuthenticatedClient(baseURL: baseURL, token: session.token)
                return AuthenticatedModels(
                    remoteNotesModel: RemoteNotesModel(repository: LiveRemoteNotesRepository(client: client)),
                    accountModel: AccountModel(repository: LiveUserRepository(client: client)),
                )
            },
        )
    }

    private static func makeNotesContainer() -> ModelContainer {
        do {
            return try LiveNotesRepository.makeContainer()
        } catch {
            preconditionFailure("The notes store could not open: \(error)")
        }
    }
}
