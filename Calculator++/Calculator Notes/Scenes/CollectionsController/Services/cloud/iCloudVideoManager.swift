import Foundation

class iCloudVideoManager {
    
    private var ubiquityContainerURL: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    // Função para salvar o vídeo no iCloud Drive
    func saveVideoToiCloud(with name: String, videoData: Data, completion: @escaping (Bool, Error?) -> ()) {
        guard let ubiquityContainerURL = ubiquityContainerURL else {
            completion(false, nil)
            return
        }
        
        let filePath = ubiquityContainerURL.appendingPathComponent("\(name).mp4")
        do {
            try videoData.write(to: filePath, options: .atomicWrite)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
    
    // Função para ler o vídeo do iCloud Drive
    func readVideoFromiCloud(with name: String, completion: @escaping (Data?, Error?) -> ()) {
        guard let ubiquityContainerURL = ubiquityContainerURL else {
            completion(nil, nil)
            return
        }
        
        let filePath = ubiquityContainerURL.appendingPathComponent("\(name).mp4")
        do {
            let videoData = try Data(contentsOf: filePath)
            completion(videoData, nil)
        } catch let error {
            completion(nil, error)
        }
    }
    
    // Função para deletar o vídeo do iCloud Drive
    func deleteVideoFromiCloud(with name: String, completion: @escaping (Bool, Error?) -> ()) {
        guard let ubiquityContainerURL = ubiquityContainerURL else {
            completion(false, nil)
            return
        }
        
        let filePath = ubiquityContainerURL.appendingPathComponent("\(name).mp4")
        do {
            try FileManager.default.removeItem(at: filePath)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }
}
