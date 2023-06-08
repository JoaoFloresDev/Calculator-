import Foundation
import UIKit
import CoreData

class ModelController {
    static let shared = ModelController()
    
    let entityName = "StoredImage"
    
    var savedObjects = [NSManagedObject]()
    var images = [UIImage]()
    var managedContext: NSManagedObjectContext?
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("AppDelegate not found")
            return
        }
        managedContext = appDelegate.persistentContainer.viewContext
        
        fetchImageObjects()
    }
    
    func fetchImageObjects() {
        guard let managedContext = managedContext else {
            print("Managed context not found")
            return
        }
        
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard let imageName = savedImageObject.imageName else {
                        continue
                    }
                    if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                        images.append(storedImage)
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
    }
    
    func saveImageObject(image: UIImage, basePath: String) {
        guard let managedContext = managedContext else {
            print("Managed context not found")
            return
        }
        
        guard let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
            print("Failed to get entity description")
            return
        }
        
        let imageName = ImageController.shared.saveImage(image: image, basePath: basePath)
        
        if let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredImage {
            newImageEntity.imageName = imageName
            
            do {
                try managedContext.save()
                images.append(image)
                print("\(imageName ?? "") was saved in a new object.")
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
    }
    
    func deleteImageObject(imageIndex: Int) {
        guard images.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else {
            return
        }
        
        guard let managedContext = managedContext else {
            print("Managed context not found")
            return
        }
        
        guard let imageObjectToDelete = savedObjects[imageIndex] as? StoredImage,
              let imageName = imageObjectToDelete.imageName else {
            return
        }
        
        do {
            managedContext.delete(imageObjectToDelete)
            
            try managedContext.save()
            
            ImageController.shared.deleteImage(imageName: imageName)
            
            savedObjects.remove(at: imageIndex)
            images.remove(at: imageIndex)
            
            print("Image object was deleted.")
        } catch let error as NSError {
            print("Could not delete image object: \(error)")
        }
    }
    
    func fetchImageObjectsInit(basePath: String) -> [UIImage] {
        guard let managedContext = managedContext else {
            print("Managed context not found")
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard let imageName = savedImageObject.imageName else {
                        continue
                    }
                    if imageName.contains(basePath) && imageName.filter({ $0 == "@" }).count == basePath.filter({ $0 == "@" }).count {
                        if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                            images.append(storedImage)
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
        
        return images
    }
}
