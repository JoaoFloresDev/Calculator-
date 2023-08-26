import CloudKit

class CloudKitPasswordService {
    
    private static let database = CKContainer(identifier: "iCloud.calculatorNotes").publicCloudDatabase
    
    private struct RecordType {
        static let hasBackup = "HasBackup"
    }
    
    private struct RecordKeys {
        static let password = "password"
    }
    
    private struct ErrorMessarge {
        static let savePassword = "Error saving password:"
        static let fetchPassword = "Error fetching password:"
        static let deletePassword = "Error deleting password:"
        static let noPasswordFound = "No password found."
        static let cloudKitError = "CloudKit error:"
    }
    
    static func savePassword(password: String, completion: @escaping (Bool, Error?) -> Void) {
        let record = CKRecord(recordType: RecordType.hasBackup)
        record.setValue(password, forKey: RecordKeys.password)
        
        database.save(record) { record, error in
            if let error = error {
                print("Error fetching password:", error.localizedDescription)
                completion(false, error)
            } else {
                print("Password saved successfully.")
                completion(true, nil)
            }
        }
    }
    
    static func fetchAllPasswords(completion: @escaping ([String]?, Error?) -> Void) {
        let query = CKQuery(recordType: RecordType.hasBackup, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching passwords:", error.localizedDescription)
                completion(nil, error)
            } else if let passwordRecords = records {
                let passwords = passwordRecords.compactMap { record in
                    return record[RecordKeys.password] as? String
                }
                completion(passwords, nil)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    static func updatePassword(newPassword: String, completion: @escaping (Bool, Error?) -> Void) {
        deleteAllPasswords { success, error in
            if success {
                savePassword(password: newPassword) { success, error in
                    if success {
                        completion(true, nil)
                    } else if let error = error {
                        completion(false, error)
                    }
                }
            } else if let error = error {
                completion(false, error)
            }
        }
    }

    
    static func listAllPasswords(completion: @escaping ([String]?, Error?) -> Void) {
        let query = CKQuery(recordType: RecordType.hasBackup, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(nil, error)
            } else if let records = records {
                let passwords = records.compactMap { record in
                    return record[RecordKeys.password] as? String
                }
                completion(passwords, nil)
            } else {
                completion(nil, nil)
            }
        }
    }

    static func deleteAllPasswords(completion: @escaping (Bool, Error?) -> Void) {
        listAllPasswords { passwords, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let passwords = passwords else {
                completion(true, nil)
                return
            }
            
            let group = DispatchGroup()
            
            for password in passwords {
                group.enter()
                deletePassword(password: password) { success, error in
                    if let error = error {
                        completion(false, error)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(true, nil)
            }
        }
    }
    
    static func deletePassword(password: String, completion: @escaping (Bool, Error?) -> Void) {
        let predicate = NSPredicate(format: "\(RecordKeys.password) == %@", password)
        let query = CKQuery(recordType: RecordType.hasBackup, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            if let record = records?.first {
                let recordID = record.recordID
                
                database.delete(withRecordID: recordID) { _, error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        }
    }

}
