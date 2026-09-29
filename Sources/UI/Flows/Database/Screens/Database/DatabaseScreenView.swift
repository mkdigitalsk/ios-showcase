import DesignSystem
import SwiftUI

private enum NoteField: Hashable {
    case title
    case content
}

struct DatabaseScreenView: View {
    @Environment(NotesModel.self) private var model
    @FocusState private var focusedField: NoteField?
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(.databaseSubtitle)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                AddNoteCard(focus: $focusedField) { title, content in
                    Task { await model.insert(title: title, content: content) }
                }
                if model.loadFailed {
                    Text(.databaseError)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsError)
                }
                if model.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if model.notes.isEmpty {
                    Text(.databaseEmpty)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextSecondary)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(model.notes) { note in
                        NoteRow(note: note) {
                            Task { await model.delete(id: note.id) }
                        }
                    }
                    Button(String(localized: .databaseClearAll)) {
                        Task { await model.deleteAll() }
                    }
                    .buttonStyle(.dsSecondary)
                }
            }
            .screenPadding()
        }
        .scrollDismissesKeyboard(.interactively)
        .keyboardDoneButton { focusedField = nil }
        .background(Color.dsBackground)
        .navigationTitle(Text(.databaseTitle))
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: Text(.databaseSearch))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker(String(localized: .databaseSort), selection: sortSelection) {
                        ForEach(NoteSort.allCases, id: \.self) { sort in
                            Text(sort.text)
                        }
                    }
                } label: {
                    Label(String(localized: .databaseSort), systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .task(id: searchText) {
            if searchText != model.query {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
            }
            await model.search(searchText)
        }
    }

    private var sortSelection: Binding<NoteSort> {
        Binding(get: { model.sort }) { sort in
            Task { await model.sort(by: sort) }
        }
    }
}

private struct AddNoteCard: View {
    var focus: FocusState<NoteField?>.Binding
    let onAdd: (String, String) -> Void
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        VStack(spacing: Spacing.m) {
            FormField(label: Text(.databaseNoteTitle), error: nil) {
                TextField(String(localized: .databaseNoteTitleHint), text: $title)
                    .focused(focus, equals: .title)
            }
            FormField(label: Text(.databaseNoteContent), error: nil) {
                TextField(String(localized: .databaseNoteContentHint), text: $content, axis: .vertical)
                    .focused(focus, equals: .content)
            }
            Button(String(localized: .databaseAdd)) {
                onAdd(title, content)
                title = ""
                content = ""
                focus.wrappedValue = nil
            }
            .buttonStyle(.dsPrimary)
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

private struct NoteRow: View {
    let note: Note
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(note.title)
                    .font(.dsBodyEmphasis)
                    .foregroundStyle(Color.dsTextPrimary)
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextPrimary)
                }
                Text(note.createdAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
            }
            Spacer()
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(Color.dsAccent)
            }
            .accessibilityLabel(Text(.databaseDelete))
        }
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

#Preview(traits: .modifier(NotesPreviewModifier())) {
    NavigationStack {
        DatabaseScreenView()
    }
}
