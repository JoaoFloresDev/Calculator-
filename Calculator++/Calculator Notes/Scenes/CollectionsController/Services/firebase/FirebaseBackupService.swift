//
//  FirebaseBackupService.swift
//  Calculator Notes
//
//  Created by Vikram Kumar on 13/06/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

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
//            if let error = error {
//                completion(false, error, nil)
//                return
//            }
            videoItems = fetchedVideos
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        FirebaseImageService.fetchImages { fetchedImages, error in
//            if let error = error {
//                completion(false, error, nil)
//                return
//            }
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

/*
struct FirebaseModelController {
    private static let storage = Storage.storage()
    private static let db = FirebaseBackupService.getDBPath()
    private static let subsystem = "com.example.calculatornotes"
    private static let category = "errors"

    static func listPhotosOf(basePath: String, completion: @escaping ([Photo]) -> Void) {
        let collectionRef = db.collection("images")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                os_log("Failed to fetch documents: %@", log: .default, type: .error, error.localizedDescription)
                completion([])
                return
            }
            var images = [Photo]()
            for document in snapshot!.documents {
                if let imageName = document.data()["imageName"] as? String {
                    if handleNewImage(basePath: basePath, imageName: imageName) || handleOldImage(basePath: basePath) {
                        fetchImage(imageName: imageName) { image in
                            if let image = image {
                                images.append(Photo(id: <#String#>, name: imageName, image: image))
                            }
                            completion(images)
                        }
                    }
                }
            }
        }
    }

    static func saveImageObject(image: UIImage, basePath: String, completion: @escaping (Photo?) -> Void) {
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            os_log("Failed to convert image to data.", log: .default, type: .error)
            completion(nil)
            return
        }

        let imageName = "\(basePath)-\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("images/\(imageName)")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                os_log("Failed to upload image: %@", log: .default, type: .error, error.localizedDescription)
                completion(nil)
                return
            }
            db.collection("images").document(imageName).setData(["imageName": imageName]) { error in
                if let error = error {
                    os_log("Failed to save image data to Firestore: %@", log: .default, type: .error, error.localizedDescription)
                    completion(nil)
                    return
                }
                ImageCloudInsertionManager.addName(imageName)
                completion(Photo(name: imageName, image: image))
            }
        }
    }

    static func deleteImageObject(name: String, completion: @escaping (Bool) -> Void) {
        let storageRef = storage.reference().child("images/\(name)")
        let documentRef = db.collection("images").document(name)

        storageRef.delete { error in
            if let error = error {
                os_log("Failed to delete image from storage: %@", log: .default, type: .error, error.localizedDescription)
                completion(false)
                return
            }
            documentRef.delete { error in
                if let error = error {
                    os_log("Failed to delete image document: %@", log: .default, type: .error, error.localizedDescription)
                    completion(false)
                    return
                }
                ImageCloudDeletionManager.addName(name)
                completion(true)
            }
        }
    }

    static func listAllPhotos(completion: @escaping ([Photo]) -> Void) {
        let collectionRef = db.collection("images")
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                os_log("Failed to fetch documents: %@", log: .default, type: .error, error.localizedDescription)
                completion([])
                return
            }
            var images = [Photo]()
            for document in snapshot!.documents {
                if let imageName = document.data()["imageName"] as? String {
                    fetchImage(imageName: imageName) { image in
                        if let image = image {
                            images.append(Photo(name: imageName, image: image))
                        }
                        completion(images)
                    }
                }
            }
        }
    }

    private static func fetchImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = storage.reference().child("images/\(imageName)")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                os_log("Failed to download image data: %@", log: .default, type: .error, error.localizedDescription)
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
}


extension FirebaseModelController {
    private static func handleNewImage(basePath: String, imageName: String) -> Bool {
        return imageName.contains(basePath) && samePathDeep(basePath: basePath, imageName: imageName)
    }
    
    private static func samePathDeep(basePath: String, imageName: String) -> Bool {
        return imageName.filter({ $0 == "@" }).count == basePath.filter({ $0 == "@" }).count
    }
    
    private static func handleOldImage(basePath: String) -> Bool {
        return countOccurrences(of: "@", in: basePath) < 2
    }
    
    private static func countOccurrences(of character: Character, in string: String) -> Int {
        return string.filter { $0 == character }.count
    }
}
*/

class FirebaseImageService: ObservableObject {
    private static let storage = Storage.storage()
    
    static let collectionIdentifier = "Photos"
    
    struct RecordKeys {
        static let name = "name"
        static let imageURL = "imageURL"
    }
    
    static func saveImage(name: String, image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        var image = image
        switch Defaults.getInt(.imageCompressionQuality) {
        case let x where x <= 3 :
            image = image.scale(newWidth: 40)
        case let x where x <= 6 :
            image = image.scale(newWidth: 70)
        default:
            print("melhor possivel")
        }
        
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

struct ImageCloudDeletionManager {
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        Defaults.setStringArray(.imagesToDelete, savedNames)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            Defaults.setStringArray(.imagesToDelete, savedNames)
        }
    }
    
    static func getNames() -> [String] {
        return Defaults.getStringArray(.imagesToDelete) ?? []
    }
}

struct ImageCloudInsertionManager {
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        Defaults.setStringArray(.imagesToUpload, savedNames)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            Defaults.setStringArray(.imagesToUpload, savedNames)
        }
    }
    
    static func getNames() -> [String] {
        Defaults.getStringArray(.imagesToUpload) ?? []
    }
}

