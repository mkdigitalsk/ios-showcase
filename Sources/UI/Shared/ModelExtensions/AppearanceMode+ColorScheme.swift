import SwiftUI

extension AppearanceMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var text: LocalizedStringResource {
        switch self {
        case .system: .settingsThemeSystem
        case .light: .settingsThemeLight
        case .dark: .settingsThemeDark
        }
    }
}
