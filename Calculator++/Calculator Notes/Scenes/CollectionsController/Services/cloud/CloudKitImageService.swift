import CloudKit
import UIKit

class CloudKitImageService: ObservableObject {
    private static let identifier = "iCloud.calculatorNotes"
    private static let database = CKContainer(identifier: identifier).publicCloudDatabase
    
    static var images: [(String, UIImage)] = []
    
    static let recordTypeIdentifier = "Photos"
    
    struct RecordKeys {
        static let name = "name"
        static let image = "userImage"
    }
    
    struct PredicateFormats {
        static let nameEqual = "name == %@"
        static let alwaysTrue = NSPredicate(value: true)
    }
    
    static func saveImage(name: String, image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let record = CKRecord(recordType: recordTypeIdentifier)
        record.setValue(name, forKey: RecordKeys.name)
        
        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let tempDirectory = FileManager.default.temporaryDirectory
            let imageFileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? imageData.write(to: imageFileURL)
            
            let imageAsset = CKAsset(fileURL: imageFileURL)
            record.setValue(imageAsset, forKey: RecordKeys.image)
        }
        
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
    
    static func fetchImages(completion: @escaping ([(String, UIImage)]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeIdentifier,
                            predicate: PredicateFormats.alwaysTrue)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let records = records {
                var fetchedItems = [(String, UIImage)]()
                
                for record in records {
                    if let itemName = record[RecordKeys.name] as? String,
                       let imageAsset = record[RecordKeys.image] as? CKAsset,
                       let imageData = try? Data(contentsOf: imageAsset.fileURL),
                       let userImage = UIImage(data: imageData) {
                        fetchedItems.append((itemName, userImage))
                    }
                }
                
                DispatchQueue.main.async {
                    print("! \(fetchedItems) !")
                    completion(fetchedItems, nil)
                }
            }
        }
    }
    
    static func deleteImage(name: String, completion: @escaping (Bool, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeIdentifier, predicate: NSPredicate(format: PredicateFormats.nameEqual, name))
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let recordToDelete = records?.first {
                database.delete(withRecordID: recordToDelete.recordID) { recordID, error in
                    if let error = error {
                        print("\(Notifications.errorDeletingItem) \(error.localizedDescription)")
                        completion(false, error)
                    } else {
                        print("\(Notifications.itemDeleted) \(recordID?.recordName ?? "Unknown")")
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    static func imageExists(withName name: String, completion: @escaping (Bool, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeIdentifier, predicate: NSPredicate(format: PredicateFormats.nameEqual, name))
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let records = records, !records.isEmpty {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    static func deleteImages(names: [String], completion: @escaping (Bool) -> ()) {
        var totalCompleted = 0
        var totalSuccess = 0
        
        if names.isEmpty {
            completion(true)
        }
        
        for name in names {
            deleteImage(name: name) { success, error in
                totalCompleted += 1
                
                if success && error == nil {
                    totalSuccess += 1
                    ImageCloudDeletionManager.deleteName(name)
                }
                
                if totalCompleted == names.count {
                    completion(totalSuccess == names.count)
                }
            }
        }
    }
    
    static func saveImages(names: [String], completion: @escaping (Bool) -> ()) {
        let serialQueue = DispatchQueue(label: "com.yourApp.saveImages")
        var totalCompleted = 0
        var totalSuccess = 0
        if names.isEmpty {
            completion(true)
        }
        for name in names {
            if let image = CoreDataImageService.fetchImage(imageName: name) {
                CloudKitImageService.saveImage(name: name, image: image) { success, error in
                    serialQueue.sync {
                        totalCompleted += 1
                        if success {
                            totalSuccess += 1
                        }
                        
                        ImageCloudInsertionManager.deleteName(name)
                        
                        if totalCompleted == names.count {
                            DispatchQueue.main.async {
                                completion(totalSuccess == names.count)
                            }
                        }
                    }
                }
            } else {
                serialQueue.sync {
                    totalCompleted += 1
                    if totalCompleted == names.count {
                        DispatchQueue.main.async {
                            completion(totalSuccess == names.count)
                        }
                    }
                }
            }
        }
    }


    
    static func deleteAllItems(completion: @escaping (Bool, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeIdentifier, predicate: PredicateFormats.alwaysTrue)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let recordsToDelete = records {
                let recordIDsToDelete = recordsToDelete.map { $0.recordID }
                
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsToDelete)
                operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    if let error = error {
                        print("\(Notifications.errorDeletingItem) \(error.localizedDescription)")
                        completion(false, error)
                    } else {
                        print(Notifications.imagesDeleted)
                        completion(true, nil)
                    }
                }
                database.add(operation)
            }
        }
    }
    
    static func isICloudEnabled(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { accountStatus, _ in
            switch accountStatus {
            case .available:
                if Defaults.getBool(.iCloudEnabled) {
                    completion(true)
                } else {
                    completion(false)
                }
            default:
                completion(false)
                Defaults.setBool(.iCloudEnabled, false)
            }
        }
    }
    
    static func enableICloudSync(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { accountStatus, error in
            guard accountStatus == .available else {
                completion(false)
                return
            }
            
            CKContainer(identifier: identifier).accountStatus { accountStatus, _ in
                guard accountStatus == .available else {
                    Defaults.setBool(.iCloudEnabled, false)
                    completion(false)
                    return
                }
                
                DispatchQueue.main.async {
                    Defaults.setBool(.iCloudEnabled, true)
                    completion(true)
                }
            }
        }
    }
    
    static func disableICloudSync(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { accountStatus, error in
            guard accountStatus == .available else {
                completion(false)
                return
            }
            
            CKContainer(identifier: identifier).accountStatus { accountStatus, _ in
                guard accountStatus == .available else {
                    completion(false)
                    return
                }
                
                DispatchQueue.main.async {
                    Defaults.setBool(.iCloudEnabled, false)
                    completion(true)
                }
            }
        }
    }
    
    static func redirectToICloudSettings() {
        if let url = URL(string: "App-prefs:root=CASTLE") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

