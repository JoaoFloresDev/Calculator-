import Firebase
import FirebaseStorage
import UIKit

class FirebaseVideoService: ObservableObject {
    
    // MARK: - Properties
    
    private static let storage = Storage.storage()
    static let videoCollection = "Videos"
    
    struct VideoRecordKeys {
        static let name = "name"
        static let videoURL = "videoURL"
        static let uploadedBy = "uploadedBy"
    }
    
    // MARK: - Public Methods
    
    static func saveVideo(name: String, videoData: Data, completion: @escaping (Bool, Error?) -> Void) {
        saveVideoData(name: name, videoData: videoData, completion: completion)
    }
    
    static func fetchVideos(completion: @escaping ([(String, Data)]?, Error?) -> Void) {
        let storage = storage.reference().child(getUserId()).child(videoCollection)
        
        storage.listAll { result, error in
            if let result, result.items.count > 0 {
                var fetchedItems = [(String, Data)]()
                let dispatchGroup = DispatchGroup()
                
                for document in result.items {
                    dispatchGroup.enter()
                    document.downloadURL { url, err in
                        if let url {
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let data = data {
                                    fetchedItems.append((document.name, data.invert()))
                                }
                                dispatchGroup.leave()
                            }.resume()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(fetchedItems, nil)
                }
            } else {
                print("Failed to fetch videos: \(error?.localizedDescription ?? "")")
                completion(nil, error)
            }
        }
    }
    
    static func deleteVideoByName(name: String, completion: @escaping (Bool, Error?) -> Void) {
        let storage = storage.reference().child(getUserId()).child(videoCollection)
        let videoRef = storage.child(name)
        
        videoRef.delete { error in
            if let error = error {
                print("Failed to delete video from storage: \(error)")
                completion(false, error)
                return
            } else {
                print("Video deleted successfully")
                completion(true, nil)
            }
        }
    }
    
    static func deleteMultipleVideosByNames(names: [String], completion: @escaping (Bool, Error?) -> Void) {
        let group = DispatchGroup()
        var errorFound: Error?
        
        for name in names {
            group.enter()
            
            deleteVideoByName(name: name) { success, error in
                if !success {
                    errorFound = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = errorFound {
                print("Error deleting one or more videos: \(error)")
                completion(false, error)
            } else {
                print("All videos deleted successfully")
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private static func saveVideoData(name: String, videoData: Data, completion: @escaping (Bool, Error?) -> Void) {
        let storage = storage.reference().child(getUserId()).child(videoCollection)
        let videoID = UUID().uuidString
        let videoRef = storage.child("\(videoID).bin")
        
        videoRef.putData(videoData.invert(), metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading video: \(error)")
                completion(false, error)
                return
            } else {
                print("Video data saved successfully")
                completion(true, nil)
            }
        }
    }
    
    private static func saveTempFile(videoData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try videoData.write(to: tempURL)
            return tempURL
        } catch {
            print("Error saving temp file: \(error)")
            return nil
        }
    }
    
    private static func removeTempFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing temp file: \(error)")
        }
    }
}