struct VideoCloudDeletionManager {
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        Defaults.setStringArray(.videoToDelete, savedNames)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            Defaults.setStringArray(.videoToDelete, savedNames)
        }
    }
    
    static func getNames() -> [String] {
        return Defaults.getStringArray(.videoToDelete) ?? []
    }
}

struct VideoCloudInsertionManager {
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        Defaults.setStringArray(.videoToUpload, savedNames)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            Defaults.setStringArray(.videoToUpload, savedNames)
        }
    }
    
    static func getNames() -> [String] {
        Defaults.getStringArray(.videoToUpload) ?? []
    }
}

struct PasswordInsertionManager {
    private static let userDefaults = UserDefaults.standard
    private static let namesKey = "PasswordToUpload"
    
    static func addName(_ name: String) {
        var savedNames = getNames()
        savedNames.append(name)
        userDefaults.set(savedNames, forKey: namesKey)
    }
    
    static func deleteName(_ name: String) {
        var savedNames = getNames()
        if let index = savedNames.firstIndex(of: name) {
            savedNames.remove(at: index)
            userDefaults.set(savedNames, forKey: namesKey)
        }
    }
    
    static func getNames() -> [String] {
        return userDefaults.array(forKey: namesKey) as? [String] ?? []
    }
}

class CloudKitVideoService: ObservableObject {
    
    private static let identifier = "iCloud.calculatorNotes"
    private static let database = CKContainer(identifier: identifier).publicCloudDatabase

    static var videos = [(String, UIImage)]()
    
    static let videoRecordTypeIdentifier = "Video"

    struct VideoRecordKeys {
        static let name = "name"
        static let video = "video"
        static let uploadedBy = "uploadedBy" // Campo de referência ao usuário
    }

    static let userRecordTypeIdentifier = "Users"
    
    struct UserRecordKeys {
        static let userID = "___recordID"
    }
    
    struct PredicateFormats {
        static let nameEqual = "name == %@"
        static let alwaysTrue = NSPredicate(value: true)
    }
    
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
        let record = CKRecord(recordType: videoRecordTypeIdentifier)
        record.setValue(name, forKey: VideoRecordKeys.name)
        
