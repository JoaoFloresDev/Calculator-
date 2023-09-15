import UIKit

struct BackupService {
    static func updateBackup(completion: @escaping (Bool) -> ()) {
        print(VideoCloudDeletionManager.getNames())
        print(VideoCloudInsertionManager.getNames())
        
        for name in VideoCloudInsertionManager.getNames() {
            switch getVideoData(videoPath: name) {
            case .success(let videoData):
                CloudKitVideoService.saveVideo(name: name, videoData: videoData) { success, error in
                    VideoCloudInsertionManager.deleteName(name)
                }
            case .failure(let error):
                print("deu erro")
            }
        }
        
        for name in VideoCloudDeletionManager.getNames() {
            CloudKitVideoService.deleteVideoByName(name: name) { success, error in
                if success {
                    VideoCloudDeletionManager.deleteName(name)
                }
            }
        }
        
        let group = DispatchGroup()
        var saveSuccess = false
        var deleteSuccess = false

        group.enter()
        CloudKitImageService.saveImages(names: ImageCloudInsertionManager.getNames()) { success in
            saveSuccess = success
            group.leave()
        }

        group.enter()
        CloudKitImageService.deleteImages(names: ImageCloudDeletionManager.getNames()) { success in
            deleteSuccess = success
            group.leave()
        }

        group.notify(queue: .main) {
            completion(saveSuccess && deleteSuccess)
        }
    }

    static let fileManager = FileManager.default
    
    // Retorna o Data do vídeo com base no caminho fornecido
    static func getVideoData(videoPath: String) -> Result<Data, Error> {
        
        guard let path = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(videoPath) else {
            return .failure(NSError(domain: "Failed to retrieve video URL", code: 404, userInfo: nil))
        }
        
        do {
            let videoData = try Data(contentsOf: path)
            return .success(videoData)
        } catch let error {
            return .failure(error)
        }
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
