import DesignSystem
import SwiftUI

struct HomeScreenView: View {
    let features: [HomeFeature]
    let onSelect: (HomeFeature) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: Spacing.m)], spacing: Spacing.m) {
                ForEach(features) { feature in
                    FeatureTile(feature: feature) {
                        onSelect(feature)
                    }
                }
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.homeTitle))
    }
}

private struct FeatureTile: View {
    let feature: HomeFeature
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Image(systemName: feature.systemImage)
                    .font(.dsTitle)
                    .foregroundStyle(Color.dsAccent)
                Text(feature.title)
                    .font(.dsBodyEmphasis)
                    .foregroundStyle(Color.dsTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.m)
            .background(Color.dsSurface, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeScreenView(features: HomeFeature.allCases) { _ in }
    }
}
