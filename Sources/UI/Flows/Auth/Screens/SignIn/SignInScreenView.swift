import DesignSystem
import SwiftUI

struct SignInScreenView: View {
    @Environment(SessionModel.self) private var sessionModel
    @State private var viewModel: SignInViewModel
    @FocusState private var focus: Field?
    private let onSignUp: () -> Void

    private enum Field {
        case email
        case password
    }

    init(viewModel: SignInViewModel = SignInViewModel(), onSignUp: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignUp = onSignUp
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                Text(.signInTitle)
                    .font(.dsTitle)
                    .foregroundStyle(Color.dsTextPrimary)
                VStack(spacing: Spacing.m) {
                    FormField(label: Text(.signInEmailLabel), error: viewModel.emailError.map { Text($0.text) }) {
                        TextField(String(localized: .signInEmailPlaceholder), text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focus = .password }
                    }
                    FormField(label: Text(.signInPasswordLabel), error: viewModel.passwordError.map { Text($0.text) }) {
                        PasswordField(placeholder: .signInPasswordPlaceholder, text: $viewModel.password)
                            .focused($focus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit(submit)
                    }
                }
                if let serverError = viewModel.serverError {
                    Text(serverError.text)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button(action: submit) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(Color.dsOnAccent)
                    } else {
                        Text(.signInButton)
                    }
                }
                .buttonStyle(.dsPrimary)
                .disabled(viewModel.isSubmitting)
                .accessibilityIdentifier("signIn.submit")
                HStack(spacing: Spacing.xs) {
                    Text(.signInNoAccount)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextSecondary)
                    Button(String(localized: .signInSignUp), action: onSignUp)
                        .font(.dsBodyEmphasis)
                        .foregroundStyle(Color.dsAccent)
                }
                TestAccountCard(fill: viewModel.fillTestAccount)
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.email) { viewModel.emailChanged() }
        .onChange(of: viewModel.password) { viewModel.passwordChanged() }
    }

    private func submit() {
        focus = nil
        Task {
            await viewModel.submit { email, password in
                try await sessionModel.signIn(email: email, password: password)
            }
        }
    }
}

private struct TestAccountCard: View {
    let fill: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s) {
            Text(.signInTestAccountHint)
                .font(.dsCaption)
                .foregroundStyle(Color.dsTextSecondary)
            Text(verbatim: SignInViewModel.testAccount.email)
                .font(.dsBody)
                .foregroundStyle(Color.dsTextPrimary)
            Text(verbatim: SignInViewModel.testAccount.password)
                .font(.dsBody)
                .foregroundStyle(Color.dsTextPrimary)
            Button(String(localized: .signInTestAccountFill), action: fill)
                .buttonStyle(.dsSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

#Preview("Empty", traits: .modifier(SignedOutPreviewModifier())) {
    NavigationStack {
        SignInScreenView {}
    }
}

#Preview("Filled", traits: .modifier(SignedOutPreviewModifier())) {
    NavigationStack {
        SignInScreenView(viewModel: SignInViewModel(email: "test@example.com", password: "Test123!")) {}
    }
}
