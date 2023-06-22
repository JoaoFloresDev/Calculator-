//
//  ModelController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 11/04/20.
//

import Foundation
import UIKit
import CoreData

struct Video {
    var image: UIImage
    var name: String
}

class VideoModelController {
    static let shared = VideoModelController()
    
    let entityName = "StoredVideo"
    
    private var savedObjects = [StoredVideo]()
    private var videos = [Video]()
//    private var images = [UIImage]()
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
    
    // MARK: - Fetching
    func fetchImageObjectsInit(basePath: String) -> [Video] {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
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
                
                if imageName.contains(basePath)
                    && imageName.filter({ $0 == "@" }).count ==
                    basePath.filter({ $0 == "@" }).count {
                    
                    if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                        videos.append(Video(image: storedImage, name: imageName))
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
        
        return videos
    }

    func fetchPathVideosObjectsInit(basePath: String) -> [String] {
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
                    if path.contains(basePath)
                        && path.filter({ $0 == "@" }).count ==
                        basePath.filter({ $0 == "@" }).count {
                        pathURLs.append(path)
                    }
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
            
            videos.removeAll()
            
            for imageObject in savedObjects {
                guard let imageName = imageObject.imageName else {
                    continue
                }
                
                if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                    videos.append(Video(image: storedImage, name: imageName))
                }
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
    }
    
    // MARK: - Saving and Deleting
    func saveImageObject(image: UIImage, video: Data, basePath: String) -> (String?, String?) {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return (nil, nil)
        }
        
        let imageName = ImageController.shared.saveImage(image: image, basePath: basePath)
        let videoName = ImageController.shared.saveVideo(image: video, basePath: basePath)
        
        if let imageName = imageName, let videoName = videoName {
            guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
                print("Could not create entity description.")
                return (nil, nil)
            }
            
            let newImageEntity = StoredVideo(entity: entity, insertInto: managedContext)
            newImageEntity.imageName = imageName
            newImageEntity.pathURL = videoName
            
            do {
                try managedContext.save()
                videos.append(Video(image: image, name: imageName))
                print("\(imageName) was saved in a new object.")
            } catch let error as NSError {
                print("Could not save new image object: \(error)")
            }
        }
        
        return (videoName, imageName)
    }

    
    func deleteImageObject(name: String) {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return
        }
        
        // Procura o objeto com o nome correspondente
        let fetchRequest = NSFetchRequest<StoredVideo>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "imageName == %@", name)
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            
            guard let imageObjectToDelete = fetchResults.first else {
                print("No image object found with the given name.")
                return
            }
            
            if let imageName = imageObjectToDelete.imageName {
                ImageController.shared.deleteImage(imageName: imageName)
            }
            
            if let videoName = imageObjectToDelete.pathURL {
                ImageController.shared.deleteImage(imageName: videoName)
            }
            
            managedContext.delete(imageObjectToDelete)
            
            do {
                try managedContext.save()
                if let index = savedObjects.firstIndex(of: imageObjectToDelete) {
                    savedObjects.remove(at: index)
                    videos.remove(at: index)
                    pathURLs.remove(at: index)
                }
                print("Image object was deleted.")
            } catch let error as NSError {
                print("Could not delete image object: \(error)")
            }
        } catch let error as NSError {
            print("Could not fetch image objects: \(error)")
        }
    }
    
    func deleteImageObject(imageIndex: Int) {
        fetchImageObjects()
        fetchPathVideosObjects()
        
        guard videos.indices.contains(imageIndex) && pathURLs.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else {
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
            videos.remove(at: imageIndex)
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

extension VideoModelController {
    // MARK: - Helper Methods
    private func managedContextUnavailable() -> Bool {
        guard managedContext == nil else {
            return false
        }
        print("Managed context is nil.")
        return true
    }
}

extension VideoModelController {
    // MARK: - Additional Functionality
    func clearAllData() {
        guard let managedContext = managedContext else {
            print("Managed context is nil.")
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(batchDeleteRequest)
            savedObjects.removeAll()
            videos.removeAll()
            pathURLs.removeAll()
            print("All data was cleared.")
        } catch let error as NSError {
            print("Could not clear all data: \(error)")
        }
    }
}
