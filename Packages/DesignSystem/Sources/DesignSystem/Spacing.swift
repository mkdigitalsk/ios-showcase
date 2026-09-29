import SwiftUI

public enum Spacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public extension View {
    /// The one padding a `*ScreenView`'s root container takes — horizontal `m`, top `l`, bottom `xl`.
    /// A container that bleeds on one axis composes `padding(.top, Spacing.l)` and the rest itself.
    func screenPadding() -> some View {
        padding(.horizontal, Spacing.m)
            .padding(.top, Spacing.l)
            .padding(.bottom, Spacing.xl)
    }
}
