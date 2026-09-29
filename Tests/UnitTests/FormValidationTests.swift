@testable import TemplateIOS
import Testing

struct FormValidationTests {
    @Test(arguments: ["a@b.co", "first.last+tag@sub.example.org"])
    func `an address with a domain and a TLD is valid`(email: String) {
        #expect(FormValidation.isValidEmail(email))
    }

    @Test(arguments: ["", "a@b", "a b@c.d", "@example.com"])
    func `anything else is not`(email: String) {
        #expect(!FormValidation.isValidEmail(email))
    }

    @Test
    func `a strong password has every class and is long enough`() {
        #expect(FormValidation.isStrongPassword("MKDigitalTest1@"))
        #expect(!FormValidation.isStrongPassword("alllowercase1@"))
        #expect(!FormValidation.isStrongPassword("NoDigits@@"))
        #expect(!FormValidation.isStrongPassword("Short1@"))
        #expect(!FormValidation.isPasswordLongEnough("Short1@"))
    }
}
