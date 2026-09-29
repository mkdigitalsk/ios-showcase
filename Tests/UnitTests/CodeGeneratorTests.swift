@testable import TemplateIOS
import Testing

struct CodeGeneratorTests {
    private let generator = CodeGenerator()

    @Test
    func `a QR code is square and a barcode is wide`() {
        let qr = generator.image(for: "https://mkdigital.sk", format: .qr)
        let barcode = generator.image(for: "https://mkdigital.sk", format: .barcode)

        #expect(qr != nil)
        #expect(qr?.width == qr?.height)
        #expect(barcode != nil)
        #expect((barcode?.width ?? 0) > (barcode?.height ?? 0))
    }

    @Test
    func `blank text and a non-ASCII barcode render nothing`() {
        #expect(generator.image(for: "   ", format: .qr) == nil)
        #expect(generator.image(for: "čaj", format: .barcode) == nil)
        #expect(generator.image(for: "čaj", format: .qr) != nil)
    }
}
