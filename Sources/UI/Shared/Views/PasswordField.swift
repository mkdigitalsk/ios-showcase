import DesignSystem
import SwiftUI
import UIKit

/// A secure field with a reveal toggle; the toggle keeps the keyboard and the focus where they were.
struct PasswordField: View {
    let placeholder: LocalizedStringResource
    @Binding var text: String
    /// `.password` fills a saved one; `.newPassword` on sign-up lets the system suggest and save a new one.
    var contentType = UITextContentType.password
    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: Spacing.s) {
            Group {
                if isRevealed {
                    TextField(String(localized: placeholder), text: $text)
                } else {
                    SecureField(String(localized: placeholder), text: $text)
                }
            }
            .textContentType(contentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(Color.dsTextSecondary)
            }
            .accessibilityLabel(Text(isRevealed ? .passwordHide : .passwordShow))
        }
    }
}

#Preview {
    @Previewable @State var text = "secret"
    FormField(label: Text("Password"), error: nil) {
        PasswordField(placeholder: "Enter your password", text: $text)
    }
    .padding()
}
