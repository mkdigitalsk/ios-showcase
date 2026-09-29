import CoreImage
import CoreImage.CIFilterBuiltins

enum CodeFormat: CaseIterable, Equatable, Sendable {
    case qr
    case barcode
}

/// Renders text as a QR code or a Code 128 barcode through Core Image, scaled so the modules stay crisp.
struct CodeGenerator: Sendable {
    private static let scale: CGFloat = 10
    /// Documented thread-safe; only the type lacks the annotation.
    private nonisolated(unsafe) let context = CIContext()

    func image(for text: String, format: CodeFormat) -> CGImage? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let output = Self.filterOutput(trimmed, format: format) else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: Self.scale, y: Self.scale))
        return context.createCGImage(scaled, from: scaled.extent)
    }

    private static func filterOutput(_ text: String, format: CodeFormat) -> CIImage? {
        switch format {
        case .qr:
            let filter = CIFilter.qrCodeGenerator()
            filter.message = Data(text.utf8)
            filter.correctionLevel = "M"
            return filter.outputImage
        case .barcode:
            guard let message = text.data(using: .ascii) else { return nil }
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = message
            filter.quietSpace = 7
            return filter.outputImage
        }
    }
}
