import Foundation
import CloudKit

class CloudKitMediaService {

    static let database = CKContainer.default().privateCloudDatabase
    static let recordTypeIdentifier = "MediaItem"

    struct RecordKeys {
        static let name = "name"
        static let media = "media"
        static let mediaType = "mediaType"
    }

    enum MediaType: String {
        case image
        case video
    }

    enum PredicateFormats {
        static let alwaysTrue = NSPredicate(value: true)
    }

    static func saveMedia(name: String, mediaType: MediaType, data: Data, completion: @escaping (Bool, Error?) -> Void) {
        let record = CKRecord(recordType: recordTypeIdentifier)
        record.setValue(name, forKey: RecordKeys.name)
        record.setValue(mediaType.rawValue, forKey: RecordKeys.mediaType)

        let tempDirectory = FileManager.default.temporaryDirectory
        let extensionType: String = mediaType == .image ? ".jpg" : ".mp4"

        let mediaFileURL = tempDirectory.appendingPathComponent(UUID().uuidString + extensionType)
        try? data.write(to: mediaFileURL)

        let mediaAsset = CKAsset(fileURL: mediaFileURL)
        record.setValue(mediaAsset, forKey: RecordKeys.media)

        database.save(record) { record, error in
            completion(record != nil, error)
        }
    }

    static func fetchMedia(completion: @escaping ([(String, Data, MediaType)]?, Error?) -> Void) {
        let query = CKQuery(recordType: recordTypeIdentifier, predicate: PredicateFormats.alwaysTrue)
        var fetchedItems: [(String, Data, MediaType)] = []

        database.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else {
                completion(nil, error)
                return
            }

            for record in records {
                if let itemName = record[RecordKeys.name] as? String,
                   let mediaTypeString = record[RecordKeys.mediaType] as? String,
                   let mediaType = MediaType(rawValue: mediaTypeString),
                   let mediaAsset = record[RecordKeys.media] as? CKAsset,
                   let mediaData = try? Data(contentsOf: mediaAsset.fileURL) {
                    fetchedItems.append((itemName, mediaData, mediaType))
                }
            }

            completion(fetchedItems, nil)
        }
    }

    static func deleteMedia(recordID: CKRecord.ID, completion: @escaping (Bool, Error?) -> Void) {
        database.delete(withRecordID: recordID) { deletedRecordID, error in
            completion(deletedRecordID != nil, error)
        }
    }

    static func mediaExists(name: String, completion: @escaping (Bool, CKRecord.ID?, Error?) -> Void) {
        let predicate = NSPredicate(format: "\(RecordKeys.name) == %@", name)
        let query = CKQuery(recordType: recordTypeIdentifier, predicate: predicate)

        database.perform(query, inZoneWith: nil) { records, error in
            if let record = records?.first {
                completion(true, record.recordID, nil)
            } else {
                completion(false, nil, error)
            }
        }
    }
}
