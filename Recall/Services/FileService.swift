import Foundation
import UIKit

class FileService {
    static func uploadJPEGImageData(data: Data, onCompletion: @escaping (CardAttachment) -> Void) {
        let image = UIImage(data: data)!
        let width = image.size.width
        let height = image.size.height
        let aspectRatio = Float(width) / Float(height)
        FirebaseFileStore.uploadJPEGImageData(data: data) { url in
            let attachment = CardAttachment(
                type: "image/jpeg",
                src: url.absoluteString,
                aspectRatio: aspectRatio
            )
            onCompletion(attachment)
        }
    }
}
