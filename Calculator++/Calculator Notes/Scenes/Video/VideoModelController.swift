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

class VideoModelController {
    static let shared = VideoModelController()
    
    let entityName = "StoredVideo"
    
    var savedObjects = [NSManagedObject]()
    var images = [UIImage]()
    var PathURL = [String]()
    
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
                let savedImageObject = imageObject as! StoredVideo
                
                guard savedImageObject.imageName != nil else { return }
                
                let storedImage = ImageController.shared.fetchImage(imageName: savedImageObject.imageName!)
                
                if let storedImage = storedImage {
                    images.append(storedImage)
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
    }
    
    func saveImageObject(image: UIImage, video: NSData) -> String? {
        //            saving image
        let imageName = ImageController.shared.saveImage(image: image)
        
        let videoName = ImageController.shared.saveVideo(image: video)
        
        if let imageName = imageName {
            let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
            let newImageEntity = NSManagedObject(entity: coreDataEntity!, insertInto: managedContext) as! StoredVideo
            
            newImageEntity.imageName = imageName
            newImageEntity.pathURL = videoName
            do {
                try managedContext.save()
                
                images.append(image)
                
                print("\(imageName) was saved in new object.")
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
        return videoName
    }
    
    
    
    func deleteImageObject(imageIndex: Int) {
        fetchImageObjects()
        fetchPathVideosObjects()
        
        print(images.indices.contains(imageIndex))
        print(PathURL.indices.contains(imageIndex))
        print(savedObjects.indices.contains(imageIndex))
        
        guard images.indices.contains(imageIndex) && PathURL.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else { return }
        
        let imageObjectToDelete = savedObjects[imageIndex] as! StoredVideo
        
        let imageName = imageObjectToDelete.imageName
        let videoName = imageObjectToDelete.pathURL
        
        do {
            managedContext.delete(imageObjectToDelete)
            
            try managedContext.save()
            
            if let imageName = imageName {
                ImageController.shared.deleteImage(imageName: imageName)
            }
            
            if let videoName = videoName {
                ImageController.shared.deleteImage(imageName: videoName)
            }
            
            savedObjects.remove(at: imageIndex)
            
            images.remove(at: imageIndex)
            PathURL.remove(at: imageIndex)
            
            print("Image object was deleted.")
        } catch let error as NSError {
            print("Could not delete image object: \(error)")
        }
    }
    
    func fetchImageObjectsInit() -> [UIImage]{
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            images.removeAll()
            
            for imageObject in savedObjects {
                let savedImageObject = imageObject as! StoredVideo
                
                guard savedImageObject.imageName != nil else { return []}
                
                let storedImage = ImageController.shared.fetchImage(imageName: savedImageObject.imageName!)
                
                if let storedImage = storedImage {
                    images.append(storedImage)
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
        return images
    }
    
    func fetchPathVideosObjects(){
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            PathURL.removeAll()
            
            for imageObject in savedObjects {
                let savedImageObject = imageObject as! StoredVideo
                
                if let path = savedImageObject.pathURL {
                    PathURL.append(path)
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
    }
    
    func fetchPathVideosObjectsInit() -> [String]{
        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            savedObjects = try managedContext.fetch(imageObjectRequest)
            
            PathURL.removeAll()
            
            for imageObject in savedObjects {
                let savedImageObject = imageObject as! StoredVideo
                
                if let path = savedImageObject.pathURL {
                    PathURL.append(path)
                }
            }
        } catch let error as NSError {
            print("Could not return image objects: \(error)")
        }
        return PathURL
    }
}
