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
        var folderName = UUID().uuidString
        let range = folderName.index(folderName.endIndex, offsetBy: -4)..<folderName.endIndex
        let lastFour = folderName[range].lowercased()
        folderName.replaceSubrange(range, with: lastFour)
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
        let folderId = String(folderName.dropLast(4))
        let deepLinkURL = "https://joaofloresdev.github.io/secrets?\(folderId)"
        let password = String(folderName.suffix(4))
        
        // Retorna o deeplink gerado
        completion(deepLinkURL, password, nil)
    }

    static func createSharedFolderWithVideos(modelData: [URL], completion: @escaping (String?, String?, Error?) -> ()) {
        guard !modelData.isEmpty else {
            completion(nil, nil, NSError(domain: "No videos to upload", code: 400, userInfo: nil))
            return
        }
        var folderName = UUID().uuidString
        let range = folderName.index(folderName.endIndex, offsetBy: -4)..<folderName.endIndex
        let lastFour = folderName[range].lowercased()
        folderName.replaceSubrange(range, with: lastFour)

        let folderRef = storage.reference().child("shared_photos/\(folderName)")
        
        let dispatchGroup = DispatchGroup()
        var uploadErrors: [Error] = []
        
        // Fazer o upload de cada vídeo para o Firebase
        for videoURL in modelData {
            let videoName = UUID().uuidString + ".mov" // ou .mp4 dependendo do formato
            let videoRef = folderRef.child(videoName)
            
            dispatchGroup.enter()
            
            // Realizar o upload do vídeo
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
}

extension FirebasePhotoSharingService {
    static func deleteSharedFolderWithPhotos(folderId: String, completion: @escaping (Error?) -> ()) {
        let folderRef = storage.reference().child("shared_photos/\(folderId)")
        
        // Listar todos os arquivos na pasta
        folderRef.listAll { (result, error) in
            if let error = error {
                print("Erro ao listar arquivos na pasta: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let items = result?.items else {
                completion(NSError(domain: "No items to delete", code: 404, userInfo: nil))
                return
            }
            
            let dispatchGroup = DispatchGroup()
            var deletionErrors: [Error] = []
            
            for item in items {
                dispatchGroup.enter()
                item.delete { error in
                    if let error = error {
                        print("Erro ao deletar arquivo: \(error.localizedDescription)")
                        deletionErrors.append(error)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Se houver erros de deleção, retorna o primeiro erro; caso contrário, retorna sucesso
                if deletionErrors.isEmpty {
                    completion(nil) // Itens deletados com sucesso
                } else {
                    completion(deletionErrors.first)
                }
            }
        }
    }
}
extension FirebasePhotoSharingService {
    // MARK: - Public Method for Uploading Text File
    static func uploadTextFile(mail: String? = nil, message: String, completion: @escaping (String?, Error?) -> ()) {
        let maxPrefixLength = 15
        let prefix = String(message.prefix(maxPrefixLength)).replacingOccurrences(of: " ", with: "_")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        let dateString = dateFormatter.string(from: Date())
        let uniqueID = UUID().uuidString
        let fileName = "\(prefix)___\(dateString)___\(uniqueID).txt"
        
        // Criar uma referência para o arquivo .txt no Firebase Storage
        let fileRef = storage.reference().child("shared_texts/opinions/\(fileName)")
        
        let fullText = message + "\n\nemail: \(mail ?? "unknow")"
        guard let fileData = fullText.data(using: .utf8) else {
            completion(nil, NSError(domain: "Text conversion failed", code: 500, userInfo: nil))
            return
        }
        
        // Realizar o upload do arquivo .txt para o Firebase Storage
        fileRef.putData(fileData, metadata: nil) { metadata, error in
            if let error = error {
                print("Erro ao fazer upload do arquivo de texto: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                // Obter a URL de download do arquivo para retornar no completion
                fileRef.downloadURL { url, error in
                    if let error = error {
                        print("Erro ao obter a URL de download: \(error.localizedDescription)")
                        completion(nil, error)
                    } else {
                        // Retorna a URL do arquivo txt armazenado
                        completion(url?.absoluteString, nil)
                    }
                }
            }
        }
    }
    
    func generateFileName(from message: String) -> String {
        let maxPrefixLength = 20
        let prefix = String(message.prefix(maxPrefixLength)).replacingOccurrences(of: " ", with: "_")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let uniqueID = UUID().uuidString
        let fileName = "\(prefix)_\(dateString)_\(uniqueID).txt"
        return fileName
    }
}
