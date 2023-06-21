//
//  ModelController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 11/04/20.
//  Copyright © 2020 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ModelController {
    static let shared = ModelController()
    
    let entityName = "StoredImage"
    
    var savedObjects = [NSManagedObject]()
    var images = [Photo]()
    var managedContext: NSManagedObjectContext!
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        managedContext = appDelegate.persistentContainer.viewContext
        
        fetchImageObjects()
    }
    
    func fetchImageObjects() {
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard savedImageObject.imageName != nil else { return }
                    if let imageName = savedImageObject.imageName,
                       let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                        images.append(Photo(name: imageName, image: storedImage))
                    }
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
    }
    
    func saveImageObject(image: UIImage, basePath: String) -> Photo? {
        let imageName = ImageController.shared.saveImage(image: image, basePath: basePath)
        
        if let imageName = imageName,
           let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext){
            let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredImage
            newImageEntity?.imageName = imageName
            do {
                try managedContext.save()
                images.append(Photo(name: imageName, image: image))
                print("\(imageName) was saved in new object.")
                return Photo(name: imageName, image: image)
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
        return nil
    }

    func deleteImageObject(name: String) {
        fetchImageObjects()
        
        // Procura o objeto de imagem com o nome fornecido
        if let imageObjectToDelete = savedObjects.first(where: { ($0 as? StoredImage)?.imageName == name }) as? StoredImage {
            let imageIndex = savedObjects.firstIndex(of: imageObjectToDelete)
            
            do {
                // Exclui o objeto de imagem do contexto gerenciado
                managedContext.delete(imageObjectToDelete)
                
                // Salva as alterações no contexto
                try managedContext.save()
                
                // Exclui a imagem associada ao objeto
                if let imageName = imageObjectToDelete.imageName {
                    ImageController.shared.deleteImage(imageName: imageName)
                }
                
                // Remove o objeto de imagem e a foto associada da matriz
                if let index = imageIndex {
                    savedObjects.remove(at: index)
                    images.remove(at: index)
                }
                
                print("Image object was deleted.")
            } catch let error as NSError {
                print("Could not delete image object: \(error)")
            }
        }
    }

    
    func deleteImageObject(imageIndex: Int) {
        fetchImageObjects()
        
        guard images.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else { return }
        
        guard let imageObjectToDelete = savedObjects[imageIndex] as? StoredImage else { return }
        
        let imageName = imageObjectToDelete.imageName
        
        do {
            managedContext.delete(imageObjectToDelete)
            
            try managedContext.save()
            
            if let imageName = imageName {
                ImageController.shared.deleteImage(imageName: imageName)
            }
            
            savedObjects.remove(at: imageIndex)
            images.remove(at: imageIndex)
            
            print("Image object was deleted.")
        } catch let error as NSError {
            print("Could not delete image object: \(error)")
        }
    }
    
    func fetchImageObjectsInit(basePath: String) -> [Photo] {
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard let imageName = savedImageObject.imageName else { return []}
                    if handleNewImage(basePath: basePath, imageName: imageName) ||
                        handleOldImage(basePath: basePath, imageName: imageName) {
                        
                        let storedImage = ImageController.shared.fetchImage(imageName: imageName)
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
    
    func handleNewImage(basePath: String, imageName: String) -> Bool {
        imageName.contains(basePath) && samePathDeep(basePath: basePath, imageName: imageName)
    }
    
    func samePathDeep(basePath: String, imageName: String) -> Bool {
        imageName.filter({ $0 == "@" }).count == basePath.filter({ $0 == "@" }).count
    }
    
    func handleOldImage(basePath: String, imageName: String) -> Bool {
        basePath == "@" && imageName.first != "@"
    }
}
