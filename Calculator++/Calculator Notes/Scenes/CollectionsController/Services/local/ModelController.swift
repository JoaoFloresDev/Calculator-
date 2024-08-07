import Foundation
import UIKit
import CoreData
import os.log

struct ModelController {
    private static let entityName = "StoredImage"
    private static var savedObjects = [NSManagedObject]()
    
    private static var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private static let subsystem = "com.example.calculatornotes"
    private static let category = "errors"
    
    static func listPhotosOf(basePath: String) -> [Photo] {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        var images = [Photo]()
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard let imageName = savedImageObject.imageName else { return []}
                    if handleNewImage(basePath: basePath, imageName: imageName) ||
                        handleOldImage(basePath: basePath) {
                        
                        let storedImage = CoreDataImageService.fetchImage(imageName: imageName)
                        if let storedImage = storedImage {
                            images.append(Photo(name: imageName, image: storedImage))
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
        return images
    }
    
    static func saveImageObject(image: UIImage, basePath: String) -> Photo? {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
        let imageName = CoreDataImageService.saveImage(image: image, basePath: basePath)
        
        if let imageName = imageName,
           let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext){
            let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredImage
            newImageEntity?.imageName = imageName
            do {
                try managedContext.save()
                print("\(imageName) was saved in new object.")
                return Photo(name: imageName, image: image)
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
        return nil
    }

    static func deleteImageObject(name: String, basePath: String) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
        _ = listPhotosOf(basePath: basePath)
        
        // Procura o objeto de imagem com o nome fornecido
        if let imageObjectToDelete = savedObjects.first(where: { ($0 as? StoredImage)?.imageName == name }) as? StoredImage {
            let imageIndex = savedObjects.firstIndex(of: imageObjectToDelete)
            
            do {
                let imageName = imageObjectToDelete.imageName
                
                // Exclui o objeto de imagem do contexto gerenciado
                managedContext.delete(imageObjectToDelete)
                
                // Salva as alterações no contexto
                try managedContext.save()
                
                // Exclui a imagem associada ao objeto
                if let imageName = imageName {
                    let result = CoreDataImageService.deleteImage(imageName: imageName)
                }
                // Remove o objeto de imagem e a foto associada da matriz
                if let index = imageIndex {
                    savedObjects.remove(at: index)
                }
                
                print("Image object was deleted.")
            } catch let error as NSError {
                print("Could not delete image object: \(error)")
            }
        }
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
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard let imageName = savedImageObject.imageName else { return []}
                    let storedImage = CoreDataImageService.fetchImage(imageName: imageName)
                    if let storedImage = storedImage {
                        images.append(Photo(name: imageName, image: storedImage))
                    }
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
        return images
    }
}

extension ModelController {
    private static func handleNewImage(basePath: String, imageName: String) -> Bool {
        imageName.contains(basePath) && samePathDeep(basePath: basePath, imageName: imageName)
    }
    
    private static func samePathDeep(basePath: String, imageName: String) -> Bool {
        imageName.filter({ $0 == "@" }).count == basePath.filter({ $0 == "@" }).count
    }
    
    private static func handleOldImage(basePath: String) -> Bool {
        countOccurrences(of: "@", in: basePath) < 2
    }
    
    private static func countOccurrences(of character: Character, in string: String) -> Int {
        var count = 0
        for char in string {
            if char == character {
                count += 1
            }
        }
        return count
    }
    
    @discardableResult
    static func saveImageObject(image: UIImage, path: String) -> Photo? {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
        let imageName = CoreDataImageService.saveImage(image: image, path: path)
        
        if let imageName = imageName,
           let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext){
            let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredImage
            newImageEntity?.imageName = imageName
            do {
                try managedContext.save()
                print("\(imageName) was saved in new object.")
                return Photo(name: imageName, image: image)
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
        return nil
    }
}
