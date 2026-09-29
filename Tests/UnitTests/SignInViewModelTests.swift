@testable import TemplateIOS
import Testing

@MainActor
struct SignInViewModelTests {
    @Test
    func `empty fields are refused before anything is sent`() async {
        let viewModel = SignInViewModel()
        var sent = false

        await viewModel.submit { _, _ in sent = true }

        #expect(viewModel.emailError == .empty)
        #expect(viewModel.passwordError == .empty)
        #expect(!sent)
    }

    @Test
    func `the form judges the format and the strength itself`() async {
        let viewModel = SignInViewModel(email: "not-an-email", password: "short")
        await viewModel.submit { _, _ in }
        #expect(viewModel.emailError == .invalid)
        #expect(viewModel.passwordError == .tooShort)

        viewModel.email = "a@b.co"
        viewModel.password = "longbutweak"
        await viewModel.submit { _, _ in }
        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == .weak)
    }

    @Test
    func `a valid form sends the trimmed email`() async {
        let viewModel = SignInViewModel(email: "  a@b.co ", password: "Secret1@")
        var received: (String, String)?

        await viewModel.submit { email, password in received = (email, password) }

        #expect(received?.0 == "a@b.co")
        #expect(received?.1 == "Secret1@")
        #expect(viewModel.serverError == nil)
    }

    @Test
    func `the server's answer becomes the form's error and a change clears it`() async {
        let viewModel = SignInViewModel(email: "a@b.co", password: "Secret1@")

        await viewModel.submit { _, _ in throw AuthError.invalidCredentials }
        #expect(viewModel.serverError == .invalidCredentials)

        viewModel.passwordChanged()
        #expect(viewModel.serverError == nil)
    }

    @Test
    func `fill writes the test account and clears every error`() async {
        let viewModel = SignInViewModel()
        await viewModel.submit { _, _ in }

        viewModel.fillTestAccount()

        #expect(viewModel.email == SignInViewModel.testAccount.email)
        #expect(viewModel.password == SignInViewModel.testAccount.password)
        #expect(viewModel.emailError == nil)
        #expect(viewModel.passwordError == nil)
    }
}
