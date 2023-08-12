import UIKit

struct BackupService {
    static func updateBackup() {
        CloudKitImageService.saveImages(names: CloudInsertionManager.getNames())
        CloudKitImageService.deleteImages(names: CloudDeletionManager.getNames())
    }
    
    static func hasDataInCloudKit(completion: @escaping (Bool, Error?, [(String, UIImage)]?) -> Void) {
        CloudKitImageService.fetchImages { items, error in
            if let error = error {
                completion(false, error, nil)
            } else {
                if let items = items, !items.isEmpty {
                    completion(true, nil, items)
                } else {
                    completion(false, nil, nil)
                }
            }
        }
    }
    
    static func restoreBackup(photos: [(String, UIImage)],
                              completion: @escaping (Bool, Error?) -> Void) {
        for photo in photos {
            ModelController.saveImageObject(image: photo.1, path: photo.0)
        }
        for photo in photos {
            if photo.0.filter({ $0 == "@" }).count > 1 {
                var outputArray = convertStringToArray(input: photo.0)
                outputArray.removeLast()
                var foldersService = FoldersService(type: .image)
                for index in 0..<outputArray.count {
                    let basePath = "@" + concatenateStringsUpToIndex(array: outputArray, index: index)
                    if !foldersService.checkAlreadyExist(folder: outputArray[index], basePath: basePath) {
                        foldersService.add(folder: outputArray[index], basePath: basePath)
                    }
                }
            }
        }
        
        completion(true, nil)
    }
    
    static func concatenateStringsUpToIndex(array: [String], index: Int) -> String {
        var result = ""
        for i in 0..<index {
            result += array[i]
        }
        return result
    }
    
    static func convertStringToArray(input: String) -> [String] {
        let components = input.components(separatedBy: "@")
        let filteredComponents = components.filter { !$0.isEmpty }
        return filteredComponents
    }
}
