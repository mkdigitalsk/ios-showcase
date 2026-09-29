import SwiftUI

enum MainTab: Hashable {
    case home
    case settings
}

/// The signed-in shell. A pending deep link picks the tab; the flow inside it consumes the link.
struct MainTabView: View {
    @Environment(DeepLinkModel.self) private var deepLinkModel
    @State private var selectedTab = MainTab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: .homeTab), systemImage: "house", value: .home) {
                HomeFlowView()
            }
            Tab(String(localized: .settingsTab), systemImage: "gearshape", value: .settings) {
                SettingsFlowView()
            }
        }
        .onChange(of: deepLinkModel.pending, initial: true) { _, pending in
            guard let pending else { return }
            switch pending {
            case .settings:
                selectedTab = .settings
                deepLinkModel.consume(.settings)
            case .signIn, .signUp:
                deepLinkModel.consume(pending)
            default:
                selectedTab = .home
            }
        }
    }
}

#Preview(traits: .modifier(SessionPreviewModifier()), .modifier(StoragePreviewModifier()), .modifier(NotesPreviewModifier()), .modifier(RemoteNotesPreviewModifier()), .modifier(SettingsPreviewModifier()), .modifier(AccountPreviewModifier()), .modifier(ApisPreviewModifier()), .modifier(NotificationsPreviewModifier())) {
    MainTabView()
}