        // Recupere o ID do usuário atual
        CKContainer.default().fetchUserRecordID { (userRecordID, error) in
            if let error = error {
                print("Erro ao recuperar o ID do usuário atual: \(error)")
                completion(false, error)
                return
            }
            
            if let userRecordID = userRecordID {
                let reference = CKRecord.Reference(recordID: userRecordID, action: .none)
                record.setValue(reference, forKey: VideoRecordKeys.uploadedBy)
                
                // Salvando o vídeo
                let tempDirectory = FileManager.default.temporaryDirectory
                let videoFileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                try? videoData.write(to: videoFileURL)
                
                // Configurar as opções de exportação
                let asset = AVURLAsset(url: videoFileURL)
                let exportSession = AVAssetExportSession(asset: asset, presetName: quality)
                
                guard let exportSession = exportSession else {
                    print("Erro ao criar a sessão de exportação")
                    completion(false, nil)
                    return
                }
                
                let compressedVideoURL = tempDirectory.appendingPathComponent(UUID().uuidString + "_compressed.mp4")
                exportSession.outputFileType = .mp4
                exportSession.outputURL = compressedVideoURL
                
                exportSession.exportAsynchronously {
                    switch exportSession.status {
                    case .completed:
                        let compressedVideoData = try? Data(contentsOf: compressedVideoURL)
                        let compressedVideoAsset = CKAsset(fileURL: compressedVideoURL)
                        record.setValue(compressedVideoAsset, forKey: VideoRecordKeys.video)
                        
                        database.save(record) { record, error in
                            if record != nil, error == nil {
                                print(Notifications.itemSaved)
                                completion(true, nil)
                            } else {
                                print(Notifications.errorSavingItem, error.debugDescription)
                                completion(false, error)
                            }
                        }
                        
                    case .failed:
                        print("Erro ao comprimir o vídeo")
                        completion(false, exportSession.error)
                        
                    default:
                        print("Exportação do vídeo incompleta ou cancelada")
                        completion(false, nil)
                    }
                }
            } else {
                print("ID do usuário atual não encontrado")
                completion(false, nil)
            }
        }
    }
    static func fetchVideos(completion: @escaping ([(String, Data)]?, Error?) -> Void) {
        // Recupere o ID do usuário atual
        CKContainer.default().fetchUserRecordID { (userRecordID, error) in
            if let error = error {
                print("Erro ao recuperar o ID do usuário atual: \(error)")
                completion(nil, error)
                return
            }
            
            if let userRecordID = userRecordID {
                let predicate = NSPredicate(format: "uploadedBy == %@", CKRecord.Reference(recordID: userRecordID, action: .none))
                let query = CKQuery(recordType: CloudKitVideoService.videoRecordTypeIdentifier, predicate: PredicateFormats.alwaysTrue)
                
                database.perform(query, inZoneWith: nil) { records, error in
                    if let error = error {
                        print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                        completion(nil, error)
                        return
                    }
                    
                    if let records = records {
                        var fetchedItems = [(String, Data)]()
                        
                        for record in records {
                            if let videoName = record[VideoRecordKeys.name] as? String,
                               let videoAsset = record[VideoRecordKeys.video] as? CKAsset,
                               let videoData = try? Data(contentsOf: videoAsset.fileURL) {
                                fetchedItems.append((videoName, videoData))
                            }
                        }
                        
                        DispatchQueue.main.async {
                            print("! \(fetchedItems) !")
                            completion(fetchedItems, nil)
                        }
                    }
                }
            } else {
                print("ID do usuário atual não encontrado")
                completion(nil, nil)
            }
        }
    }
    
    static func fetchVideosPlaceholders(completion: @escaping ([(String, UIImage)]?, Error?) -> Void) {
        let query = CKQuery(recordType: CloudKitVideoService.videoRecordTypeIdentifier, predicate: PredicateFormats.alwaysTrue)
        
        CloudKitVideoService.database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let records = records {
                var fetchedItems = [(String, UIImage)]()
                
                for record in records {
                    if let videoName = record[VideoRecordKeys.name] as? String,
                       let videoAsset = record[VideoRecordKeys.video] as? CKAsset,
                       let videoData = try? Data(contentsOf: videoAsset.fileURL) {
                        CloudKitVideoService.getThumbnailImageFromVideoData(videoData: videoData) { image in
                            guard let image = image else {
                                return
                            }
                            fetchedItems.append((videoName, image))
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.videos = fetchedItems
                    print("! \(fetchedItems) !")
                    completion(fetchedItems, nil)
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
        
        let time = CMTimeMake(1, 60)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            completion(uiImage)
        } catch {
            print("Erro ao gerar imagem do vídeo: \(error)")
            completion(nil)
        }
        
        // Remova o arquivo temporário, se necessário
        removeTempFile(url: tempURL)
    }
    
    private static func saveTempFile(videoData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try videoData.write(to: tempURL)
            return tempURL
        } catch {
            print("Erro ao salvar arquivo temporário: \(error)")
            return nil
        }
    }
    
    private static func removeTempFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Erro ao remover arquivo temporário: \(error)")
        }
    }
    
    static func deleteVideoByName(name: String, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(format: PredicateFormats.nameEqual, name)
        let query = CKQuery(recordType: videoRecordTypeIdentifier, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Erro ao buscar registros: \(error)")
                completion(false, error)
                return
            }
            
            guard let records = records, let record = records.first else {
                print("Nenhum registro encontrado")
                completion(false, nil)
                return
            }
            
            database.delete(withRecordID: record.recordID) { _, error in
                if let error = error {
                    print("Erro ao deletar registro: \(error)")
                    completion(false, error)
                } else {
                    print("Registro deletado com sucesso")
                    completion(true, nil)
                }
            }
        }
    }
    
    // Deletar um array de vídeos, dado o name
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
                print("Erro ao deletar um ou mais registros: \(error)")
                completion(false, error)
            } else {
                print("Todos os registros deletados com sucesso")
                completion(true, nil)
            }
        }
    }
}

