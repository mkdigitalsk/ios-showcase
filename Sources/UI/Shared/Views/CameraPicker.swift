import SwiftUI
import UIKit

/// The system camera; the photo comes back as JPEG data, or nothing when the sheet is cancelled.
struct CameraPicker: UIViewControllerRepresentable {
    let onPhoto: (Data?) -> Void

    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPhoto: onPhoto)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onPhoto: (Data?) -> Void

        init(onPhoto: @escaping (Data?) -> Void) {
            self.onPhoto = onPhoto
        }

        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            onPhoto((info[.originalImage] as? UIImage)?.profilePhotoData)
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            onPhoto(nil)
        }
    }
}

extension UIImage {
    private static let profilePhotoSide: CGFloat = 512

    /// A square-ish thumbnail as JPEG — what the settings store keeps, whatever the source size.
    var profilePhotoData: Data? {
        let scale = Self.profilePhotoSide / max(size.width, size.height, 1)
        let target = CGSize(width: size.width * min(scale, 1), height: size.height * min(scale, 1))
        return preparingThumbnail(of: target)?.jpegData(compressionQuality: 0.85) ?? jpegData(compressionQuality: 0.85)
    }
}
