import SwiftUI

struct HomeFlowView: View {
    @Environment(DeepLinkModel.self) private var deepLinkModel
    @State private var path: [HomeFeature] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreenView(features: HomeFeature.allCases) { feature in
                path.append(feature)
            }
            .navigationDestination(for: HomeFeature.self) { feature in
                switch feature {
                case .uiComponents: UiComponentsScreenView()
                case .networking: NetworkingScreenView()
                case .storage: StorageScreenView()
                case .apis: ApisScreenView()
                case .scanner: ScannerScreenView()
                case .database: DatabaseScreenView()
                case .calendar: CalendarScreenView()
                case .notifications: NotificationsScreenView()
                }
            }
        }
        .onChange(of: deepLinkModel.pending, initial: true) { _, pending in
            guard let pending else { return }
            if pending == .home {
                path = []
                deepLinkModel.consume(.home)
            } else if let feature = HomeFeature(deepLink: pending) {
                path = [feature]
                deepLinkModel.consume(pending)
            }
        }
    }
}

#Preview(traits: .modifier(SessionPreviewModifier()), .modifier(StoragePreviewModifier()), .modifier(NotesPreviewModifier()), .modifier(RemoteNotesPreviewModifier()), .modifier(ApisPreviewModifier()), .modifier(NotificationsPreviewModifier())) {
    HomeFlowView()
}
