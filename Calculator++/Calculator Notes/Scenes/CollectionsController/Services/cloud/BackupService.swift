import UIKit
import AVKit
import os.log

enum MediaItem {
    case image(name: String, data: UIImage)
    case video(name: String, data: Data)
}

struct BackupService {
    static func updateBackup(completion: @escaping (Bool) -> ()) {
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
    
    static func hasDataInCloudKit(completion: @escaping (Bool, Error?, [MediaItem]?) -> Void) {
        var imageItems: [(String, UIImage)]?
        var videoItems: [(String, Data)]?
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        CloudKitVideoService.fetchVideos { fetchedVideos, error in
            if let error = error {
                completion(false, error, nil)
                return
            }
            videoItems = fetchedVideos
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        CloudKitImageService.fetchImages { fetchedImages, error in
            if let error = error {
                completion(false, error, nil)
                return
            }
            imageItems = fetchedImages
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            var mediaItems: [MediaItem] = []
            
            if let imageItems = imageItems {
                for (name, image) in imageItems {
                    mediaItems.append(.image(name: name, data: image))
                }
            }
            
            if let videoItems = videoItems {
                for (name, data) in videoItems {
                    mediaItems.append(.video(name: name, data: data))
                }
            }
            
            if !mediaItems.isEmpty {
                completion(true, nil, mediaItems)
            } else {
                completion(false, nil, nil)
            }
        }
    }
    
    static func restoreBackup(items: [MediaItem]?, completion: @escaping (Bool, Error?) -> Void) {
        guard let items = items else {
            completion(false, nil) // ou alguma Error personalizada
            return
        }
        
        for item in items {
            switch item {
            case .image(let name, let image):
                ModelController.saveImageObject(image: image, path: name)
                
                if name.filter({ $0 == "@" }).count > 1 {
                    handleFolderCreation(path: name, type: .image)
                }
                
            case .video(let name, let data):
                getThumbnailImageFromVideoData(videoData: data) { thumbImage in
                    let result = VideoModelController.saveVideoObject(image: thumbImage ?? UIImage(), video: data)
                }
                
                if name.filter({ $0 == "@" }).count > 1 {
                    handleFolderCreation(path: name, type: .video)
                }
            }
        }
        
        completion(true, nil)
    }

    static func getThumbnailImageFromVideoData(videoData: Data, completion: @escaping (UIImage?) -> Void) {
        guard let tempURL = saveTempFile(videoData: videoData) else {
            completion(nil)
            return
        }
        
        let asset = AVURLAsset(url: tempURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(1, 60)
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let uiImage = UIImage(cgImage: cgImage)
            completion(uiImage)
        } catch {
            print("Erro ao gerar imagem do vídeo: \(error)")
            completion(nil)
        }
        
        // Remova o arquivo temporário, se necessário
        removeTempFile(url: tempURL)
    }
    
    private static func saveTempFile(videoData: Data) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        do {
            try videoData.write(to: tempURL)
            return tempURL
        } catch {
            print("Erro ao salvar arquivo temporário: \(error)")
            return nil
        }
    }
    
    private static func removeTempFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Erro ao remover arquivo temporário: \(error)")
        }
    }
    
    // Função auxiliar para lidar com a criação de pastas
    static func handleFolderCreation(path: String, type: FoldersService.AssetType) {
        var outputArray = convertStringToArray(input: path)
        outputArray.removeLast()
        var foldersService = FoldersService(type: type)
        for index in 0..<outputArray.count {
            let basePath = "@" + concatenateStringsUpToIndex(array: outputArray, index: index)
            if !foldersService.checkAlreadyExist(folder: outputArray[index], basePath: basePath) {
                foldersService.add(folder: outputArray[index], basePath: basePath)
            }
        }
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
