import Foundation
import Security

/// One generic-password item in the app's keychain, read and written as raw data.
struct KeychainStore: Sendable {
    enum Failure: Error, Equatable {
        case invalidData
        case unexpectedStatus(OSStatus)
    }

    private let service: String
    private let account: String

    init(account: String, service: String = Bundle.main.bundleIdentifier ?? "sk.mkdigital.templateios") {
        self.service = service
        self.account = account
    }

    func load() throws -> Data? {
        var query = baseQuery()
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw Failure.invalidData }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw Failure.unexpectedStatus(status)
        }
    }

    func save(_ data: Data) throws {
        try remove()
        var query = baseQuery()
        query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        query[kSecValueData] = data
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw Failure.unexpectedStatus(status) }
    }

    func remove() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw Failure.unexpectedStatus(status) }
    }

    private func baseQuery() -> [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
    }
}
