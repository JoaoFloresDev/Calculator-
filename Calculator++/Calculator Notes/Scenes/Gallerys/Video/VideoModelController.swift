//
//  ModelController.swift
//  Calculator Notes
//
//  Created by Joao Flores on 11/04/20.
//

import Foundation
import UIKit
import CoreData
import os.log

struct Video {
    var image: UIImage
    var name: String
}

class VideoModelController {
    static let shared = VideoModelController()
    
    let entityName = "StoredVideo"
    
    private var savedObjects = [StoredVideo]()
    private var videos = [Video]()
    private var pathURLs = [String]()
    
    private var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    private let subsystem = "com.example.yourapp"
    private let category = "errors"
    
    init() {
        fetchImageObjects()
    }
    
    // MARK: - Fetching
    func fetchImageObjectsInit(basePath: String) -> [Video] {
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
                    
                    if let storedImage = ImageController.shared.fetchImage(imageName: imageName) {
                        videos.append(Video(image: storedImage, name: imageName))
                    }
                }
            }
        } catch let error as NSError {
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
        
        return videos
    }

    func fetchPathVideosObjectsInit(basePath: String) -> [String] {
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

    func fetchImageObjects() {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
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
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
    }
    
    // MARK: - Saving and Deleting
    func saveImageObject(image: UIImage, video: Data, basePath: String) -> (String?, String?) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return (nil, nil)
        }
        
        let imageName = ImageController.shared.saveImage(image: image, basePath: basePath)
        let videoName = ImageController.shared.saveVideo(image: video, basePath: basePath)
        
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

    
    func deleteImageObject(name: String) {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
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
                    fetchImageObjects()
                    fetchPathVideosObjects()
                }
                os_log("Image object was deleted.", log: OSLog(subsystem: subsystem, category: category), type: .info)
            } catch let error as NSError {
                os_log("Could not delete image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
            }
        } catch let error as NSError {
            os_log("Could not fetch image objects: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
    }
    
    func deleteImageObject(imageIndex: Int) {
        fetchImageObjects()
        fetchPathVideosObjects()
        
        guard videos.indices.contains(imageIndex) && pathURLs.indices.contains(imageIndex) && savedObjects.indices.contains(imageIndex) else {
            os_log("Invalid image index.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
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
            os_log("Image object was deleted.", log: OSLog(subsystem: subsystem, category: category), type: .info)
        } catch let error as NSError {
            os_log("Could not delete image object: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
    }
    
    func fetchPathVideosObjects() {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
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
            os_log("Could not fetch path URLs: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
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

extension VideoModelController {
    // MARK: - Helper Methods
    private func managedContextUnavailable() -> Bool {
        guard managedContext == nil else {
            return false
        }
        os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
        return true
    }
}

extension VideoModelController {
    // MARK: - Additional Functionality
    func clearAllData() {
        guard let managedContext = managedContext else {
            os_log("Managed context is nil.", log: OSLog(subsystem: subsystem, category: category), type: .error)
            return
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(batchDeleteRequest)
            savedObjects.removeAll()
            videos.removeAll()
            pathURLs.removeAll()
            os_log("All data was cleared.", log: OSLog(subsystem: subsystem, category: category), type: .info)
        } catch let error as NSError {
            os_log("Could not clear all data: %@", log: OSLog(subsystem: subsystem, category: category), type: .error, error.localizedDescription)
        }
    }
}
