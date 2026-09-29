import SwiftUI

/// A labelled field on a surface; an error turns the border and adds the message under it.
public struct FormField<Field: View>: View {
    private let label: Text
    private let error: Text?
    private let field: Field

    public init(label: Text, error: Text?, @ViewBuilder field: () -> Field) {
        self.label = label
        self.error = error
        self.field = field()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            label
                .font(.dsCaption)
                .foregroundStyle(Color.dsTextSecondary)
            field
                .font(.dsBody)
                .foregroundStyle(Color.dsTextPrimary)
                .padding(Spacing.m - Spacing.xs)
                .background(Color.dsSurface, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(error == nil ? Color.dsOutline : Color.dsError),
                )
            if let error {
                error
                    .font(.dsCaption)
                    .foregroundStyle(Color.dsError)
            }
        }
    }
}
