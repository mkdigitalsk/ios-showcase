import Foundation
import Observation

/// The sign-in form's own state — what it can judge before the session model is asked.
@MainActor
@Observable
final class SignInViewModel {
    enum EmailError: Equatable {
        case empty
        case invalid
    }

    enum PasswordError: Equatable {
        case empty
        case tooShort
        case weak
    }

    /// The shared test account the sign-in card fills in.
    static let testAccount = (email: "test01@mkdigital.sk", password: "MKDigitalTest1@")

    var email: String
    var password: String
    private(set) var emailError: EmailError?
    private(set) var passwordError: PasswordError?
    private(set) var serverError: AuthError?
    private(set) var isSubmitting = false

    init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
    }

    func emailChanged() {
        emailError = nil
        serverError = nil
    }

    func passwordChanged() {
        passwordError = nil
        serverError = nil
    }

    func fillTestAccount() {
        email = Self.testAccount.email
        password = Self.testAccount.password
        emailChanged()
        passwordChanged()
    }

    /// Validates, then hands the credentials to `signIn`; an `AuthError` it throws becomes the form's error.
    func submit(_ signIn: @MainActor (_ email: String, _ password: String) async throws -> Void) async {
        guard validate() else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await signIn(email.trimmingCharacters(in: .whitespacesAndNewlines), password)
        } catch let error as AuthError {
            serverError = error
        } catch where error.isCancellation {
            return
        } catch {
            serverError = .unavailable
        }
    }

    private func validate() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        emailError = if trimmedEmail.isEmpty {
            .empty
        } else if !FormValidation.isValidEmail(trimmedEmail) {
            .invalid
        } else {
            nil
        }
        passwordError = if password.isEmpty {
            .empty
        } else if !FormValidation.isPasswordLongEnough(password) {
            .tooShort
        } else if !FormValidation.isStrongPassword(password) {
            .weak
        } else {
            nil
        }
        return emailError == nil && passwordError == nil
    }
}

extension SignInViewModel.EmailError {
    var text: LocalizedStringResource {
        switch self {
        case .empty: .signInEmailEmpty
        case .invalid: .signInEmailInvalid
        }
    }
}

extension SignInViewModel.PasswordError {
    var text: LocalizedStringResource {
        switch self {
        case .empty: .signInPasswordEmpty
        case .tooShort: .signInPasswordShort
        case .weak: .signInPasswordWeak
        }
    }
}
