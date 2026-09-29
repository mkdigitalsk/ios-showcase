import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dsBodyEmphasis)
            .foregroundStyle(Color.dsOnAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.m - Spacing.xs / 2)
            .background(
                Color.dsAccent.opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4),
                in: .rect(cornerRadius: 12),
            )
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dsBodyEmphasis)
            .foregroundStyle(Color.dsAccent.opacity(isEnabled ? 1 : 0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.m - Spacing.xs / 2)
            .background(
                Color.dsSurface.opacity(configuration.isPressed ? 1 : 0),
                in: .rect(cornerRadius: 12),
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.dsOutline),
            )
    }
}

public extension ButtonStyle where Self == PrimaryButtonStyle {
    static var dsPrimary: PrimaryButtonStyle {
        PrimaryButtonStyle()
    }
}

public extension ButtonStyle where Self == SecondaryButtonStyle {
    static var dsSecondary: SecondaryButtonStyle {
        SecondaryButtonStyle()
    }
}
