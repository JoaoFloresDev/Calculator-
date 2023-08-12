import CloudKit
import UIKit

class CloudKitService: ObservableObject {
    private static let dataBase = CKContainer(identifier: "iCloud.calculatorNotes").publicCloudDatabase
    
    static var items: [(String, UIImage)] = []
    
    static let recordTypeID = "ItemItem"
    struct RecordKeys {
        static let name = "name"
        static let userImage = "userImage"
    }
    
    struct PredicateFormats {
        static let nameEqual = "name == %@"
        static let alwaysTrue = NSPredicate(value: true)
    }
    
    struct Notifications {
        static let itemSaved = "Item saved"
        static let errorSavingItem = "Error saving item:"
        static let errorFetchingItems = "Error fetching items:"
        static let errorDeletingItem = "Error deleting item:"
        static let itemDeleted = "Item deleted:"
        static let userExists = "Usuário com o nome já existe."
        static let success = "sucesso!"
        static let errorVerifyingUser = "Erro ao verificar existência do usuário:"
        static let itemsDeleted = "Items deleted:"
    }
    
    static func saveItem(name: String, userImage: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let record = CKRecord(recordType: recordTypeID)
        record.setValue(name, forKey: RecordKeys.name)
        
        if let imageData = UIImageJPEGRepresentation(userImage, 0.8) {
            let tempDirectory = FileManager.default.temporaryDirectory
            let imageFileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? imageData.write(to: imageFileURL)
            
            let imageAsset = CKAsset(fileURL: imageFileURL)
            record.setValue(imageAsset, forKey: RecordKeys.userImage)
        }
        
        dataBase.save(record) { record, error in
            if record != nil, error == nil {
                print(Notifications.itemSaved)
                completion(true, nil)
            } else {
                print(Notifications.errorSavingItem, error.debugDescription)
                completion(false, error)
            }
        }
    }
    
    static func fetchItems(completion: @escaping ([(String, UIImage)]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeID, predicate: PredicateFormats.alwaysTrue)
        
        dataBase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let records = records {
                var fetchedItems = [(String, UIImage)]()
                
                for record in records {
                    if let itemName = record[RecordKeys.name] as? String,
                       let imageAsset = record[RecordKeys.userImage] as? CKAsset,
                       let imageData = try? Data(contentsOf: imageAsset.fileURL),
                       let userImage = UIImage(data: imageData) {
                        fetchedItems.append((itemName, userImage))
                    }
                }
                
                DispatchQueue.main.async {
                    items = fetchedItems
                    print("! \(fetchedItems) !")
                    completion(fetchedItems, nil)
                }
            }
        }
    }
    
    static func deleteItem(name: String, completion: @escaping (Bool, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeID, predicate: NSPredicate(format: PredicateFormats.nameEqual, name))
        
        dataBase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("\(Notifications.errorFetchingItems) \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let recordToDelete = records?.first {
                dataBase.delete(withRecordID: recordToDelete.recordID) { recordID, error in
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
    
    static func userExists(withName name: String, completion: @escaping (Bool, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeID, predicate: NSPredicate(format: PredicateFormats.nameEqual, name))
        
        dataBase.perform(query, inZoneWith: nil) { records, error in
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
    
    static func updateBackup() {
        addNewPhotos()
        deletePhotos(nameList: NameManager.getNames())
    }
    
    static func deletePhotos(nameList: [String]) {
        for name in nameList {
            deleteItem(name: name) { success, error in
                if success && error == nil {
                    NameManager.deleteName(name)
                }
            }
        }
    }
    
    static func addNewPhotos() {
        let photos = ModelController.listAllPhotos()
        for photo in photos {
            CloudKitService.userExists(withName: photo.name) { exists, error in
                if let error = error {
                    print("\(Notifications.errorVerifyingUser) \(error.localizedDescription)")
                    return
                }
                if exists {
                    print(Notifications.userExists)
                } else {
                    CloudKitService.saveItem(name: photo.name, userImage: photo.image) { success, error in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        print(Notifications.success)
    }
    
    static func deleteAllItems(completion: @escaping (Bool, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeID, predicate: PredicateFormats.alwaysTrue)
        
        dataBase.perform(query, inZoneWith: nil) { records, error in
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
                        print(Notifications.itemsDeleted)
                        completion(true, nil)
                    }
                }
                dataBase.add(operation)
            }
        }
    }
}
