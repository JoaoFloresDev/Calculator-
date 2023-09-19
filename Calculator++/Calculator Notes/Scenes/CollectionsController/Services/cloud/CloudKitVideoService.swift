import CloudKit
import UIKit
import AVFoundation

class CloudKitVideoService: ObservableObject {
    private static let identifier = "iCloud.calculatorNotes"
    private static let database = CKContainer(identifier: identifier).publicCloudDatabase

    static var videos = [(String, UIImage)]()
    
    static let videoRecordTypeIdentifier = "Video"

    struct VideoRecordKeys {
        static let name = "name"
        static let video = "video"
    }
    
    struct PredicateFormats {
        static let nameEqual = "name == %@"
        static let alwaysTrue = NSPredicate(value: true)
    }
    
    static func saveVideo(name: String, videoData: Data, completion: @escaping (Bool, Error?) -> Void) {
        let record = CKRecord(recordType: videoRecordTypeIdentifier)
        record.setValue(name, forKey: VideoRecordKeys.name)
        
        // Salvando o vídeo
        let tempDirectory = FileManager.default.temporaryDirectory
        let videoFileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        try? videoData.write(to: videoFileURL)
        let videoAsset = CKAsset(fileURL: videoFileURL)
        record.setValue(videoAsset, forKey: VideoRecordKeys.video)
        
        database.save(record) { record, error in
            if record != nil, error == nil {
                print(Notifications.itemSaved)
                completion(true, nil)
            } else {
                print(Notifications.errorSavingItem, error.debugDescription)
                completion(false, error)
            }
        }
    }

    static func fetchVideos(completion: @escaping ([(String, UIImage)]?, Error?) -> Void) {
        let query = CKQuery(recordType: CloudKitVideoService.videoRecordTypeIdentifier, predicate: PredicateFormats.alwaysTrue)
        
        CloudKitVideoService.database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let records = records {
                var fetchedItems = [(String, UIImage)]()
                
                for record in records {
                    if let videoName = record[VideoRecordKeys.name] as? String,
                       let videoAsset = record[VideoRecordKeys.video] as? CKAsset,
                       let videoData = try? Data(contentsOf: videoAsset.fileURL) {
                        CloudKitVideoService.getThumbnailImageFromVideoData(videoData: videoData) { image in
                            guard let image = image else {
                                return
                            }
                            fetchedItems.append((videoName, image))
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.videos = fetchedItems
                    print("! \(fetchedItems) !")
                    completion(fetchedItems, nil)
                }
            }
        }
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
    
    static func deleteVideoByName(name: String, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(format: PredicateFormats.nameEqual, name)
        let query = CKQuery(recordType: videoRecordTypeIdentifier, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Erro ao buscar registros: \(error)")
                completion(false, error)
                return
            }
            
            guard let records = records, let record = records.first else {
                print("Nenhum registro encontrado")
                completion(false, nil)
                return
            }
            
            database.delete(withRecordID: record.recordID) { _, error in
                if let error = error {
                    print("Erro ao deletar registro: \(error)")
                    completion(false, error)
                } else {
                    print("Registro deletado com sucesso")
                    completion(true, nil)
                }
            }
        }
    }
    
    // Deletar um array de vídeos, dado o name
    static func deleteMultipleVideosByNames(names: [String], completion: @escaping (Bool, Error?) -> Void) {
        let group = DispatchGroup()
        var errorFound: Error?
        
        for name in names {
            group.enter()
            
            deleteVideoByName(name: name) { success, error in
                if !success {
                    errorFound = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = errorFound {
                print("Erro ao deletar um ou mais registros: \(error)")
                completion(false, error)
            } else {
                print("Todos os registros deletados com sucesso")
                completion(true, nil)
            }
        }
    }
}
