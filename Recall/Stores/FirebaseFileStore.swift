import Foundation
import FirebaseStorage

class FirebaseFileStore {

    static func uploadJPEGImageData(data: Data, onCompletion: @escaping (URL) -> Void) {
        let storageRef = Storage.storage().reference()
        let filename = UUID().uuidString + ".jpg"
//        let imagesRef = storageRef.child("images")
        let imageRef = storageRef.child(filename)

        let metadata = StorageMetadata()
        //        metadata.contentType = "image/jpeg"

        let uploadTask = imageRef.putData(data, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                onCompletion(downloadURL)
            }
        }

        let observer = uploadTask.observe(.progress) { snapshot in
            // A progress event occured
        }
//        return URL(string: "https://foo.bar/" + filename)!
    }
}
