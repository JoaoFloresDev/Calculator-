import UIKit
import Firebase
import FirebaseStorage
import os.log
import AVKit
import CoreData

struct FirebaseBackupService {
   
    static let fileManager = FileManager.default
    private static let storage = Storage.storage()
   
    // MARK: - Public Methods
   
    static func updateBackup(completion: @escaping (Bool) -> ()) {
        updateVideos()
        updateImages(completion: completion)
    }

    static func hasDataInFirebase(completion: @escaping (Bool, Error?, [MediaItem]?) -> Void) {
        fetchFirebaseMediaItems(completion: completion)
    }
   
    static func restoreBackup(items: [MediaItem]?, completion: @escaping (Bool, Error?) -> Void) {
        guard let items = items else {
            completion(false, nil)
            return
        }
         
        for item in items {
            processMediaItem(item)
        }
         
        completion(true, nil)
    }
   
    // MARK: - Private Helpers
   
    private static func updateVideos() {
        for name in VideoCloudInsertionManager.getNames() {
            switch getVideoData(videoPath: name) {
            case .success(let videoData):
                FirebaseVideoService.saveVideo(name: name, videoData: videoData) { success, error in
                    if success {
                        VideoCloudInsertionManager.deleteName(name)
                    }
                }
            case .failure(let error):
                os_log("Failed to get video data: %@", log: .default, type: .error, error.localizedDescription)
            }
        }
         
        for name in VideoCloudDeletionManager.getNames() {
            FirebaseVideoService.deleteVideoByName(name: name) { success, error in
                if success {
                    VideoCloudDeletionManager.deleteName(name)
                }
            }
        }
    }
   
    private static func updateImages(completion: @escaping (Bool) -> ()) {
        let group = DispatchGroup()
        var saveSuccess = false
        var deleteSuccess = false
         
        group.enter()
        FirebaseImageService.saveImages(names: ImageCloudInsertionManager.getNames()) { success in
            saveSuccess = success
            group.leave()
        }
         
        group.enter()
        FirebaseImageService.deleteImages(names: ImageCloudDeletionManager.getNames()) { success in
            deleteSuccess = success
            group.leave()
        }
         
        group.notify(queue: .main) {
            completion(saveSuccess && deleteSuccess)
        }
    }
   
