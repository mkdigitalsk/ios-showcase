import SnapshotTesting
import SwiftUI
@testable import TemplateIOS
import Testing

@MainActor
@Suite(.serialized, .snapshots(record: SnapshotRecordMode.record))
struct ScannerScreenViewSnapshotTests {
    @Test
    func generated() {
        let viewModel = ScannerViewModel(text: "https://mkdigital.sk")
        viewModel.generate()

        assertScreenSnapshots(of: screen(viewModel))
    }

    @Test
    func barcode() {
        let viewModel = ScannerViewModel(text: "MKD-62")
        viewModel.format = .barcode
        viewModel.generate()

        assertScreenSnapshots(of: screen(viewModel), variants: [.light])
    }

    /// The simulator has no camera, so the scan pane renders its unsupported state.
    @Test
    func `scan unsupported`() {
        let viewModel = ScannerViewModel()
        viewModel.mode = .scan

        assertScreenSnapshots(of: screen(viewModel), variants: [.light])
    }

    private func screen(_ viewModel: ScannerViewModel) -> some View {
        NavigationStack {
            ScannerScreenView(viewModel: viewModel)
        }
    }
}
