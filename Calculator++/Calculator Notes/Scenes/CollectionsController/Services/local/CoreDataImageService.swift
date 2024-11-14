import Foundation
import UIKit
import CoreData

struct CoreDataImageService {
    static let fileManager = FileManager.default
    static let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // MARK: - Save Image
    
    static func saveImage(image: UIImage, basePath: String) -> String? {
        let date = String(Date.timeIntervalSinceReferenceDate)
        let imageName = basePath + date.replacingOccurrences(of: ".", with: "-") + ".png"
        return saveImage(image: image, path: imageName)
    }
    
    static func saveImage(image: UIImage, path: String) -> String? {
        guard let imageData = UIImagePNGRepresentation(image) else {
            print("Could not convert UIImage to PNG data.")
            return nil
        }
        
        let filePath = documentsPath.appendingPathComponent(path)
        do {
            try imageData.write(to: filePath, options: .atomic)
            
            print("\(path) was saved.")
            return path
        } catch let error {
            print("\(path) could not be saved: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Fetch Image
    
    static func fetchImage(imageName: String) -> UIImage? {
        let filePath = documentsPath.appendingPathComponent(imageName).path
        guard fileManager.fileExists(atPath: filePath) else {
            print("Error: Image does not exist at path: \(filePath)")
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let image = UIImage(data: imageData) else {
            print("Error: Could not load image from path: \(filePath)")
            return nil
        }
        
        print("Loaded image from path:", filePath)
        return image
    }
    
    // MARK: - Delete Image
    
    static func deleteImage(imageName: String) -> Result<Void, Error> {
        let filePath = documentsPath.appendingPathComponent(imageName)
        guard fileManager.fileExists(atPath: filePath.path) else {
            print("Error: Image does not exist at path: \(filePath)")
            return .failure(NSError(domain: "CoreDataImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image not found"]))
        }
        
        do {
            try fileManager.removeItem(at: filePath)
            
            print("\(imageName) was deleted.")
            return .success(())
        } catch let error {
            print("Could not delete \(imageName): \(error.localizedDescription)")
            return .failure(error)
        }
    }
}
