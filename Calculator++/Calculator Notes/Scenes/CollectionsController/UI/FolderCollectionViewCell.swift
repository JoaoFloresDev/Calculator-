import UIKit

class FolderCollectionViewCell: UICollectionViewCell {
    //MARK: - PROPERTIES
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var checkmarkLabel: UILabel!
    
    var isSelectedCell: Bool = false {
        didSet {
            imageCell.alpha = isSelectedCell ? 0.5 : 1
            titleLabel.alpha = isSelectedCell ? 0.5 : 1
            checkmarkLabel.text = isSelectedCell ? "✓" : ""
        }
    }
    
    func setup(name: String) {
        imageCell.image = UIImage(named: "folder")
        titleLabel.text = name
    }
}
