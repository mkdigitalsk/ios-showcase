import DesignSystem
import SwiftUI
import UIKit

struct NotificationsScreenView: View {
    @Environment(NotificationsModel.self) private var model
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(.notificationsSubtitle)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                Card(title: .notificationsPermissionTitle) {
                    Text(permissionText)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextPrimary)
                    switch model.permission {
                    case .notDetermined:
                        Button(String(localized: .notificationsRequestPermission)) {
                            Task { await model.requestPermission() }
                        }
                        .buttonStyle(.dsSecondary)
                    case .denied:
                        Button(String(localized: .notificationsOpenSettings), action: openSettings)
                            .buttonStyle(.dsSecondary)
                    case .granted:
                        EmptyView()
                    }
                }
                Card(title: .notificationsTokenTitle) {
                    Text(model.pushToken ?? String(localized: .notificationsNoToken))
                        .font(.dsCaption.monospaced())
                        .foregroundStyle(model.pushToken == nil ? Color.dsTextSecondary : Color.dsTextPrimary)
                        .textSelection(.enabled)
                    HStack(spacing: Spacing.m) {
                        Button(String(localized: .notificationsRefreshToken)) {
                            Task { await model.refreshToken() }
                        }
                        .buttonStyle(.dsSecondary)
                        .disabled(model.isRefreshingToken)
                        Button(String(localized: .notificationsLogToken), action: model.logToken)
                            .buttonStyle(.dsSecondary)
                    }
                }
                Card(title: .notificationsSendTitle) {
                    HStack(spacing: Spacing.m) {
                        Button(String(localized: .notificationsSendReminder)) {
                            Task { await model.send(title: String(localized: .notificationsReminderTitle), body: String(localized: .notificationsReminderMessage), category: .reminders) }
                        }
                        .buttonStyle(.dsSecondary)
                        Button(String(localized: .notificationsSendPromo)) {
                            Task { await model.send(title: String(localized: .notificationsPromoTitle), body: String(localized: .notificationsPromoMessage), category: .promotions) }
                        }
                        .buttonStyle(.dsSecondary)
                    }
                    if let lastSent = model.lastSent {
                        Text(.notificationsLastSent(lastSent))
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    }
                    if model.sendFailed {
                        Text(.notificationsSendFailed)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsError)
                    }
                }
                Card(title: .notificationsManageTitle) {
                    HStack(spacing: Spacing.m) {
                        Button(String(localized: .notificationsCancelAll)) {
                            Task { await model.cancelAll() }
                        }
                        .buttonStyle(.dsSecondary)
                        Button(String(localized: .notificationsOpenSettings), action: openSettings)
                            .buttonStyle(.dsSecondary)
                    }
                    if let received = model.lastReceived {
                        Text(.notificationsLastReceived("\(received.title): \(received.body)"))
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    }
                }
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.notificationsTitle))
        .task {
            await model.load()
        }
    }

    private var permissionText: LocalizedStringResource {
        switch model.permission {
        case .notDetermined: .notificationsPermissionUnknown
        case .granted: .notificationsPermissionGranted
        case .denied: .notificationsPermissionDenied
        }
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

private struct Card<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(title)
                .font(.dsBodyEmphasis)
                .foregroundStyle(Color.dsTextPrimary)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.m)
        .background(Color.dsSurface, in: .rect(cornerRadius: 12))
    }
}

#Preview(traits: .modifier(NotificationsPreviewModifier())) {
    NavigationStack {
        NotificationsScreenView()
    }
}
