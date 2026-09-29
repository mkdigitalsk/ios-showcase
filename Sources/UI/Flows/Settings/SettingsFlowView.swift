import SwiftUI

struct SettingsFlowView: View {
    var body: some View {
        NavigationStack {
            SettingsScreenView(
                version: AppConfiguration.version,
                build: AppConfiguration.build,
                buildType: AppConfiguration.buildType,
                apiHost: AppConfiguration.apiBaseURL.host() ?? "",
            )
        }
    }
}
