import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct HomeScreenViewSnapshotTests {
    @Test
    func `every feature`() {
        assertScreenSnapshots(
            of: NavigationStack {
                HomeScreenView(features: HomeFeature.allCases) { _ in }
            },
        )
    }
}
