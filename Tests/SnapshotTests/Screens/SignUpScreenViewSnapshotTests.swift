import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct SignUpScreenViewSnapshotTests {
    private let sessionModel = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore())

    @Test
    func empty() {
        assertScreenSnapshots(of: screen(SignUpViewModel()))
    }

    @Test
    func invalid() async {
        let viewModel = SignUpViewModel(email: "taken@example.com", password: "Secret1@", confirmPassword: "Secret1!")
        await viewModel.submit { _, _ in }

        assertScreenSnapshots(of: screen(viewModel), variants: [.light])
    }

    private func screen(_ viewModel: SignUpViewModel) -> some View {
        NavigationStack {
            SignUpScreenView(viewModel: viewModel) {}
        }
        .environment(sessionModel)
    }
}
