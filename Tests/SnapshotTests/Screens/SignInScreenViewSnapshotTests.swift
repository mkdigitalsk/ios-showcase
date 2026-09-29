import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct SignInScreenViewSnapshotTests {
    private let sessionModel = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore())

    @Test
    func empty() {
        assertScreenSnapshots(of: screen(SignInViewModel()))
    }

    @Test
    func invalid() async {
        let viewModel = SignInViewModel(email: "not-an-email", password: "short")
        await viewModel.submit { _, _ in }

        assertScreenSnapshots(of: screen(viewModel), variants: [.light])
    }

    @Test
    func rejected() async {
        let viewModel = SignInViewModel(email: "test@example.com", password: "Wrong1@@")
        await viewModel.submit { _, _ in throw AuthError.invalidCredentials }

        assertScreenSnapshots(of: screen(viewModel), variants: [.light])
    }

    private func screen(_ viewModel: SignInViewModel) -> some View {
        NavigationStack {
            SignInScreenView(viewModel: viewModel) {}
        }
        .environment(sessionModel)
    }
}
