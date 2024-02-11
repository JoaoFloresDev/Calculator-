import Foundation
import UIKit
import CoreData
import os.log

struct VideoModelController {
    static let shared = VideoModelController()
    
    static let entityName = "StoredVideo"
    
    private static var savedObjects = [StoredVideo]()
    private static var videos = [Video]()
    private static var pathURLs = [String]()
    
    private static var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private static let subsystem = "com.example.calculatornotes"
    private static let category = "errors"
    
    // MARK: - Fetching
    static func fetchImageObjectsInit(basePath: String) -> [Video] {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            videos.removeAll()
            
            for imageObject in savedObjects {
                guard let imageName = imageObject.imageName else {
                    continue
                }
                
                if (imageName.contains(basePath)
                    && imageName.filter({ $0 == "@" }).count ==
                    basePath.filter({ $0 == "@" }).count)  || handleOldImage(basePath: basePath){
                    
                    if let storedImage = CoreDataImageService.fetchImage(imageName: imageName) {
                        videos.append(Video(image: storedImage, name: imageName))
                    }
                }
            }
        } catch let error as NSError {
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        
        return videos
    }
    
    static func fetchPathVideosObjectsInit(basePath: String) -> [String] {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return []
        }
        
        let videoObjectRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(videoObjectRequest)
            
            pathURLs.removeAll()
            
            for videoObject in savedObjects {
                if let path = videoObject.pathURL {
                    if (path.contains(basePath)
                        && path.filter({ $0 == "@" }).count ==
                        basePath.filter({ $0 == "@" }).count) || handleOldImage(basePath: basePath) {
                        pathURLs.append(path)
                    }
                }
            }
        } catch let error as NSError {
            os_log("Could not fetch video objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        
        return pathURLs
    }
    
    // MARK: - Saving and Deleting
    static func saveVideoObject(image: UIImage, video: Data, basePath: String = "") -> (String?, String?) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return (nil, nil)
        }
        
        let imageName = CoreDataImageService.saveImage(image: image, basePath: basePath)
        let videoName = saveVideo(videoData: video, basePath: basePath)
        
        if let imageName = imageName, let videoName = videoName {
            guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
                os_log("Could not create entity description.", log: OSLog(subsystem: subsystem, category: category), type: .error)
                return (nil, nil)
            }
            
            let newImageEntity = StoredVideo(entity: entity, insertInto: managedContext)
            newImageEntity.imageName = imageName
            newImageEntity.pathURL = videoName
            
            do {
                try managedContext.save()
                videos.append(Video(image: image, name: imageName))
                os_log("%@ was saved in a new object.", log: OSLog(subsystem: subsystem, category: category), type: .info, imageName)
            } catch let error as NSError {
                os_log("Could not save new image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
            }
        }
        
        return (videoName, imageName)
    }
    
    static func deleteImageObject(name: String, basePath: String) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
        _ = fetchImageObjectsInit(basePath: basePath)
        _ = fetchPathVideosObjectsInit(basePath: basePath)
        
        // Procura o objeto com o nome correspondente
        let fetchRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "imageName == %@", name)
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            guard let imageObjectToDelete = fetchResults.first else {
                os_log("No image object found with the given name.", log: OSLog(subsystem: subsystem, category: category), type: .error)
                return
            }
            
            if let imageName = imageObjectToDelete.imageName {
                CoreDataImageService.deleteImage(imageName: imageName)
            }
            
            if let videoName = imageObjectToDelete.pathURL {
                CoreDataImageService.deleteImage(imageName: videoName)
            }
            
            managedContext.delete(imageObjectToDelete)
            
            do {
                try managedContext.save()
                if let index = savedObjects.firstIndex(of: imageObjectToDelete) {
                    savedObjects.remove(at: index)
                }
                os_log("Image object was deleted.", log: OSLog(subsystem: subsystem, category: category), type: .info)
            } catch let error as NSError {
                os_log("Could not delete image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
            }
        } catch let error as NSError {
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
    }
    
    static func handleOldImage(basePath: String) -> Bool {
        countOccurrences(of: "@", in: basePath) < 2
    }
    
    static func countOccurrences(of character: Character, in string: String) -> Int {
        var count = 0
        for char in string {
            if char == character {
                count += 1
            }
        }
        return count
    }
    
    static let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    static func saveVideo(videoData: Data, basePath: String) -> String? {
        let date = String(Date.timeIntervalSinceReferenceDate)
        let videoName = basePath + date.replacingOccurrences(of: ".", with: "-") + ".mp4"

        let filePath = documentsPath.appendingPathComponent(videoName)
        do {
            try videoData.write(to: filePath)
            print("\(videoName) was saved at \(filePath).")
            return videoName
        } catch let error as NSError {
            print("\(videoName) could not be saved: \(error)")
            return nil
        }
    }
}
