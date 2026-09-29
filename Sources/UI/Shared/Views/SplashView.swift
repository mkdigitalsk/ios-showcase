import DesignSystem
import SwiftUI

struct SplashView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.dsBackground)
    }
}

#Preview {
    SplashView()
}
