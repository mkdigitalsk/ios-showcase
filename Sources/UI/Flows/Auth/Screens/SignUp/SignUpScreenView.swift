import DesignSystem
import SwiftUI

struct SignUpScreenView: View {
    @Environment(SessionModel.self) private var sessionModel
    @State private var viewModel: SignUpViewModel
    @FocusState private var focus: Field?
    private let onSignIn: () -> Void

    private enum Field {
        case email
        case password
        case confirmPassword
    }

    init(viewModel: SignUpViewModel = SignUpViewModel(), onSignIn: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onSignIn = onSignIn
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                Text(.signUpTitle)
                    .font(.dsTitle)
                    .foregroundStyle(Color.dsTextPrimary)
                VStack(spacing: Spacing.m) {
                    FormField(label: Text(.signUpEmailLabel), error: viewModel.emailError.map { Text($0.text) }) {
                        TextField(String(localized: .signUpEmailPlaceholder), text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focus = .password }
                    }
                    FormField(label: Text(.signUpPasswordLabel), error: viewModel.passwordError.map { Text($0.text) }) {
                        PasswordField(placeholder: .signUpPasswordPlaceholder, text: $viewModel.password, contentType: .newPassword)
                            .focused($focus, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focus = .confirmPassword }
                    }
                    FormField(label: Text(.signUpConfirmPasswordLabel), error: viewModel.confirmPasswordError.map { Text($0.text) }) {
                        PasswordField(placeholder: .signUpConfirmPasswordPlaceholder, text: $viewModel.confirmPassword, contentType: .newPassword)
                            .focused($focus, equals: .confirmPassword)
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
                        Text(.signUpButton)
                    }
                }
                .buttonStyle(.dsPrimary)
                .disabled(viewModel.isSubmitting)
                .accessibilityIdentifier("signUp.submit")
                HStack(spacing: Spacing.xs) {
                    Text(.signUpHasAccount)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextSecondary)
                    Button(String(localized: .signUpSignIn), action: onSignIn)
                        .font(.dsBodyEmphasis)
                        .foregroundStyle(Color.dsAccent)
                }
                Link(String(localized: .signUpPrivacy), destination: AppConfiguration.privacyURL)
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.signUpScreen))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.email) { viewModel.emailChanged() }
        .onChange(of: viewModel.password) { viewModel.passwordChanged() }
        .onChange(of: viewModel.confirmPassword) { viewModel.passwordChanged() }
    }

    private func submit() {
        focus = nil
        Task {
            await viewModel.submit { email, password in
                try await sessionModel.signUp(email: email, password: password)
            }
        }
    }
}

#Preview(traits: .modifier(SignedOutPreviewModifier())) {
    NavigationStack {
        SignUpScreenView {}
    }
}
