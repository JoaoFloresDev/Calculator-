import CloudKit
import UIKit

class CloudKitImageService: ObservableObject {
    private static let database = CKContainer(identifier: "iCloud.calculatorNotes").publicCloudDatabase
    
    static var images: [(String, UIImage)] = []
    
    static let recordTypeIdentifier = "ImageItem"
    struct RecordKeys {
        static let name = "name"
        static let image = "image"
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
        let query = CKQuery(recordType: recordTypeIdentifier, predicate: PredicateFormats.alwaysTrue)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let records = records {
                var fetchedImages = [(String, UIImage)]()
                
                for record in records {
                    if let imageName = record[RecordKeys.name] as? String,
                       let imageAsset = record[RecordKeys.image] as? CKAsset,
                       let imageData = try? Data(contentsOf: imageAsset.fileURL),
                       let image = UIImage(data: imageData) {
                        fetchedImages.append((imageName, image))
                    }
                }
                
                DispatchQueue.main.async {
                    images = fetchedImages
                    print("! \(fetchedImages) !")
                    completion(fetchedImages, nil)
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
    
    static func deleteImages(names: [String]) {
        for name in names {
            deleteImage(name: name) { success, error in
                if success && error == nil {
                    NameManager.deleteName(name)
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
}
