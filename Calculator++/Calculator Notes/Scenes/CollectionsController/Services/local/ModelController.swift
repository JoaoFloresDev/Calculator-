import Foundation
import UIKit
import CoreData
import os.log

struct ModelController {
    // MARK: - Properties
    private static let entityName = "StoredImage"
    private static var savedObjects = [NSManagedObject]()
    private static let subsystem = "com.example.calculatornotes"
    private static let category = "errors"

    private static var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }

    // MARK: - Fetching Methods
    static func listPhotosOf(basePath: String) -> [Photo] {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        var images = [Photo]()
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            images = savedObjects.compactMap { imageObject in
                guard let savedImageObject = imageObject as? StoredImage,
                      let imageName = savedImageObject.imageName else {
                    return nil
                }
                if handleNewImage(basePath: basePath, imageName: imageName) || handleOldImage(basePath: basePath) {
                    if let storedImage = CoreDataImageService.fetchImage(imageName: imageName) {
                        return Photo(name: imageName, image: storedImage)
                    }
                }
                return nil
            }
        } catch let error as NSError {
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        return images
    }
    
    static func listAllPhotos() -> [Photo] {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        var images = [Photo]()
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            images = savedObjects.compactMap { imageObject in
                guard let savedImageObject = imageObject as? StoredImage,
                      let imageName = savedImageObject.imageName,
                      let storedImage = CoreDataImageService.fetchImage(imageName: imageName) else {
                    return nil
                }
                return Photo(name: imageName, image: storedImage)
            }
        } catch let error as NSError {
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        return images
    }

    // MARK: - Saving Methods
    @discardableResult
    static func saveImageObject(image: UIImage, basePath: String) -> Photo? {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
        guard let imageName = CoreDataImageService.saveImage(image: image, basePath: basePath),
              let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
            os_log("Could not create entity description or save image.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
        let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredImage
        newImageEntity?.imageName = imageName
        
        do {
            try managedContext.save()
            ImageCloudInsertionManager.addName(imageName)
            os_log("%@ was saved in new object.", log: OSLog(subsystem: subsystem, category: category), type: .info, imageName)
            return Photo(name: imageName, image: image)
        } catch let error as NSError {
            os_log("Could not save new image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        return nil
    }

    // MARK: - Deleting Methods
    static func deleteImageObject(name: String, basePath: String) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
        listPhotosOf(basePath: basePath)
        
        if let imageObjectToDelete = savedObjects.first(where: { ($0 as? StoredImage)?.imageName == name }) as? StoredImage {
            let imageIndex = savedObjects.firstIndex(of: imageObjectToDelete)
            
            do {
                let imageName = imageObjectToDelete.imageName
                
                managedContext.delete(imageObjectToDelete)
                try managedContext.save()
                
                if let imageName = imageName {
                    let result = CoreDataImageService.deleteImage(imageName: imageName)
                    if case .success() = result {
                        ImageCloudDeletionManager.addName(imageName)
                    }
                }
                
                if let index = imageIndex {
                    savedObjects.remove(at: index)
                }
                
                os_log("Image object was deleted.", log: OSLog(subsystem: subsystem, category: category), type: .info)
            } catch let error as NSError {
                os_log("Could not delete image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
            }
        }
    }

    // MARK: - Helper Methods
    private static func handleNewImage(basePath: String, imageName: String) -> Bool {
        imageName.contains(basePath) && samePathDepth(basePath: basePath, imageName: imageName)
    }
    
    private static func samePathDepth(basePath: String, imageName: String) -> Bool {
        imageName.filter { $0 == "@" }.count == basePath.filter { $0 == "@" }.count
    }
    
    private static func handleOldImage(basePath: String) -> Bool {
        countOccurrences(of: "@", in: basePath) < 2
    }
    
    private static func countOccurrences(of character: Character, in string: String) -> Int {
        return string.filter { $0 == character }.count
    }
    
    @discardableResult
    static func saveImageObject(image: UIImage, path: String) -> Photo? {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
        guard let imageName = CoreDataImageService.saveImage(image: image, path: path),
              let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
            os_log("Could not create entity description or save image.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
        let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredImage
        newImageEntity?.imageName = imageName
        
        do {
            try managedContext.save()
            os_log("%@ was saved in new object.", log: OSLog(subsystem: subsystem, category: category), type: .info, imageName)
            return Photo(name: imageName, image: image)
        } catch let error as NSError {
            os_log("Could not save new image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        return nil
    }
}
