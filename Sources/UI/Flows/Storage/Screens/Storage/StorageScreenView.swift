import DesignSystem
import SwiftUI

struct StorageScreenView: View {
    @Environment(StorageModel.self) private var model
    @State private var lastChangeFailed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                CounterSection(
                    title: .storageSessionTitle,
                    detail: .storageSessionDetail,
                    count: model.sessionCount,
                    increment: model.incrementSession,
                )
                CounterSection(
                    title: .storagePersistentTitle,
                    detail: .storagePersistentDetail,
                    count: model.persistentCount,
                ) {
                    perform(model.incrementPersistent)
                }
                if lastChangeFailed {
                    Text(.storageFailed)
                        .font(.dsCaption)
                        .foregroundStyle(Color.dsTextSecondary)
                }
                Button(String(localized: .storageReset)) {
                    perform(model.reset)
                }
                .buttonStyle(.dsSecondary)
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.storageTitle))
        .task {
            do {
                try await model.load()
            } catch {
                lastChangeFailed = true
            }
        }
    }

    private func perform(_ change: @escaping @MainActor () async throws -> Void) {
        Task {
            do {
                try await change()
                lastChangeFailed = false
            } catch {
                lastChangeFailed = true
            }
        }
    }
}

private struct CounterSection: View {
    let title: LocalizedStringResource
    let detail: LocalizedStringResource
    let count: Int
    let increment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.dsTitle)
                .foregroundStyle(Color.dsTextPrimary)
            Text(detail)
                .font(.dsCaption)
                .foregroundStyle(Color.dsTextSecondary)
            HStack {
                Text(count, format: .number)
                    .font(.dsTitle)
                    .foregroundStyle(Color.dsTextPrimary)
                    .contentTransition(.numericText())
                Spacer()
                Button(String(localized: .storageIncrement), action: increment)
                    .buttonStyle(.dsPrimary)
                    .frame(maxWidth: 160)
            }
        }
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

#Preview(traits: .modifier(StoragePreviewModifier())) {
    NavigationStack {
        StorageScreenView()
    }
}
