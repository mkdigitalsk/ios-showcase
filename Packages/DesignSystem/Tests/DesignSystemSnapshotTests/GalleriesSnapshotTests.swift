import DesignSystem
import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: SnapshotRecordMode.record))
struct GalleriesSnapshotTests {
    @Test
    func buttons() {
        assertComponentSnapshots(of: ButtonsGallery())
    }

    @Test
    func colors() {
        assertComponentSnapshots(of: ColorsGallery())
    }

    @Test
    func fonts() {
        assertComponentSnapshots(of: FontsGallery())
    }

    @Test
    func fields() {
        assertComponentSnapshots(of: FieldsGallery())
    }
}
