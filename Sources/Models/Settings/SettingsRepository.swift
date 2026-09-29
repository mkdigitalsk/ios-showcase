import Foundation

protocol SettingsRepository: Sendable {
    func loadAppearance() async -> AppearanceMode
    func saveAppearance(_ mode: AppearanceMode) async
    func loadProfilePhoto() async throws -> Data?
    /// `nil` removes the photo.
    func saveProfilePhoto(_ data: Data?) async throws
}
