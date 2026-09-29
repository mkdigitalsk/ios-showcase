import DesignSystem
import SwiftUI

struct UiComponentsScreenView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                GallerySection(title: .uiComponentsButtons) { ButtonsGallery() }
                GallerySection(title: .uiComponentsColors) { ColorsGallery() }
                GallerySection(title: .uiComponentsFonts) { FontsGallery() }
                GallerySection(title: .uiComponentsFields) { FieldsGallery() }
            }
            .screenPadding()
        }
        .background(Color.dsBackground)
        .navigationTitle(Text(.uiComponentsTitle))
    }
}

private struct GallerySection<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(title)
                .font(.dsTitle)
                .foregroundStyle(Color.dsTextPrimary)
            content
        }
    }
}

#Preview {
    NavigationStack {
        UiComponentsScreenView()
    }
}
