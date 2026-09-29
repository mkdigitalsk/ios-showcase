import SwiftUI

enum AuthRoute: Hashable {
    case signUp
}

/// Sign-in at the root, sign-up pushed; any other deep link waits here until a session opens.
struct AuthFlowView: View {
    @Environment(DeepLinkModel.self) private var deepLinkModel
    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            SignInScreenView {
                path.append(.signUp)
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:
                    SignUpScreenView {
                        path.removeLast()
                    }
                }
            }
        }
        .onChange(of: deepLinkModel.pending, initial: true) { _, pending in
            switch pending {
            case .signUp:
                path = [.signUp]
                deepLinkModel.consume(.signUp)
            case .signIn:
                path = []
                deepLinkModel.consume(.signIn)
            default:
                break
            }
        }
    }
}

#Preview(traits: .modifier(SignedOutPreviewModifier())) {
    AuthFlowView()
}
