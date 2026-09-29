import SwiftUI

extension View {
    /// A Done button above the keyboard. A multi-line field turns Return into a newline and SwiftUI does
    /// not dismiss on an outside tap, so without it the keyboard stays until the person scrolls.
    func keyboardDoneButton(_ dismiss: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: .keyboardDone), action: dismiss)
            }
        }
    }
}
