#if DEBUG
import SwiftUI

struct PreviewSession {
    let sessionModel: SessionModel
    let deepLinkModel: DeepLinkModel
}

/// A restored, signed-in session for every preview past the auth gate.
struct SessionPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> PreviewSession {
        let sessionModel = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore(token: Session.stub.token))
        await sessionModel.restore()
        return PreviewSession(sessionModel: sessionModel, deepLinkModel: DeepLinkModel(parser: DeepLinkParser(scheme: "preview")))
    }

    func body(content: Content, context: PreviewSession) -> some View {
        content
            .environment(context.sessionModel)
            .environment(context.deepLinkModel)
    }
}

/// No stored token — the auth flow as a first launch shows it.
struct SignedOutPreviewModifier: PreviewModifier {
    static func makeSharedContext() async throws -> PreviewSession {
        let sessionModel = SessionModel(repository: StubAuthRepository(), tokenStore: StubTokenStore())
        await sessionModel.restore()
        return PreviewSession(sessionModel: sessionModel, deepLinkModel: DeepLinkModel(parser: DeepLinkParser(scheme: "preview")))
    }

    func body(content: Content, context: PreviewSession) -> some View {
        content
            .environment(context.sessionModel)
            .environment(context.deepLinkModel)
    }
}
#endif
