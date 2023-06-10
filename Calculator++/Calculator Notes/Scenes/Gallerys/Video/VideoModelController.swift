//
//  ModelController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 11/04/20.
//

import Foundation
import UIKit
import CoreData

class VideoModelController {
    static let shared = VideoModelController()
    
    let entityName = "StoredVideo"
    
    private var savedObjects = [StoredVideo]()
    private var images = [UIImage]()
    private var pathURLs = [String]()
    
    private var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    init() {
        fetchImageObjects()
    }
    
    func fetchImageObjectsInit(basePath: String) -> [UIImage] {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return []
        }
        
        let imageObjectRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                guard let imageName = imageObject.imageName else {
                    continue
                }
                
                if imageName.contains(basePath)
                    && imageName.filter({ $0 == "@" }).count ==
                    basePath.filter({ $0 == "@" }).count {
                    
                    if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                        images.append(storedImage)
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
        
        return images
    }

    func fetchPathVideosObjectsInit() -> [String] {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return []
        }
        
        let videoObjectRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(videoObjectRequest)
            
            pathURLs.removeAll()
            
            for videoObject in savedObjects {
                if let path = videoObject.pathURL {
                    pathURLs.append(path)
                }
            }
        } catch let error as NSError {
            print("Could not fetch video objects: \(error)")
        }
        
        return pathURLs
    }

    func fetchImageObjects() {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return
        }
        
        let imageObjectRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                guard let imageName = imageObject.imageName else {
                    continue
                }
                
                if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                    images.append(storedImage)
                }
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
    }
    
    func saveImageObject(image: UIImage, video: Data, basePath: String) -> String? {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return nil
        }
        
        let imageName = ImageController.shared.saveImage(image: image, basePath: basePath)
        let videoName = ImageController.shared.saveVideo(image: video)
        
        if let imageName = imageName, let videoName = videoName {
            guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
                print("Could not create entity description.")
                return nil
            }
            
            let newImageEntity = StoredVideo(entity: entity, insertInto: managedContext)
            newImageEntity.imageName = imageName
            newImageEntity.pathURL = videoName
            
            do {
                try managedContext.save()
                images.append(image)
                print("\(imageName) was saved in a new object.")
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
        
        return videoName
    }
    
    func deleteImageObject(imageIndex: Int) {
        fetchImageObjects()
        fetchPathVideosObjects()
        
        guard images.indices.contains(imageIndex) && pathURLs.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else {
            print("Invalid image index.")
            return
        }
        
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return
        }
        
        let imageObjectToDelete = savedObjects[imageIndex]
        
        if let imageName = imageObjectToDelete.imageName {
            ImageController.shared.deleteImage(imageName: imageName)
        }
        
        if let videoName = imageObjectToDelete.pathURL {
            ImageController.shared.deleteImage(imageName: videoName)
        }
        
        managedContext.delete(imageObjectToDelete)
        
        do {
            try managedContext.save()
            savedObjects.remove(at: imageIndex)
            images.remove(at: imageIndex)
            pathURLs.remove(at: imageIndex)
            print("Image object was deleted.")
        } catch let error as NSError {
            print("Could not delete image object: \(error)")
        }
    }
    
    func fetchPathVideosObjects() {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return
        }
        
        let pathURLRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(pathURLRequest)
            
            pathURLs.removeAll()
            
            for imageObject in savedObjects {
                if let path = imageObject.pathURL {
                    pathURLs.append(path)
                }
            }
        } catch let error as NSError {
            print("Could not fetch path URLs: \(error)")
        }
    }
}
