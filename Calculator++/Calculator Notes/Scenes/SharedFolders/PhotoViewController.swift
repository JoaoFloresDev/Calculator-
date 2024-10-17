import UIKit
import SnapKit

class PhotoViewController: UIViewController {

    private var photoURLs: [URL]
    private var collectionView: UICollectionView!
    private var downloadButton: UIButton!

    // Inicializador personalizado que aceita um array de URLs de fotos
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
        setupCollectionView()
        setupDownloadButton()
    }

    private func setupView() {
        view.backgroundColor = .white
        title = "Shared Photos"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()

        // Definindo espaçamento e largura das células
        let spacing: CGFloat = 10
        let itemWidth = (view.bounds.width - (4 * spacing)) / 3  // 3 fotos por linha, com espaçamento igual

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)

        // Usando SnapKit para configurar o layout
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60) // Para deixar espaço para o botão
        }
    }

    private func setupDownloadButton() {
        downloadButton = UIButton(type: .system)
        downloadButton.setTitle("Importar fotos", for: .normal)
        downloadButton.backgroundColor = .systemBlue
        downloadButton.tintColor = .white
        downloadButton.layer.cornerRadius = 8
        downloadButton.addTarget(self, action: #selector(downloadAllPhotos), for: .touchUpInside)
        view.addSubview(downloadButton)
        
        // Usando SnapKit para configurar o layout do botão
        downloadButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }

        @objc private func downloadAllPhotos() {
                for url in photoURLs {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.saveImageToLocal(image: image)
                            }
                        }
                    }.resume()
                }
            }

            private func saveImageToLocal(image: UIImage) {
                guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
                let fileName = UUID().uuidString + ".jpg"
                ModelController.saveImageObject(image: image, basePath: "@")
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
        
        // Baixar a imagem a partir da URL
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
        }.resume()
        
        return cell
    }
}

// MARK: - PhotoCell (UICollectionViewCell para exibir a imagem)
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
            make.edges.equalToSuperview() // Preencher toda a célula
        }
    }
    
    private func setupShadow() {
        // Adicionando sombra à célula
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
