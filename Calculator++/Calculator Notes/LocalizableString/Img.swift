
enum Img: String {
    case diselectedIndicator
    case selectedIndicator
    case keyEmpty
    case keyCurrent
    case placeholderVideo
    case placeholderNotes
    case keyFill
    case folder
    case leftarrow
    case emptyGalleryIcon
    case emptyVideoIcon
    case premiumIcon
    case emptyNotesIcon
    case iconMrk
    case noads
    case videosupport
    case unlimited
    
    func name() -> String {
        self.rawValue
    }
}
