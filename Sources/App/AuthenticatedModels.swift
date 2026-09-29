/// The models that exist only while a session does — built when it opens, dropped when it ends.
@MainActor
final class AuthenticatedModels {
    let remoteNotesModel: RemoteNotesModel
    let accountModel: AccountModel

    init(remoteNotesModel: RemoteNotesModel, accountModel: AccountModel) {
        self.remoteNotesModel = remoteNotesModel
        self.accountModel = accountModel
    }
}

#if DEBUG
extension AuthenticatedModels {
    static func stub() -> AuthenticatedModels {
        AuthenticatedModels(
            remoteNotesModel: RemoteNotesModel(repository: StubRemoteNotesRepository()),
            accountModel: AccountModel(repository: StubUserRepository()),
        )
    }
}
#endif
