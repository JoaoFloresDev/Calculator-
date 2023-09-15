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
            ImageCloudInsertionManager.addName(imageName)
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

    static func fetchImage(imageName: String) -> UIImage? {
        guard !imageName.isEmpty else {
            print("Erro: Nome da imagem é inválido ou vazio.")
            return nil
        }
        
        let imagePath = documentsPath.appendingPathComponent(imageName).path
        
        guard fileManager.fileExists(atPath: imagePath) else {
            print("Erro: A imagem não existe no caminho: \(imagePath)")
            return nil
        }
        
        if let imageData = UIImage(contentsOfFile: imagePath) {
            print("Carregando imagem do caminho:", imagePath)
            return imageData
        } else {
            print("Erro: UIImage não pôde ser criada.")
            return nil
        }
    }

    static func deleteImage(imageName: String)  -> Result<Void, Error> {
        let imagePath = documentsPath.appendingPathComponent(imageName)

        guard fileManager.fileExists(atPath: imagePath.path) else {
            print("Image does not exist at path: \(imagePath)")
            return .failure(NSError())
        }

        do {
            try fileManager.removeItem(at: imagePath)
            print("\(imageName) was deleted.")
            return .success(())
        } catch let error as NSError {
            print("Could not delete \(imageName): \(error)")
            return .failure(error)
        }
    }
}
