import FirebaseStorage
import Firebase
import Foundation
import AssetsPickerViewController
import UIKit
import ImageViewer

struct FirebasePhotoSharingService {
   
    // MARK: - Properties
    private static let storage = Storage.storage()
   
    // MARK: - Public Methods
    static func createSharedFolderWithPhotos(modelData: [Photo], completion: @escaping (String?, String?, Error?) -> ()) {
        guard !modelData.isEmpty else {
            completion(nil, nil, NSError(domain: "No photos to upload", code: 400, userInfo: nil))
            return
        }
        
        // Criar uma pasta única com UUID
        let folderName = UUID().uuidString
        let folderRef = storage.reference().child("shared_photos/\(folderName)")
        
        let dispatchGroup = DispatchGroup()
        var uploadErrors: [Error] = []
        
        // Fazer o upload de cada imagem para o Firebase
        for photo in modelData {
            guard let imageData = UIImageJPEGRepresentation(photo.image, 0.8) else {
                print("Erro ao converter a imagem para JPEG.")
                uploadErrors.append(NSError(domain: "Image conversion failed", code: 401, userInfo: nil))
                continue
            }

            let imageName = UUID().uuidString + ".jpg"
            let imageRef = folderRef.child(imageName)
            
            dispatchGroup.enter()
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Erro ao fazer upload da imagem: \(error.localizedDescription)")
                    uploadErrors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        // Quando todos os uploads forem concluídos, gerar o deep link
        dispatchGroup.notify(queue: .main) {
            if uploadErrors.isEmpty {
                createDynamicLink(for: folderName, completion: completion)
            } else {
                completion(nil,nil, uploadErrors.first)
            }
        }
    }
    
    // MARK: - Private Methods
    private static func createDynamicLink(for folderName: String, completion: @escaping (String?, String?, Error?) -> ()) {
        // Criar um link customizado no formato myapp://photos/folderId
        let folderId = String(folderName.dropLast(4))
        let deepLinkURL = "secrets://shared_photos/\(folderId)"
        let password = String(folderName.suffix(4))
        
        // Retorna o deeplink gerado
        completion(deepLinkURL, password, nil)
    }
    
    static func createSharedFolderWithVideos(modelData: [URL], completion: @escaping (String?, String?, Error?) -> ()) {
        guard !modelData.isEmpty else {
            completion(nil, nil, NSError(domain: "No videos to upload", code: 400, userInfo: nil))
            return
        }
        
        // Criar uma pasta única com UUID
        let folderName = UUID().uuidString
        let folderRef = storage.reference().child("shared_videos/\(folderName)")
        
        let dispatchGroup = DispatchGroup()
        var uploadErrors: [Error] = []
        
        // Fazer o upload de cada vídeo para o Firebase
        for videoURL in modelData {
            let videoName = UUID().uuidString + ".mov" // ou .mp4 dependendo do formato
            let videoRef = folderRef.child(videoName)
            
            dispatchGroup.enter()
            
            // Fazer upload do vídeo
            videoRef.putFile(from: videoURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("Erro ao fazer upload do vídeo: \(error.localizedDescription)")
                    uploadErrors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        // Quando todos os uploads forem concluídos, gerar o deep link
        dispatchGroup.notify(queue: .main) {
            if uploadErrors.isEmpty {
                createDynamicLink(for: folderName, completion: completion)
            } else {
                completion(nil, nil, uploadErrors.first)
            }
        }
    }
    
//    // MARK: - Private Methods
//    private static func createDynamicLink(for folderName: String, completion: @escaping (String?, String?, Error?) -> ()) {
//        // Criar um link customizado no formato myapp://videos/folderId
//        let folderId = String(folderName.dropLast(4))
//        let deepLinkURL = "secrets://shared_videos/\(folderId)"
//        let password = String(folderName.suffix(4))
//        
//        // Retorna o deeplink gerado
//        completion(deepLinkURL, password, nil)
//    }
}
