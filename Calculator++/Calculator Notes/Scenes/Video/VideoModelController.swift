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

//class VideoModelController {
//    static let shared = VideoModelController()
//
//    let entityName = "StoredVideo"
//
//    var savedObjects = [NSManagedObject]()
//    var images = [UIImage]()
//    var PathURL = [String]()
//
//    var managedContext: NSManagedObjectContext!
//
//    init() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        managedContext = appDelegate.persistentContainer.viewContext
//
//        fetchImageObjects()
//    }
//
//    func fetchImageObjects() {
//        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//        do {
//            savedObjects = try managedContext.fetch(imageObjectRequest)
//
//            images.removeAll()
//
//            for imageObject in savedObjects {
//                let savedImageObject = imageObject as? StoredVideo
//
//                guard savedImageObject?.imageName != nil else { return }
//                if let imageName = savedImageObject?.imageName,
//                   let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
//                    images.append(storedImage)
//                }
//            }
//        } catch let error as NSError {
//            print("Could not return image objects: \(error)")
//        }
//    }
//
//    func saveImageObject(image: UIImage, video: NSData) -> String? {
//        let imageName = ImageController.shared.saveImage(image: image, basePath: String())
//        let videoName = ImageController.shared.saveVideo(image: video as Data)
//        if let imageName = imageName {
//            guard let coreDataEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return nil}
//            let newImageEntity = NSManagedObject(entity: coreDataEntity, insertInto: managedContext) as? StoredVideo
//            newImageEntity?.imageName = imageName
//            newImageEntity?.pathURL = videoName
//
//            do {
//                try managedContext.save()
//                images.append(image)
//                print("\(imageName) was saved in new object.")
//            } catch let error as NSError {
//                print("Could not save new image object: \(error)")
//            }
//        }
//        return videoName
//    }
//
//    func deleteImageObject(imageIndex: Int) {
//        fetchImageObjects()
//        fetchPathVideosObjects()
//
//        print(images.indices.contains(imageIndex))
//        print(PathURL.indices.contains(imageIndex))
//        print(savedObjects.indices.contains(imageIndex))
//
//        guard images.indices.contains(imageIndex) && PathURL.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else { return }
//
//        guard let imageObjectToDelete = savedObjects[imageIndex] as? StoredVideo else { return }
//
//        let imageName = imageObjectToDelete.imageName
//        let videoName = imageObjectToDelete.pathURL
//
//        do {
//            managedContext.delete(imageObjectToDelete)
//
//            try managedContext.save()
//
//            if let imageName = imageName {
//                ImageController.shared.deleteImage(imageName: imageName)
//            }
//
//            if let videoName = videoName {
//                ImageController.shared.deleteImage(imageName: videoName)
//            }
//
//            savedObjects.remove(at: imageIndex)
//
//            images.remove(at: imageIndex)
//            PathURL.remove(at: imageIndex)
//
//            print("Image object was deleted.")
//        } catch let error as NSError {
//            print("Could not delete image object: \(error)")
//        }
//    }
//
//    func fetchImageObjectsInit() -> [UIImage]{
//        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//        do {
//            savedObjects = try managedContext.fetch(imageObjectRequest)
//
//            images.removeAll()
//
//            for imageObject in savedObjects {
//                let savedImageObject = imageObject as? StoredVideo
//
//                guard savedImageObject?.imageName != nil else { return []}
//
//                if let imageName = savedImageObject?.imageName,
//                   let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
//                    images.append(storedImage)
//                }
//            }
//        } catch let error as NSError {
//            print("Could not return image objects: \(error)")
//        }
//        return images
//    }
//
//    func fetchPathVideosObjects(){
//        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//        do {
//            savedObjects = try managedContext.fetch(imageObjectRequest)
//
//            PathURL.removeAll()
//
//            for imageObject in savedObjects {
//                let savedImageObject = imageObject as? StoredVideo
//
//                if let path = savedImageObject?.pathURL {
//                    PathURL.append(path)
//                }
//            }
//        } catch let error as NSError {
//            print("Could not return image objects: \(error)")
//        }
//    }
//
//    func fetchPathVideosObjectsInit() -> [String]{
//        let imageObjectRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//
//        do {
//            savedObjects = try managedContext.fetch(imageObjectRequest)
//
//            PathURL.removeAll()
//
//            for imageObject in savedObjects {
//                let savedImageObject = imageObject as? StoredVideo
//
//                if let path = savedImageObject?.pathURL {
//                    PathURL.append(path)
//                }
//            }
//        } catch let error as NSError {
//            print("Could not return image objects: \(error)")
//        }
//        return PathURL
//    }
//}

class VideoModelController {
    static let shared = VideoModelController()
    
    let entityName = "StoredVideo"
    
    var savedObjects = [StoredVideo]()
    var images = [UIImage]()
    var pathURLs = [String]()
    
    var managedContext: NSManagedObjectContext?
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedContext = appDelegate.persistentContainer.viewContext
        
        fetchImageObjects()
    }
    
    func fetchImageObjectsInit() -> [UIImage] {
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
                
                if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                    images.append(storedImage)
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
    
    func saveImageObject(image: UIImage, video: NSData) -> String? {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return nil
        }
        
        let imageName = ImageController.shared.saveImage(image: image, basePath: "")
        let videoName = ImageController.shared.saveVideo(image: video as Data)
        
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

