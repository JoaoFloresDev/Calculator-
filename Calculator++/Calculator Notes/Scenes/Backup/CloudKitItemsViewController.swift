import UIKit
import CloudKit
import SnapKit
import AVFoundation

class CloudKitItemsViewController: UIViewController {
    private let closeBarButtonTitle = Text.close.localized()
    private let deleteItemTitle = Text.deleteFiles.localized()
    private let deleteActionTitle = Text.delete.localized()
    private let cancelActionTitle = Text.cancel.localized()
    private let navigationTitle = Text.myBackupItens.localized()
    
    private var viewModel = CloudKitImageService()
    lazy var alert = LoadingAlert(in: self)
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let numberOfItemsPerRow: CGFloat = 4
        let spacingBetweenCells: CGFloat = 12

        let totalSpacing = (2 * 12) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) // left + right + in-between items
        let width = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow

        layout.itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alert.startLoading()
        CloudKitImageService.fetchImages { _, _ in
            self.alert.stopLoading {
                self.collectionView.reloadData()
            }
            
            CloudKitVideoService.fetchVideos { fetchedItems, error in
                self.collectionView.reloadData()
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Registrar a classe da célula customizada
        collectionView.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "ItemCell")
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let closeButton = UIBarButtonItem(title: closeBarButtonTitle, style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.title = Text.backupNavigationTitle.localized()
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CloudKitItemsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return CloudKitImageService.images.count
            
        default:
            return CloudKitVideoService.videos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
            let (_, userImage) = CloudKitImageService.images[indexPath.row]
            cell.itemImageView.image = userImage
            cell.itemImageView.contentMode = .scaleAspectFit
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
            let (_, userImage) = CloudKitVideoService.videos[indexPath.row]
            cell.itemImageView.image = userImage
            cell.itemImageView.contentMode = .scaleAspectFit
            return cell
        }
    }
}

extension CloudKitItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            collectionView.deselectItem(at: indexPath, animated: true)
            let alertController = UIAlertController(title: Text.deleteFiles.localized(), message: String(), preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: Text.delete.localized(), style: .destructive) { _ in
                let (itemName, _) = CloudKitImageService.images[indexPath.row]
                self.alert.startLoading()
                CloudKitImageService.deleteImage(name: itemName) { success, error in
                    self.alert.stopLoading()
                    if success {
                        CloudKitImageService.fetchImages { _, _ in
                            self.collectionView.reloadData()
                        }
                    } else {
                        // Handle error here
                    }
                }
            }

            let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .cancel, handler: nil)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
            let alertController = UIAlertController(title: Text.deleteFiles.localized(), message: String(), preferredStyle: .alert)

            let deleteAction = UIAlertAction(title: Text.delete.localized(), style: .destructive) { _ in
                let (itemName, _) = CloudKitVideoService.videos[indexPath.row]
                self.alert.startLoading()
                CloudKitVideoService.deleteVideoByName(name: itemName) { success, error in
                    CloudKitVideoService.fetchVideos { success, error in
                        self.alert.stopLoading()
                        self.collectionView.reloadData()
                    }
                }
            }

            let cancelAction = UIAlertAction(title: Text.cancel.localized(), style: .cancel, handler: nil)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
        }
    }
}

class ItemCollectionViewCell: UICollectionViewCell {
    let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // ajusta o modo de conteúdo
        imageView.clipsToBounds = true // corta a imagem para preencher o espaço
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(itemImageView)
        
        itemImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionHeaderView: UICollectionReusableView {
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = Text.backupNavigationSubtitle.localized()
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
