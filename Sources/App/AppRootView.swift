import SwiftUI

/// The auth gate: splash until the stored token is answered, then the auth flow or the app with the
/// session's own models in its environment.
struct AppRootView: View {
    @Environment(SessionModel.self) private var sessionModel
    @State private var authenticated: AuthenticatedModels?
    let makeAuthenticated: @MainActor (Session) -> AuthenticatedModels

    var body: some View {
        Group {
            if sessionModel.isRestoring {
                SplashView()
            } else if sessionModel.session == nil {
                AuthFlowView()
            } else if let authenticated {
                MainTabView()
                    .environment(authenticated.remoteNotesModel)
                    .environment(authenticated.accountModel)
            } else {
                SplashView()
            }
        }
        .task {
            await sessionModel.restore()
        }
        .onChange(of: sessionModel.session, initial: true) { _, session in
            authenticated = session.map(makeAuthenticated)
        }
    }
}

#Preview("Signed in", traits: .modifier(SessionPreviewModifier()), .modifier(StoragePreviewModifier()), .modifier(NotesPreviewModifier()), .modifier(SettingsPreviewModifier()), .modifier(ApisPreviewModifier()), .modifier(NotificationsPreviewModifier())) {
    AppRootView { _ in AuthenticatedModels.stub() }
}

#Preview("Signed out", traits: .modifier(SignedOutPreviewModifier())) {
    AppRootView { _ in AuthenticatedModels.stub() }
}
