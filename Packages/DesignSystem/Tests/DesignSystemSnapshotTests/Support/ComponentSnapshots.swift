import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIKit

/// `make record-snapshots` sets `SNAPSHOT_RECORD` in the test runner's environment. A compile
/// condition would need `SWIFT_ACTIVE_COMPILATION_CONDITIONS` on the command line, and that
/// overrides every package's own conditions and breaks their build.
enum SnapshotRecordMode {
    static var record: SnapshotTestingConfiguration.Record {
        ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1" ? .all : .missing
    }
}

/// A component at a fixed width, as tall as it needs, in light and dark — on the simulator through the
/// hosting view, the same path the screens take, at the standard type size.
@MainActor
func assertComponentSnapshots(
    of view: @autoclosure () -> some View,
    width: CGFloat = 320,
    fileID: StaticString = #fileID,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    for scheme in [ColorScheme.light, .dark] {
        assertSnapshot(
            of: view()
                .frame(width: width)
                .environment(\.colorScheme, scheme)
                .environment(\.dynamicTypeSize, .large),
            as: .image(
                layout: .sizeThatFits,
                traits: UITraitCollection(userInterfaceStyle: scheme == .dark ? .dark : .light),
            ),
            named: scheme == .dark ? "dark" : "light",
            fileID: fileID,
            file: file,
            testName: testName,
            line: line,
            column: column,
        )
    }
}
