@testable import TemplateIOS
import Testing

@MainActor
struct SignUpViewModelTests {
    @Test
    func `every field is judged before anything is sent`() async {
        let viewModel = SignUpViewModel(email: "a@b.co", password: "Secret1@", confirmPassword: "Secret1!")
        var sent = false

        await viewModel.submit { _, _ in sent = true }

        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
        #expect(viewModel.confirmPasswordError == .mismatch)
        #expect(!sent)
    }

    @Test
    func `a taken email lands on the email field`() async {
        let viewModel = SignUpViewModel(email: "a@b.co", password: "Secret1@", confirmPassword: "Secret1@")

        await viewModel.submit { _, _ in throw AuthError.emailTaken }

        #expect(viewModel.emailError == .alreadyExists)
        #expect(viewModel.serverError == nil)
    }

    @Test
    func `any other failure is the form's`() async {
        let viewModel = SignUpViewModel(email: "a@b.co", password: "Secret1@", confirmPassword: "Secret1@")

        await viewModel.submit { _, _ in throw AuthError.offline }

        #expect(viewModel.emailError == nil)
        #expect(viewModel.serverError == .offline)
    }
}
