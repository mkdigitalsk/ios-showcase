import CoreGraphics
import Observation

@MainActor
@Observable
final class ScannerViewModel {
    enum Mode: CaseIterable, Equatable {
        case generate
        case scan
    }

    var mode = Mode.generate
    var format = CodeFormat.qr
    var text: String
    private(set) var generated: CGImage?
    private(set) var scanned: String?
    private let generator = CodeGenerator()

    init(text: String = "") {
        self.text = text
    }

    func generate() {
        generated = generator.image(for: text, format: format)
    }

    func inputChanged() {
        generated = nil
    }

    func modeChanged() {
        scanned = nil
    }

    func codeScanned(_ payload: String) {
        scanned = payload
    }

    func scanAgain() {
        scanned = nil
    }
}
