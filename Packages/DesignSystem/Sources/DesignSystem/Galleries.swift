import SwiftUI

/// Every button style in every state — the preview and the snapshot test render this one view.
public struct ButtonsGallery: View {
    public init() {}

    public var body: some View {
        VStack(spacing: Spacing.m) {
            Button("Primary") {}
                .buttonStyle(.dsPrimary)
            Button("Primary disabled") {}
                .buttonStyle(.dsPrimary)
                .disabled(true)
            Button("Secondary") {}
                .buttonStyle(.dsSecondary)
            Button("Secondary disabled") {}
                .buttonStyle(.dsSecondary)
                .disabled(true)
        }
        .padding(Spacing.m)
        .background(Color.dsBackground)
    }
}

/// Every color token beside its name.
public struct ColorsGallery: View {
    private static let tokens: [(name: String, color: Color)] = [
        ("background", .dsBackground),
        ("surface", .dsSurface),
        ("textPrimary", .dsTextPrimary),
        ("textSecondary", .dsTextSecondary),
        ("accent", .dsAccent),
        ("onAccent", .dsOnAccent),
        ("outline", .dsOutline),
        ("error", .dsError),
    ]

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            ForEach(Self.tokens, id: \.name) { token in
                HStack(spacing: Spacing.m) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(token.color)
                        .frame(width: 44, height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.dsOutline))
                    Text(token.name)
                        .font(.dsBody)
                        .foregroundStyle(Color.dsTextPrimary)
                }
            }
        }
        .padding(Spacing.m)
        .background(Color.dsBackground)
    }
}

/// Every font token set in itself.
public struct FontsGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Title").font(.dsTitle)
            Text("Body").font(.dsBody)
            Text("Body emphasis").font(.dsBodyEmphasis)
            Text("Caption").font(.dsCaption)
        }
        .foregroundStyle(Color.dsTextPrimary)
        .padding(Spacing.m)
        .background(Color.dsBackground)
    }
}

/// A field at rest and a field in error — the two states the border draws.
public struct FieldsGallery: View {
    public init() {}

    public var body: some View {
        VStack(spacing: Spacing.m) {
            FormField(label: Text("Label"), error: nil) {
                Text("Value")
            }
            FormField(label: Text("Label"), error: Text("Something is wrong with this value")) {
                Text("Value")
            }
        }
        .padding(Spacing.m)
        .background(Color.dsBackground)
    }
}

#Preview("Buttons") {
    ButtonsGallery()
}

#Preview("Colors") {
    ColorsGallery()
}

#Preview("Fonts") {
    FontsGallery()
}

#Preview("Fields") {
    FieldsGallery()
}