    private static func fetchFirebaseMediaItems(completion: @escaping (Bool, Error?, [MediaItem]?) -> Void) {
        var imageItems: [(String, UIImage)]?
        var videoItems: [(String, Data)]?

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        FirebaseVideoService.fetchVideos { fetchedVideos, error in
            videoItems = fetchedVideos
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        FirebaseImageService.fetchImages { fetchedImages, error in
            imageItems = fetchedImages
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            var mediaItems: [MediaItem] = []

            if let imageItems = imageItems {
                mediaItems.append(contentsOf: imageItems.map { .image(name: $0.0, data: $0.1) })
            }

            if let videoItems = videoItems {
                mediaItems.append(contentsOf: videoItems.map { .video(name: $0.0, data: $0.1) })
            }

            completion(!mediaItems.isEmpty, nil, mediaItems)
        }
    }

    private static func processMediaItem(_ item: MediaItem) {
        switch item {
        case .image(let name, let image):
            ModelController.saveImageObject(image: image, path: name)
            handleFolderCreation(path: name, type: .image)
           
        case .video(let name, let data):
            getThumbnailImageFromVideoData(videoData: data) { thumbImage in
                _ = VideoModelController.saveVideoObject(image: thumbImage ?? UIImage(), video: data)
            }

            if name.filter({ $0 == "@" }).count > 1 {
                handleFolderCreation(path: name, type: .video)
            }
        }
    }

    static func getThumbnailImageFromVideoData(videoData: Data, completion: @escaping (UIImage?) -> Void) {
        guard let tempURL = saveTempFile(videoData: videoData) else {
            completion(nil)
            return
        }

        let asset = AVURLAsset(url: tempURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(value: 1, timescale: 60)

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            completion(uiImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            completion(nil)
        }

        removeTempFile(url: tempURL)
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
   
    static func getVideoData(videoPath: String) -> Result<Data, Error> {
        guard let path = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoPath) else {
            return .failure(NSError(domain: "Failed to retrieve video URL", code: 404, userInfo: nil))
        }
         
        do {
            let videoData = try Data(contentsOf: path)
            return .success(videoData)
        } catch let error {
            return .failure(error)
        }
    }

    static func handleFolderCreation(path: String, type: FoldersService.AssetType) {
        var outputArray = convertStringToArray(input: path)
        outputArray.removeLast()
        var foldersService = FoldersService(type: type)
        for index in 0..<outputArray.count {
            let basePath = "@" + concatenateStringsUpToIndex(array: outputArray, index: index)
            if !foldersService.checkAlreadyExist(folder: outputArray[index], basePath: basePath) {
                foldersService.add(folder: outputArray[index], basePath: basePath)
            }
        }
    }

    static func concatenateStringsUpToIndex(array: [String], index: Int) -> String {
        var result = ""
        for i in 0..<index {
            result += array[i]
        }
        return result
    }

    static func convertStringToArray(input: String) -> [String] {
        let components = input.components(separatedBy: "@")
        let filteredComponents = components.filter { !$0.isEmpty }
        return filteredComponents
    }
}

class FirebaseImageService: ObservableObject {
    private static let storage = Storage.storage()
    
    static let collectionIdentifier = "Photos"
    
    struct RecordKeys {
        static let name = "name"
        static let imageURL = "imageURL"
    }
    
    static func saveImage(name: String, image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let storage = storage.reference().child(getUserId()).child(collectionIdentifier)
            let storageRef = storage.child("\(UUID().uuidString).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    print("Failed to upload image: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                print("Image saved successfully")
                completion(true, nil)
            }
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
                                if let data = data, let userImage = UIImage(data: data) {
                                    fetchedItems.append((document.name, userImage))
                                }
                                dispatchGroup.leave()
                            }.resume()
                        } else {
                            dispatchGroup.leave()
                            print("downloadURL Errror", err ?? "")
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
    
    static func isICloudEnabled(completion: @escaping (Bool) -> Void) {
        // Replace this with Firebase specific code if needed
        let isFirebaseEnabled = Defaults.getBool(.iCloudEnabled)
        completion(isFirebaseEnabled)
    }
    
    static func enableICloudSync(completion: @escaping (Bool) -> Void) {
        // Replace this with Firebase specific code if needed
        Defaults.setBool(.iCloudEnabled, true)
        completion(true)
    }
    
    static func disableICloudSync(completion: @escaping (Bool) -> Void) {
        // Replace this with Firebase specific code if needed
        Defaults.setBool(.iCloudEnabled, false)
        completion(true)
    }
    
    static func redirectToICloudSettings() {
        if let url = URL(string: "App-prefs:root=CASTLE") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

class FirebaseVideoService: ObservableObject {
    
    private static let storage = Storage.storage()
    static var videos = [(String, UIImage)]()
    
    static let videoCollection = "Videos"
    
    struct VideoRecordKeys {
        static let name = "name"
        static let videoURL = "videoURL"
        static let uploadedBy = "uploadedBy"
    }
    
    static let userCollection = "users"
    
    static func saveVideo(name: String, videoData: Data, completion: @escaping (Bool, Error?) -> Void) {
        let quality = Defaults.getInt(.videoCompressionQuality)
        var qualityString = AVAssetExportPresetHighestQuality
        if quality < 4 {
            qualityString = AVAssetExportPresetLowQuality
        } else if quality < 7 {
            qualityString = AVAssetExportPresetMediumQuality
        }
        saveVideo2(
            name: name,
            videoData: videoData,
            quality: qualityString,
            completion: completion
        )
    }
    
    static func saveVideo2(name: String, videoData: Data, quality: String, completion: @escaping (Bool, Error?) -> Void) {
        
        let storage = storage.reference().child(getUserId()).child(videoCollection)
        let videoID = UUID().uuidString
        let videoRef = storage.child("videos/\(videoID).mp4")
        
        videoRef.putData(videoData, metadata: nil) { (metadata, error) in
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
    
    static func fetchVideos(completion: @escaping ([(String, Data)]?, Error?) -> Void) {
    
        let storage = storage.reference().child(getUserId()).child(videoCollection)
        storage.listAll { result, error in
            if let result, result.items.count > 0 {
                var fetchedItems = [(String, Data)]()
                let dispatchGroup = DispatchGroup()
                
                for document in result.items {
                    document.downloadURL { url, err in
                        if let url {
                            dispatchGroup.enter()
                            
                            URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let data = data {
                                    fetchedItems.append((document.name, data))
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
    
    static func getThumbnailImageFromVideoData(videoData: Data, completion: @escaping (UIImage?) -> Void) {
        guard let tempURL = saveTempFile(videoData: videoData) else {
            completion(nil)
            return
        }
        
        let asset = AVURLAsset(url: tempURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(value: 1, timescale: 60)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            completion(uiImage)
        } catch {
            print("Error generating thumbnail image: \(error)")
            completion(nil)
        }
        
        removeTempFile(url: tempURL)
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
    
    static func deleteVideoByName(name: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false, NSError(domain: "FirebaseVideoService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let storage = storage.reference().child(getUserId()).child(videoCollection)
        let videoRef = storage.child(name)
        
        videoRef.delete { error in
            if let error = error {
                print("Error deleting video from storage: \(error)")
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
}


func getUserId() -> String {
    let userId = Auth.auth().currentUser?.uid ?? "AnonymousUploads"
    return userId
}
