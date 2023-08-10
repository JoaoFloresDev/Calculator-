import Foundation
import UIKit
import CoreData

struct ImageController {
    static let shared = ImageController()
    private var cloudKitItemsViewModel = CloudKitItemsViewModel()
    
    let fileManager = FileManager.default
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    func saveImage(image: UIImage, basePath: String) -> String? {
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
            cloudKitItemsViewModel.saveItem(name: imageName, userImage: image) { saved, error in
                print("Response:")
                print(saved, error)
            }
            return imageName
        } catch let error as NSError {
            print("\(imageName) could not be saved: \(error)")
            return nil
        }
    }

    func saveVideo(videoData: Data, basePath: String) -> String? {
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

    func fetchImage(imageName: String) -> UIImage? {
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

    func deleteImage(imageName: String) {
        let imagePath = documentsPath.appendingPathComponent(imageName)

        guard fileManager.fileExists(atPath: imagePath.path) else {
            print("Image does not exist at path: \(imagePath)")
            return
        }

        do {
            try fileManager.removeItem(at: imagePath)
            print("\(imageName) was deleted.")
            cloudKitItemsViewModel.deleteItem(name: imageName) { saved, error in
                print("Response:")
                print(saved, error)
            }
        } catch let error as NSError {
            print("Could not delete \(imageName): \(error)")
        }
    }
}
