import UIKit

class FolderCollectionViewCell: UICollectionViewCell {
    //MARK: - PROPERTIES
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var checkmarkLabel: UILabel!
    
    var isInEditingMode = false
    
    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                imageCell.alpha = isSelected ? 0.5 : 1
                titleLabel.alpha = isSelected ? 0.5 : 1
                checkmarkLabel.text = isSelected ? "✓" : ""
            }
        }
    }
    
    func setup(name: String) {
        imageCell.image = UIImage(named: "folder")
        titleLabel.text = name
    }
}