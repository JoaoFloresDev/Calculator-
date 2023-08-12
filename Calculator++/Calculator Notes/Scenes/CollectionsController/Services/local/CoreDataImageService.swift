import Foundation
import UIKit
import CoreData

struct CoreDataImageService {
    static let fileManager = FileManager.default
    static let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    static func saveImage(image: UIImage, basePath: String) -> String? {
        let date = String(Date.timeIntervalSinceReferenceDate)
        let imageName = basePath + date.replacingOccurrences(of: ".", with: "-") + ".png"

        guard let imageData = UIImagePNGRepresentation(image) else {
            print("Could not convert UIImage to PNG data.")
            return nil
        }

        let filePath = documentsPath.appendingPathComponent(imageName)
        do {
            try imageData.write(to: filePath)
            print("\(imageName) was saved.")
            CloudInsertionManager.addName(imageName)
            return imageName
        } catch let error as NSError {
            print("\(imageName) could not be saved: \(error)")
            return nil
        }
    }
    
    static func saveImage(image: UIImage, path: String) -> String? {
        let imageName = path

        guard let imageData = UIImagePNGRepresentation(image) else {
            print("Could not convert UIImage to PNG data.")
            return nil
        }

        let filePath = documentsPath.appendingPathComponent(imageName)
        do {
            try imageData.write(to: filePath)
            print("\(imageName) was saved.")
            return imageName
        } catch let error as NSError {
            print("\(imageName) could not be saved: \(error)")
            return nil
        }
    }

    static func saveVideo(videoData: Data, basePath: String) -> String? {
        let date = String(Date.timeIntervalSinceReferenceDate)
        let videoName = basePath + date.replacingOccurrences(of: ".", with: "-") + ".mp4"

        let filePath = documentsPath.appendingPathComponent(videoName)
        do {
            try videoData.write(to: filePath)
            print("\(videoName) was saved at \(filePath).")
            return videoName
        } catch let error as NSError {
            print("\(videoName) could not be saved: \(error)")
            return nil
        }
    }

    static func fetchImage(imageName: String) -> UIImage? {
        let imagePath = documentsPath.appendingPathComponent(imageName).path
        print("Loading image from path:", imagePath)
        guard fileManager.fileExists(atPath: imagePath) else {
            print("Image does not exist at path: \(imagePath)")
            return nil
        }

        if let imageData = UIImage(contentsOfFile: imagePath) {
            return imageData
        } else {
            print("UIImage could not be created.")
            return nil
        }
    }

    static func deleteImage(imageName: String) {
        let imagePath = documentsPath.appendingPathComponent(imageName)

        guard fileManager.fileExists(atPath: imagePath.path) else {
            print("Image does not exist at path: \(imagePath)")
            return
        }

        do {
            try fileManager.removeItem(at: imagePath)
            print("\(imageName) was deleted.")
            CloudDeletionManager.addName(imageName)
        } catch let error as NSError {
            print("Could not delete \(imageName): \(error)")
        }
    }
}
