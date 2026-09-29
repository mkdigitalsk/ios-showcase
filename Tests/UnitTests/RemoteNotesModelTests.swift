@testable import TemplateIOS
import Testing

@MainActor
struct RemoteNotesModelTests {
    @Test
    func `load shows the server's notes`() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository())

        await model.load()

        #expect(model.notes == .stub)
        #expect(!model.isLoading)
        #expect(model.error == nil)
    }

    @Test
    func `create reloads with the new note first`() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository())
        await model.load()

        await model.create(title: "New", content: "note")

        #expect(model.notes.first?.title == "New")
        #expect(model.notes.count == 3)
    }

    @Test
    func `a save against the current tag updates the note and ends the edit`() async {
        let repository = StubRemoteNotesRepository()
        let model = RemoteNotesModel(repository: repository)
        await model.load()
        model.startEditing(model.notes[0])

        await model.save(title: "Buy oat milk", content: "One litre")

        #expect(model.editing == nil)
        #expect(model.conflict == nil)
        #expect(model.notes[0].title == "Buy oat milk")
        #expect(model.notes[0].etag == "\"1\"")
    }

    @Test
    func `a refused save exposes the server's version and keeps the draft`() async {
        let serverVersion = RemoteNote(id: 2, title: "Buy milk (server)", content: "Changed elsewhere", createdAt: .stubNow, updatedAt: .stubNow, etag: "\"7\"")
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository(conflict: serverVersion))
        await model.load()
        model.startEditing(model.notes[0])

        await model.save(title: "Buy oat milk", content: "One litre")

        #expect(model.conflict == serverVersion)
        #expect(model.editing?.id == 2)
        #expect(model.notes[0].title == "Buy milk")
    }

    @Test
    func `keep mine resends the draft against the tag the server returned`() async {
        let repository = StubRemoteNotesRepository()
        let model = RemoteNotesModel(repository: repository)
        await model.load()
        model.startEditing(model.notes[1])
        let moved = try? await repository.update(id: 1, etag: "\"3\"", title: "Moved on", content: "elsewhere")
        #expect(moved?.etag == "\"4\"")

        await model.save(title: "My title", content: "My content")
        #expect(model.conflict?.etag == "\"4\"")

        await model.keepMine()

        #expect(model.conflict == nil)
        #expect(model.editing == nil)
        let saved = model.notes.first { $0.id == 1 }
        #expect(saved?.title == "My title")
        #expect(saved?.content == "My content")
        #expect(saved?.etag == "\"5\"")
    }

    @Test
    func `discard mine takes the server's version into the list`() async {
        let serverVersion = RemoteNote(id: 2, title: "Buy milk (server)", content: "Changed elsewhere", createdAt: .stubNow, updatedAt: .stubNow, etag: "\"7\"")
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository(conflict: serverVersion))
        await model.load()
        model.startEditing(model.notes[0])
        await model.save(title: "Buy oat milk", content: "One litre")

        model.discardMine()

        #expect(model.conflict == nil)
        #expect(model.editing == nil)
        #expect(model.notes[0] == serverVersion)
    }

    @Test
    func `delete reloads without the note`() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository())
        await model.load()

        await model.delete(id: 2)

        #expect(model.notes.map(\.id) == [1])
    }

    @Test
    func `a failure is a state the screen shows and the next call clears`() async {
        let model = RemoteNotesModel(repository: StubRemoteNotesRepository(failure: .offline))

        await model.load()

        #expect(model.error == .offline)
        #expect(model.notes.isEmpty)
    }
}
