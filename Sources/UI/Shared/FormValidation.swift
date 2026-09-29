/// What a form can judge on its own, before the server sees it.
enum FormValidation {
    static let minimumPasswordLength = 8

    static func isValidEmail(_ email: String) -> Bool {
        email.wholeMatch(of: /[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/) != nil
    }

    static func isPasswordLongEnough(_ password: String) -> Bool {
        password.count >= minimumPasswordLength
    }

    /// An upper-case letter, a lower-case one, a digit and one of `@$!%*?&`, nothing else.
    static func isStrongPassword(_ password: String) -> Bool {
        password.wholeMatch(of: /(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}/) != nil
    }
}
