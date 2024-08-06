import UIKit
import AVKit
import os.log

enum MediaItem {
    case image(name: String, data: UIImage)
    case video(name: String, data: Data)
}
