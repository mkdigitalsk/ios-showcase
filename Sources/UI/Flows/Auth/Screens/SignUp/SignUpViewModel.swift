import Foundation
import Observation

@MainActor
@Observable
final class SignUpViewModel {
    enum EmailError: Equatable {
        case empty
        case invalid
        case alreadyExists
    }

    enum PasswordError: Equatable {
        case empty
        case tooShort
        case weak
    }

    enum ConfirmPasswordError: Equatable {
        case empty
        case mismatch
    }

    var email: String
    var password: String
    var confirmPassword: String
    private(set) var emailError: EmailError?
    private(set) var passwordError: PasswordError?
    private(set) var confirmPasswordError: ConfirmPasswordError?
    private(set) var serverError: AuthError?
    private(set) var isSubmitting = false

    init(email: String = "", password: String = "", confirmPassword: String = "") {
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
    }

    func emailChanged() {
        emailError = nil
        serverError = nil
    }

    func passwordChanged() {
        passwordError = nil
        confirmPasswordError = nil
        serverError = nil
    }

    /// A taken email lands on the email field; any other failure is the form's.
    func submit(_ signUp: @MainActor (_ email: String, _ password: String) async throws -> Void) async {
        guard validate() else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await signUp(email.trimmingCharacters(in: .whitespacesAndNewlines), password)
        } catch AuthError.emailTaken {
            emailError = .alreadyExists
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
        confirmPasswordError = if confirmPassword.isEmpty {
            .empty
        } else if confirmPassword != password {
            .mismatch
        } else {
            nil
        }
        return emailError == nil && passwordError == nil && confirmPasswordError == nil
    }
}

extension SignUpViewModel.EmailError {
    var text: LocalizedStringResource {
        switch self {
        case .empty: .signUpEmailEmpty
        case .invalid: .signUpEmailInvalid
        case .alreadyExists: .signUpEmailAlreadyExists
        }
    }
}

extension SignUpViewModel.PasswordError {
    var text: LocalizedStringResource {
        switch self {
        case .empty: .signUpPasswordEmpty
        case .tooShort: .signUpPasswordShort
        case .weak: .signUpPasswordWeak
        }
    }
}

extension SignUpViewModel.ConfirmPasswordError {
    var text: LocalizedStringResource {
        switch self {
        case .empty: .signUpConfirmPasswordEmpty
        case .mismatch: .signUpConfirmPasswordMismatch
        }
    }
}
