import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct ApisScreenViewSnapshotTests {
    @Test
    func idle() {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient())
        model.load()

        assertScreenSnapshots(of: screen(model))
    }

    @Test
    func answered() async {
        let model = ApisModel(locationClient: StubLocationClient(), biometricClient: StubBiometricClient(outcome: .failed("Not recognised")))
        model.load()
        await model.locate()
        await model.authenticate(reason: "test")
        model.markCopied()

        assertScreenSnapshots(of: screen(model), variants: [.light])
    }

    private func screen(_ model: ApisModel) -> some View {
        NavigationStack {
            ApisScreenView()
        }
        .environment(model)
    }
}
