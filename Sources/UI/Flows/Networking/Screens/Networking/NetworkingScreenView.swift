import DesignSystem
import SwiftUI

private enum NoteField: Hashable {
    case newTitle
    case newContent
    case editedTitle
    case editedContent
}

struct NetworkingScreenView: View {
    @Environment(RemoteNotesModel.self) private var model
    @FocusState private var focusedField: NoteField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(.networkingSubtitle)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                CreateNoteCard(isSaving: model.isSaving, focus: $focusedField) { title, content in
                    Task { await model.create(title: title, content: content) }
                }
                if let error = model.error {
                    Text(error.text)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsError)
                }
                if model.isLoading, model.notes.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if model.notes.isEmpty {
                    Text(.networkingEmpty)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextSecondary)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(model.notes) { note in
                        if model.editing?.id == note.id {
                            EditNoteCard(note: note, isSaving: model.isSaving, focus: $focusedField, onCancel: model.cancelEditing) { title, content in
                                Task { await model.save(title: title, content: content) }
                            }
                        } else {
                            NoteCard(note: note) {
                                model.startEditing(note)
                            } onDelete: {
                                Task { await model.delete(id: note.id) }
                            }
                        }
                    }
                }
            }
            .screenPadding()
        }
        .scrollDismissesKeyboard(.interactively)
        .keyboardDoneButton { focusedField = nil }
        .background(Color.dsBackground)
        .navigationTitle(Text(.networkingTitle))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await model.load() }
                } label: {
                    Label(String(localized: .networkingRefresh), systemImage: "arrow.clockwise")
                }
            }
        }
        .task {
            await model.load()
        }
        .alert(Text(.networkingConflictTitle), isPresented: isConflictPresented, presenting: model.conflict) { _ in
            Button(String(localized: .networkingConflictKeep)) {
                Task { await model.keepMine() }
            }
            Button(String(localized: .networkingConflictDiscard), role: .cancel, action: model.discardMine)
        } message: { current in
            Text(.networkingConflictText(current.title))
        }
    }

    private var isConflictPresented: Binding<Bool> {
        Binding(get: { model.conflict != nil }, set: { _ in })
    }
}

private struct CreateNoteCard: View {
    let isSaving: Bool
    var focus: FocusState<NoteField?>.Binding
    let onCreate: (String, String) -> Void
    @State private var title = ""
    @State private var content = ""

    var body: some View {
        VStack(spacing: Spacing.m) {
            FormField(label: Text(.networkingNoteTitle), error: nil) {
                TextField(String(localized: .networkingNoteTitleHint), text: $title)
                    .focused(focus, equals: .newTitle)
            }
            FormField(label: Text(.networkingNoteContent), error: nil) {
                TextField(String(localized: .networkingNoteContentHint), text: $content, axis: .vertical)
                    .focused(focus, equals: .newContent)
            }
            Button(String(localized: .networkingAdd)) {
                onCreate(title, content)
                title = ""
                content = ""
                focus.wrappedValue = nil
            }
            .buttonStyle(.dsPrimary)
            .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

private struct NoteCard: View {
    let note: RemoteNote
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(note.title)
                .font(.dsBodyEmphasis)
                .foregroundStyle(Color.dsTextPrimary)
            Text(note.content)
                .font(.dsBody)
                .foregroundStyle(Color.dsTextPrimary)
            HStack {
                Text(note.updatedAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsTextSecondary)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel(Text(.networkingEdit))
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(Text(.networkingDelete))
            }
            .foregroundStyle(Color.dsAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

private struct EditNoteCard: View {
    let isSaving: Bool
    let onCancel: () -> Void
    let onSave: (String, String) -> Void
    var focus: FocusState<NoteField?>.Binding
    @State private var title: String
    @State private var content: String

    init(
        note: RemoteNote,
        isSaving: Bool,
        focus: FocusState<NoteField?>.Binding,
        onCancel: @escaping () -> Void,
        onSave: @escaping (String, String) -> Void,
    ) {
        self.isSaving = isSaving
        self.focus = focus
        self.onCancel = onCancel
        self.onSave = onSave
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }

    var body: some View {
        VStack(spacing: Spacing.m) {
            FormField(label: Text(.networkingNoteTitle), error: nil) {
                TextField(String(localized: .networkingNoteTitleHint), text: $title)
                    .focused(focus, equals: .editedTitle)
                    .accessibilityIdentifier("networking.edit.title")
            }
            FormField(label: Text(.networkingNoteContent), error: nil) {
                TextField(String(localized: .networkingNoteContentHint), text: $content, axis: .vertical)
                    .focused(focus, equals: .editedContent)
                    .accessibilityIdentifier("networking.edit.content")
            }
            HStack(spacing: Spacing.m) {
                Button(String(localized: .networkingCancel), action: onCancel)
                    .buttonStyle(.dsSecondary)
                Button(String(localized: .networkingSave)) {
                    focus.wrappedValue = nil
                    onSave(title, content)
                }
                .buttonStyle(.dsPrimary)
                .disabled(isSaving || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.dsAccent))
    }
}

#Preview(traits: .modifier(RemoteNotesPreviewModifier())) {
    NavigationStack {
        NetworkingScreenView()
    }
}
