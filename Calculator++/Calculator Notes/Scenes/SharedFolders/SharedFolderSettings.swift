import UIKit
import FirebaseStorage
import SnapKit

class SharedFolderSettings: UIViewController, SecretLinkCellDelegate {
    private let stackView = UIStackView()
    private var cellTitles: [String] = Defaults.getStringArray(.secretLinks) ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupStackViewCells()
    }
    
    private func setupNavigationBar() {
        title = "Links ativos"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Fechar",
            style: .plain,
            target: self,
            action: #selector(closePressed)
        )
        
        navigationController?.navigationBar.barTintColor = .lightGray
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        stackView.axis = .vertical
        stackView.spacing = 12
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    private func setupStackViewCells() {
        for title in cellTitles {
            let cellView = SecretLinkCell(title: title)
            cellView.delegate = self // Define o delegate
            stackView.addArrangedSubview(cellView)
        }
    }
    
    @objc private func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SecretLinkCellDelegate
    
    func removeCell(withTitle title: String) {
        var updatedCellTitles = Defaults.getStringArray(.secretLinks) ?? []
        
        if let index = updatedCellTitles.firstIndex(of: title) {
            updatedCellTitles.remove(at: index)
            Defaults.setStringArray(.secretLinks, updatedCellTitles)
            
            cellTitles = updatedCellTitles
            stackView.arrangedSubviews[index].removeFromSuperview()
        }
    }

    
    func showDetails(withTitle title: String) {
        let folderId = title
            .replacingOccurrences(of: "secrets://shared_photos/", with: "")
            .replacingOccurrences(of: "@@", with: "")
        loadPhotosAndShowModal(folderId: folderId)
    }
    
    func loadPhotosAndShowModal(folderId: String) {
        let folderRef = Storage.storage().reference().child("shared_photos/\(folderId)")
        
        folderRef.listAll { result, error in
            if let error = error {
                print("Erro ao listar fotos: \(error.localizedDescription)")
                return
            }
            
            var photoURLs: [URL] = []
            let dispatchGroup = DispatchGroup()
            
            result?.items.forEach { item in
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        photoURLs.append(url)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                guard !photoURLs.isEmpty else {
//                    self.showAlert(message: "Link ou senha inválidos. Tente novamente.")
                    return
                }
                let photoViewController = PhotoViewController(photoURLs: photoURLs)
                self.present(photoViewController, animated: true)
            }
        }
    }
}
