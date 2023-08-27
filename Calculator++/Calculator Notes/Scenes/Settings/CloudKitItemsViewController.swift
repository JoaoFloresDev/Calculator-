import UIKit
import CloudKit
import SnapKit

class CloudKitItemsViewController: UIViewController {
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
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "As fotos são sincronizadas com sua galeria todas as vezes que seu app é aberto"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.backgroundColor = .systemGray6
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        alert.startLoading()
        CloudKitImageService.fetchImages { _, _ in
            self.alert.stopLoading {
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
        
        let closeButton = UIBarButtonItem(title: "Fechar", style: .plain, target: self, action: #selector(closeButtonTapped))
        closeButton.tintColor = .systemBlue
        navigationItem.leftBarButtonItem = closeButton
        
        navigationItem.title = "Meus itens no Backup"
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CloudKitItemsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CloudKitImageService.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
        let (_, userImage) = CloudKitImageService.images[indexPath.row]
        cell.itemImageView.image = userImage
        cell.itemImageView.contentMode = .scaleAspectFit
        return cell
    }
}

extension CloudKitItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let alertController = UIAlertController(title: "Delete Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
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

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension CloudKitItemsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! CollectionHeaderView
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100) // Ajuste a altura conforme necessário
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
        label.text = "As fotos são sincronizadas com sua galeria todas as vezes que o app é iniciado e existe conexão wifi"
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
