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
import os.log

class ModelController {
    static let shared = ModelController()
    
    let entityName = "StoredImage"
    
    var savedObjects = [NSManagedObject]()
    var images = [Photo]()
    
    private var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private let subsystem = "com.example.calculatornotes"
    private let category = "errors"
    
    // MARK: - Fetching
    func fetchImageObjectsInit(basePath: String) -> [Photo] {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                if let savedImageObject = imageObject as? StoredImage {
                    guard let imageName = savedImageObject.imageName else { return []}
                    if handleNewImage(basePath: basePath, imageName: imageName) ||
                        handleOldImage(basePath: basePath) {
                        
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
    
    func saveImageObject(image: UIImage, basePath: String) -> Photo? {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return nil
        }
        
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

    func deleteImageObject(name: String, basePath: String) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
        _ = fetchImageObjectsInit(basePath: basePath)
        
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
                    images.removeAll { $0.name == imageName }
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
    
    func handleNewImage(basePath: String, imageName: String) -> Bool {
        imageName.contains(basePath) && samePathDeep(basePath: basePath, imageName: imageName)
    }
    
    func samePathDeep(basePath: String, imageName: String) -> Bool {
        imageName.filter({ $0 == "@" }).count == basePath.filter({ $0 == "@" }).count
    }
    
    func handleOldImage(basePath: String) -> Bool {
        countOccurrences(of: "@", in: basePath) < 2
    }
    
    func countOccurrences(of character: Character, in string: String) -> Int {
        var count = 0
        for char in string {
            if char == character {
                count += 1
            }
        }
        return count
    }
}