enum MediaItem {
    case image(name: String, data: UIImage)
    case video(name: String, data: Data)
}

struct BackupService2 {
    
    static let fileManager = FileManager.default
    
    // MARK: - Public Methods
    
    static func updateBackup(completion: @escaping (Bool) -> ()) {
        updateVideos()
        updateImages(completion: completion)
    }

    static func hasDataInCloudKit(completion: @escaping (Bool, Error?, [MediaItem]?) -> Void) {
        fetchCloudKitMediaItems(completion: completion)
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
                CloudKitVideoService.saveVideo(name: name, videoData: videoData) { success, error in
                    if success {
                        VideoCloudInsertionManager.deleteName(name)
                    }
                }
            case .failure(let error):
                os_log("Failed to get video data: %@", log: .default, type: .error, error.localizedDescription)
            }
        }
        
        for name in VideoCloudDeletionManager.getNames() {
            CloudKitVideoService.deleteVideoByName(name: name) { success, error in
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
        CloudKitImageService.saveImages(names: ImageCloudInsertionManager.getNames()) { success in
            saveSuccess = success
            group.leave()
        }
        
        group.enter()
        CloudKitImageService.deleteImages(names: ImageCloudDeletionManager.getNames()) { success in
            deleteSuccess = success
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(saveSuccess && deleteSuccess)
        }
    }
    
    private static func fetchCloudKitMediaItems(completion: @escaping (Bool, Error?, [MediaItem]?) -> Void) {
        var imageItems: [(String, UIImage)]?
        var videoItems: [(String, Data)]?

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        CloudKitVideoService.fetchVideos { fetchedVideos, error in
            if let error = error {
                completion(false, error, nil)
                return
            }
            videoItems = fetchedVideos
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        CloudKitImageService.fetchImages { fetchedImages, error in
            if let error = error {
                completion(false, error, nil)
                return
            }
            imageItems = fetchedImages
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            var mediaItems: [MediaItem] = []

            print(imageItems?.count)
            if let imageItems = imageItems {
                mediaItems.append(contentsOf: imageItems.map { .image(name: $0.0, data: $0.1) })
            }
            print(mediaItems.count)

            print(videoItems?.count)
            if let videoItems = videoItems {
                mediaItems.append(contentsOf: videoItems.map { .video(name: $0.0, data: $0.1) })
            }

            print(mediaItems.count)
            completion(!mediaItems.isEmpty, nil, mediaItems)
        }
    }

    
    private static func processMediaItem(_ item: MediaItem) {
        switch item {
        case .image(let name, let image):
            ModelController.saveImageObject(image: image, path: name)
            handleFolderCreation(path: name, type: .image)
            
        case .video(let name, let data):
            // Seu código para salvar o objeto de vídeo aqui.
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

        let time = CMTimeMake(1, 60)

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            completion(uiImage)
        } catch {
            print("Erro ao gerar imagem do vídeo: \(error)")
            completion(nil)
        }

        // Remova o arquivo temporário, se necessário
        removeTempFile(url: tempURL)
    }
    
    private static func saveTempFile(videoData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try videoData.write(to: tempURL)
            return tempURL
        } catch {
            print("Erro ao salvar arquivo temporário: \(error)")
            return nil
        }
    }

    private static func removeTempFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Erro ao remover arquivo temporário: \(error)")
        }
    }
    
    // Método para obter dados do vídeo com base no caminho fornecido
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

    // Função auxiliar para lidar com a criação de pastas
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

    // Função para concatenar strings até um índice específico
    static func concatenateStringsUpToIndex(array: [String], index: Int) -> String {
        var result = ""
        for i in 0..<index {
            result += array[i]
        }
        return result
    }

    // Função para converter uma string em um array com base em um delimitador
    static func convertStringToArray(input: String) -> [String] {
        let components = input.components(separatedBy: "@")
        let filteredComponents = components.filter { !$0.isEmpty }
        return filteredComponents
    }
}
