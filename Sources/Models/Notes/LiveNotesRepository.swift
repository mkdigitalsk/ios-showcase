import Foundation
import SwiftData

@Model
final class NoteEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date

    init(id: UUID, title: String, content: String, createdAt: Date) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
    }
}

/// SwiftData behind the protocol; the domain `Note` never leaves this actor as an entity.
@ModelActor
actor LiveNotesRepository: NotesRepository {
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        try ModelContainer(
            for: NoteEntity.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory),
        )
    }

    func notes(matching query: String, sortedBy sort: NoteSort) async throws -> [Note] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        var descriptor = FetchDescriptor<NoteEntity>(sortBy: Self.sortDescriptors(for: sort))
        if !trimmed.isEmpty {
            descriptor.predicate = #Predicate {
                $0.title.localizedStandardContains(trimmed) || $0.content.localizedStandardContains(trimmed)
            }
        }
        return try modelContext.fetch(descriptor).map { Note(id: $0.id, title: $0.title, content: $0.content, createdAt: $0.createdAt) }
    }

    func insert(_ note: Note) async throws {
        modelContext.insert(NoteEntity(id: note.id, title: note.title, content: note.content, createdAt: note.createdAt))
        try modelContext.save()
    }

    func delete(id: UUID) async throws {
        try modelContext.delete(model: NoteEntity.self, where: #Predicate { $0.id == id })
        try modelContext.save()
    }

    func deleteAll() async throws {
        try modelContext.delete(model: NoteEntity.self)
        try modelContext.save()
    }

    private static func sortDescriptors(for sort: NoteSort) -> [SortDescriptor<NoteEntity>] {
        switch sort {
        case .dateDescending: [SortDescriptor(\.createdAt, order: .reverse)]
        case .dateAscending: [SortDescriptor(\.createdAt, order: .forward)]
        case .titleAscending: [SortDescriptor(\.title, comparator: .localizedStandard, order: .forward)]
        case .titleDescending: [SortDescriptor(\.title, comparator: .localizedStandard, order: .reverse)]
        }
    }
}
