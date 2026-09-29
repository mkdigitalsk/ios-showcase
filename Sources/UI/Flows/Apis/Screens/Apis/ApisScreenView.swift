import DesignSystem
import SwiftUI
import UIKit

struct ApisScreenView: View {
    @Environment(ApisModel.self) private var model
    @Environment(\.openURL) private var openURL

    private static let demoURL = URL(string: "https://mkdigital.sk")!
    private static let demoPhone = URL(string: "tel:+1234567890")!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text(.apisSubtitle)
                    .font(.dsBody)
                    .foregroundStyle(Color.dsTextSecondary)
                ApiCard(title: .apisShareTitle) {
                    ShareLink(item: Self.shareText) {
                        Text(.apisShareAction)
                    }
                    .buttonStyle(.dsSecondary)
                }
                ApiCard(title: .apisDialTitle) {
                    Button(String(localized: .apisDialAction)) {
                        open(Self.demoPhone, in: .dialer)
                    }
                    .buttonStyle(.dsSecondary)
                    ExternalAppUnavailable(app: .dialer, unavailable: model.unavailableApps)
                }
                ApiCard(title: .apisLinkTitle) {
                    Link(String(localized: .apisLinkAction), destination: Self.demoURL)
                        .buttonStyle(.dsSecondary)
                }
                ApiCard(title: .apisEmailTitle) {
                    Button(String(localized: .apisEmailAction)) {
                        open(Self.mailURL, in: .mail)
                    }
                    .buttonStyle(.dsSecondary)
                    ExternalAppUnavailable(app: .mail, unavailable: model.unavailableApps)
                }
                ApiCard(title: .apisCopyTitle) {
                    Button(String(localized: .apisCopyAction)) {
                        UIPasteboard.general.string = String(localized: .apisCopyText)
                        model.markCopied()
                    }
                    .buttonStyle(.dsSecondary)
                    if model.copied {
                        Text(.apisCopied)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    }
                }
                ApiCard(title: .apisLocationTitle) {
                    Button(String(localized: .apisLocationAction)) {
                        Task { await model.locate() }
                    }
                    .buttonStyle(.dsSecondary)
                    .disabled(model.isLocating)
                    if model.isLocating {
                        Text(.apisLocationLoading)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    } else if let location = model.location {
                        Text(.apisLocationResult(location.latitude.coordinateText, location.longitude.coordinateText))
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    } else if model.locationFailed {
                        Text(.apisLocationError)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsError)
                    }
                }
                ApiCard(title: .apisLocationUpdatesTitle) {
                    Button(String(localized: model.isTracking ? .apisLocationUpdatesStop : .apisLocationUpdatesStart)) {
                        if model.isTracking {
                            model.stopTracking()
                        } else {
                            model.startTracking()
                        }
                    }
                    .buttonStyle(.dsSecondary)
                    if let tracked = model.trackedLocation {
                        Text(.apisLocationResult(tracked.latitude.coordinateText, tracked.longitude.coordinateText))
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    } else if model.trackingFailed {
                        Text(.apisLocationUpdatesError)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsError)
                    }
                }
                ApiCard(title: .apisBiometricsTitle) {
                    if let kind = model.biometricKind.text {
                        Button(String(localized: .apisBiometricsAction)) {
                            Task { await model.authenticate(reason: String(localized: .apisBiometricsReason)) }
                        }
                        .buttonStyle(.dsSecondary)
                        .disabled(model.isAuthenticating)
                        Text(kind)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    } else {
                        Text(.apisBiometricsNotAvailable)
                            .font(.dsCaption)
                            .foregroundStyle(Color.dsTextSecondary)
                    }
                    if let outcome = model.biometricOutcome {
                        Text(outcome.text)
                            .font(.dsCaption)
                            .foregroundStyle(outcome == .success ? Color.dsTextSecondary : Color.dsError)
                    }
                }
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.apisTitle))
        .onAppear(perform: model.load)
        .onDisappear(perform: model.stopTracking)
    }

    /// The sentence and the link as one text — what the share sheet previews and what Copy puts on the clipboard.
    private static var shareText: String {
        "\(String(localized: .apisShareText))\n\(demoURL.absoluteString)"
    }

    /// A URL no installed app claims is refused without a sound — the simulator has no Phone and no Mail.
    private func open(_ url: URL, in app: ExternalApp) {
        openURL(url) { accepted in
            model.externalAppOpened(app, accepted: accepted)
        }
    }

    private static var mailURL: URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "example@example.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: String(localized: .apisEmailSubject)),
            URLQueryItem(name: "body", value: String(localized: .apisEmailBody)),
        ]
        return components.url ?? URL(string: "mailto:example@example.com")!
    }
}

private struct ExternalAppUnavailable: View {
    let app: ExternalApp
    let unavailable: Set<ExternalApp>

    var body: some View {
        if unavailable.contains(app) {
            Text(.apisAppUnavailable)
                .font(.dsCaption)
                .foregroundStyle(Color.dsError)
        }
    }
}

private struct ApiCard<Content: View>: View {
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

private extension Double {
    var coordinateText: String {
        formatted(.number.precision(.fractionLength(6)))
    }
}

#Preview(traits: .modifier(ApisPreviewModifier())) {
    NavigationStack {
        ApisScreenView()
    }
}
