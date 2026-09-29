@testable import TemplateIOS
import Testing

@MainActor
struct AccountModelTests {
    @Test
    func `load shows the account`() async {
        let model = AccountModel(repository: StubUserRepository())

        await model.load()

        #expect(model.user == .stub)
    }

    @Test
    func `a deletion the server agreed to answers true`() async {
        let repository = StubUserRepository()
        let model = AccountModel(repository: repository)

        #expect(await model.deleteAccount())
        #expect(await repository.deleted)
        #expect(!model.deleteFailed)
    }

    @Test
    func `a refused deletion is a state the screen shows`() async {
        let model = AccountModel(repository: StubUserRepository(failure: .unavailable))

        #expect(await model.deleteAccount() == false)
        #expect(model.deleteFailed)
        #expect(!model.isDeleting)
    }
}
