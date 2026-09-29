import Foundation
@testable import TemplateIOS
import Testing

@MainActor
struct NotesModelTests {
    @Test
    func `search filters on the title or the content, ignoring case`() async {
        let model = NotesModel(repository: StubNotesRepository())

        await model.search("APPLES")

        #expect(model.notes.map(\.title) == ["Groceries"])
        #expect(!model.isLoading)
    }

    @Test
    func `sort orders the list both ways`() async {
        let model = NotesModel(repository: StubNotesRepository())
        await model.search("")
        #expect(model.notes.map(\.title) == ["Ideas", "Groceries"])

        await model.sort(by: .titleAscending)
        #expect(model.notes.map(\.title) == ["Groceries", "Ideas"])

        await model.sort(by: .dateAscending)
        #expect(model.notes.map(\.title) == ["Groceries", "Ideas"])
    }

    @Test
    func `insert trims and reloads, and a blank title is ignored`() async {
        let repository = StubNotesRepository(notes: [])
        let model = NotesModel(repository: repository)
        await model.search("")

        await model.insert(title: "   ", content: "nothing")
        #expect(await repository.notes.isEmpty)

        await model.insert(title: "  Title ", content: " body ")
        #expect(model.notes.map(\.title) == ["Title"])
        #expect(model.notes[0].content == "body")
    }

    @Test
    func `delete and delete all reload`() async {
        let model = NotesModel(repository: StubNotesRepository())
        await model.search("")

        await model.delete(id: model.notes[0].id)
        #expect(model.notes.count == 1)

        await model.deleteAll()
        #expect(model.notes.isEmpty)
    }

    @Test
    func `a store that fails is a state the screen shows`() async {
        let model = NotesModel(repository: StubNotesRepository(fails: true))

        await model.search("")

        #expect(model.loadFailed)
        #expect(!model.isLoading)
    }
}
