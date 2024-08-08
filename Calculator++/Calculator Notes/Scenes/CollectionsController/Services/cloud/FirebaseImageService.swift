import Firebase
import FirebaseStorage
import UIKit

class FirebaseImageService: ObservableObject {
    
    // MARK: - Properties
    
    private static let storage = Storage.storage()
    static let collectionIdentifier = "Photos"
    
    struct RecordKeys {
        static let name = "name"
        static let imageURL = "imageURL"
    }
    
    // MARK: - Public Methods
    
    static func saveImage(name: String, image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let storage = storage.reference().child(getUserId()).child(collectionIdentifier)
            let storageRef = storage.child("\(UUID().uuidString).bin")
            let metadata = StorageMetadata()
            metadata.contentType = "application/octet-stream"
            
            storageRef.putData(imageData.invert(), metadata: metadata) { metadata, error in
                if let error = error {
                    print("Failed to upload image: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                print("Image saved successfully")
                completion(true, nil)
            }
        } else {
            let error = NSError(domain: "FirebaseImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
            completion(false, error)
        }
    }
    
    static func fetchImages(completion: @escaping ([(String, UIImage)]?, Error?) -> Void) {
        let storage = storage.reference().child(getUserId()).child(collectionIdentifier)
        
        storage.listAll { result, error in
            if let result, result.items.count > 0 {
                var fetchedItems = [(String, UIImage)]()
                let dispatchGroup = DispatchGroup()
                
                for document in result.items {
                    dispatchGroup.enter()
                    document.downloadURL { url, err in
                        if let url {
                            URLSession.shared.dataTask(with: url) { data, response, error in
                                if let data = data, let userImage = UIImage(data: data.invert()) {
                                    fetchedItems.append((document.name, userImage))
                                }
                                dispatchGroup.leave()
                            }.resume()
                        } else {
                            dispatchGroup.leave()
                            print("downloadURL Error", err ?? "")
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(fetchedItems, nil)
                }
            } else {
                print("Failed to fetch images: \(error?.localizedDescription ?? "")")
                completion(nil, error)
            }
        }
    }
    
    static func deleteImage(name: String, completion: @escaping (Bool, Error?) -> Void) {
        let storage = storage.reference().child(getUserId()).child(collectionIdentifier)
        let storageRef = storage.child(name)
        
        storageRef.delete { error in
            if let error = error {
                print("Failed to delete image: \(error.localizedDescription)")
                completion(false, error)
                return
            } else {
                print("Image deleted successfully")
                completion(true, nil)
            }
        }
    }
    
    static func deleteImages(names: [String], completion: @escaping (Bool) -> ()) {
        var totalCompleted = 0
        var totalSuccess = 0
        
        if names.isEmpty {
            completion(true)
        }
        
        for name in names {
            deleteImage(name: name) { success, error in
                totalCompleted += 1
                
                if success && error == nil {
                    totalSuccess += 1
                    ImageCloudDeletionManager.deleteName(name)
                }
                
                if totalCompleted == names.count {
                    completion(totalSuccess == names.count)
                }
            }
        }
    }
    
    static func saveImages(names: [String], completion: @escaping (Bool) -> ()) {
        let serialQueue = DispatchQueue(label: "com.yourApp.saveImages")
        var totalCompleted = 0
        var totalSuccess = 0
        
        if names.isEmpty {
            completion(true)
        }
        
        for name in names {
            if let image = CoreDataImageService.fetchImage(imageName: name) {
                FirebaseImageService.saveImage(name: name, image: image) { success, error in
                    serialQueue.sync {
                        totalCompleted += 1
                        if success {
                            totalSuccess += 1
                        }
                        
                        ImageCloudInsertionManager.deleteName(name)
                        
                        if totalCompleted == names.count {
                            DispatchQueue.main.async {
                                completion(totalSuccess == names.count)
                            }
                        }
                    }
                }
            } else {
                serialQueue.sync {
                    totalCompleted += 1
                    if totalCompleted == names.count {
                        DispatchQueue.main.async {
                            completion(totalSuccess == names.count)
                        }
                    }
                }
            }
        }
    }
    
    static func redirectToICloudSettings() {
        if let url = URL(string: "App-prefs:root=CASTLE") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
