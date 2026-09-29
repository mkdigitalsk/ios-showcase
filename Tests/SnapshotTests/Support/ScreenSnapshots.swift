import Foundation
import SnapshotTesting
import SwiftUI
import UIKit

/// `make record-snapshots` sets `SNAPSHOT_RECORD` in the test runner's environment. A compile
/// condition would need `SWIFT_ACTIVE_COMPILATION_CONDITIONS` on the command line, and that
/// overrides every package's own conditions and breaks their build.
enum SnapshotRecordMode {
    static var record: SnapshotTestingConfiguration.Record {
        ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1" ? .all : .missing
    }
}

struct SnapshotVariant: Sendable {
    let name: String
    let colorScheme: ColorScheme
    let dynamicTypeSize: DynamicTypeSize

    static let light = SnapshotVariant(name: "light", colorScheme: .light, dynamicTypeSize: .large)
    static let dark = SnapshotVariant(name: "dark", colorScheme: .dark, dynamicTypeSize: .large)
    static let accessibility = SnapshotVariant(name: "accessibility", colorScheme: .light, dynamicTypeSize: .accessibility3)

    /// Every screen records these; a variant is dropped per test only where it proves nothing.
    static let standard: [SnapshotVariant] = [.light, .dark, .accessibility]
}

/// A screen at iPhone size in every variant, the locale and time zone pinned so copy, numbers and
/// dates stay stable.
@MainActor
func assertScreenSnapshots(
    of view: @autoclosure () -> some View,
    variants: [SnapshotVariant] = SnapshotVariant.standard,
    fileID: StaticString = #fileID,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    for variant in variants {
        assertSnapshot(
            of: view()
                .environment(\.colorScheme, variant.colorScheme)
                .environment(\.dynamicTypeSize, variant.dynamicTypeSize)
                .environment(\.locale, Locale(identifier: "en_GB"))
                .environment(\.timeZone, TimeZone(identifier: "Europe/Bratislava")!),
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: UITraitCollection(userInterfaceStyle: variant.colorScheme == .dark ? .dark : .light),
            ),
            named: variant.name,
            fileID: fileID,
            file: file,
            testName: testName,
            line: line,
            column: column,
        )
    }
}
