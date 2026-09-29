import Foundation
@testable import TemplateIOS
import Testing

struct DeepLinkParserTests {
    private let parser = DeepLinkParser(scheme: "templateios")

    @Test(arguments: [
        ("templateios://", DeepLinkDestination.home),
        ("templateios://home", .home),
        ("templateios://settings", .settings),
        ("templateios://sign-up", .signUp),
        ("templateios://ui-components", .uiComponents),
        ("templateios://uicomponents", .uiComponents),
        ("TEMPLATEIOS://Database", .database),
        ("templateios:///notifications", .notifications),
    ])
    func `a known destination parses`(link: String, destination: DeepLinkDestination) throws {
        #expect(try parser.parse(#require(URL(string: link))) == destination)
    }

    @Test(arguments: ["https://mkdigital.sk/settings", "other://settings", "templateios://nowhere"])
    func `another scheme or an unknown destination is nothing`(link: String) throws {
        #expect(try parser.parse(#require(URL(string: link))) == nil)
    }

    @Test
    @MainActor
    func `the model keeps one pending link until its flow consumes it`() throws {
        let model = DeepLinkModel(parser: parser)

        #expect(try model.handle(#require(URL(string: "templateios://settings"))))
        #expect(model.pending == .settings)

        model.consume(.home)
        #expect(model.pending == .settings)

        model.consume(.settings)
        #expect(model.pending == nil)
    }
}
