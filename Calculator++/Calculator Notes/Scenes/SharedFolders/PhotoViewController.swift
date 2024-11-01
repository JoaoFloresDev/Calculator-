import UIKit
import SnapKit

class PhotoViewController: UIViewController {

    // MARK: - Constants
//    private let closeButtonText = Text.close
//    private let sharedPhotosTitle = "Shared Photos"
//    private let savePhotosButtonText = "Salvar fotos"
//    private let savePhotosErrorTitle = "Erro"
//    private let savePhotosErrorMessage = "Erro ao baixar a imagem:"
//    private let processImageErrorMessage = "Erro ao processar a imagem."
//    private let convertImageErrorMessage = "Erro ao converter a imagem para JPEG."
//    private let photosSavedTitle = "Fotos salvas"
//    private let photosSavedMessage = "Todas as fotos foram salvas na calculadora."
//    private let okActionText = "OK"

    // MARK: - Properties
    private var photoURLs: [URL]
    private var collectionView: UICollectionView!
    private var downloadButton: UIButton!

    init(photoURLs: [URL]) {
        self.photoURLs = photoURLs
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCloseButton()
        setupCollectionView()
        setupDownloadButton()
    }

    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
        title = Text.sharedPhotosTitle.localized()
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupCloseButton() {
        let closeButton = UIBarButtonItem(title: Text.close.localized(), style: .plain, target: self, action: #selector(closeViewController))
        navigationItem.rightBarButtonItem = closeButton
    }

    @objc private func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()

        let spacing: CGFloat = 10
        let itemWidth = (view.bounds.width - (4 * spacing)) / 3
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        let screenWidth = self.view.frame.size.width - 100
        let flowLayout = FlowLayout(screenWidth: screenWidth, sizeRate: 3)
        collectionView.collectionViewLayout = flowLayout
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
    }

    private func setupDownloadButton() {
        downloadButton = UIButton(type: .system)
        downloadButton.setTitle(Text.savePhotosButtonText.localized(), for: .normal)
        downloadButton.backgroundColor = .systemBlue
        downloadButton.tintColor = .white
        downloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        downloadButton.layer.cornerRadius = 8
        downloadButton.addTarget(self, action: #selector(downloadAllPhotos), for: .touchUpInside)
        view.addSubview(downloadButton)
        
        downloadButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }

    lazy var loadingAlert = LoadingAlert(in: self)
    
    @objc private func downloadAllPhotos() {
        loadingAlert.startLoading()
        let dispatchGroup = DispatchGroup()
        
        for url in photoURLs {
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        Alerts.showError(title: Text.savePhotosErrorTitle.localized(), text: "\(Text.savePhotosErrorMessage.localized()) \(error.localizedDescription)", controller: self) {
                            // Ação adicional se necessário após a exibição do erro
                        }
                    }
                    dispatchGroup.leave()
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        Alerts.showError(title: Text.savePhotosErrorTitle.localized(), text: Text.processImageErrorMessage.localized(), controller: self) {
                            // Ação adicional se necessário após a exibição do erro
                        }
                    }
                    dispatchGroup.leave()
                    return
                }
                
                DispatchQueue.main.async {
                    self.saveImageToLocal(image: image)
                    dispatchGroup.leave()
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.loadingAlert.stopLoading()
            self.dismiss(animated: true) {
                Alerts.showAlert(title: Text.photosSavedTitle.localized(), text: Text.photosSavedMessage.localized(), controller: self)
            }
        }
    }

    private func saveImageToLocal(image: UIImage) {
        guard let _ = UIImageJPEGRepresentation(image, 0.8) else {
            DispatchQueue.main.async {
                Alerts.showError(title: Text.savePhotosErrorTitle.localized(), text: Text.convertImageErrorMessage.localized(), controller: self) {
                    // Ação adicional se necessário após a exibição do erro
                }
            }
            return
        }
        ModelController.saveImageObject(image: image, basePath: "@")
    }

    private func showSuccessAlert() {
        let alertController = UIAlertController(title: Text.photosSavedTitle.localized(), message: Text.photosSavedMessage.localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: Text.savePhotosErrorTitle.localized(), message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.okActionText.localized(), style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let url = photoURLs[indexPath.item]
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "\(Text.savePhotosErrorMessage.localized()) \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: Text.processImageErrorMessage.localized())
                }
                return
            }
            
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        }.resume()
        
        return cell
    }
}

// MARK: - PhotoCell
class PhotoCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupShadow()
    }
    
    private func setupImageView() {
        imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
