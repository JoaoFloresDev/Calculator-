import UIKit
import Firebase
import FirebaseStorage
import os.log
import AVKit
import CoreData

enum MediaItem {
    case image(name: String, data: UIImage)
    case video(name: String, data: Data)
}

func getUserId() -> String {
    let userId = Auth.auth().currentUser?.uid ?? "AnonymousUploads"
    return userId
}

import UIKit
import Firebase
import FirebaseStorage
import os.log
import AVKit
import CoreData

struct FirebaseBackupService {
   
    // MARK: - Properties
    
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
   
    private static let imageProcessingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4
        return queue
    }()
   
    // MARK: - Public Methods
   
    static func restoreBackup(items: [MediaItem]?, completion: @escaping (Bool, Error?) -> Void) {
        guard let items = items else {
            completion(false, nil)
            return
        }

        let dispatchGroup = DispatchGroup()

        for item in items {
            dispatchGroup.enter()
            imageProcessingQueue.addOperation {
                processMediaItem(item) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(true, nil)
        }
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

    private static func processMediaItem(_ item: MediaItem, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            switch item {
            case .image(let name, let image):
                imageProcessingQueue.addOperation {
                    autoreleasepool {
                        _ = ModelController.saveImageObject(image: image, path: name)
                        
                        DispatchQueue.main.async {
                            handleFolderCreation(path: name, type: .image)
                            completion()
                        }
                    }
                }
                
            case .video(let name, let data):
                imageProcessingQueue.addOperation {
                    autoreleasepool {
                        getThumbnailImageFromVideoData(videoData: data) { thumbImage in
                            _ = VideoModelController.saveVideoObject(image: thumbImage ?? UIImage(), video: data)
                            
                            DispatchQueue.main.async {
                                if name.filter({ $0 == "@" }).count > 1 {
                                    handleFolderCreation(path: name, type: .video)
                                }
                                completion()
                            }
                        }
                    }
                }
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
