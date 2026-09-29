import SwiftUI

@main
struct TemplateApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            AppContainer(pushClient: appDelegate.pushClient)
        }
    }
}

/// Builds the composition root once and hands every app-wide model to the tree.
private struct AppContainer: View {
    @State private var dependencies: AppDependencies

    init(pushClient: any PushClient) {
        _dependencies = State(initialValue: AppDependencies.makeLive(pushClient: pushClient))
    }

    var body: some View {
        #if DEBUG
        if CommandLine.arguments.contains(UIReviewGallery.launchArgument) {
            UIReviewGallery()
        } else {
            appRoot
        }
        #else
        appRoot
        #endif
    }

    private var appRoot: some View {
        AppRootView(makeAuthenticated: dependencies.makeAuthenticated)
            .environment(dependencies.sessionModel)
            .environment(dependencies.deepLinkModel)
            .environment(dependencies.settingsModel)
            .environment(dependencies.storageModel)
            .environment(dependencies.notesModel)
            .environment(dependencies.apisModel)
            .environment(dependencies.notificationsModel)
            .preferredColorScheme(dependencies.settingsModel.appearance.colorScheme)
            .task {
                await dependencies.settingsModel.load()
            }
            .onOpenURL { url in
                dependencies.deepLinkModel.handle(url)
            }
    }
}
