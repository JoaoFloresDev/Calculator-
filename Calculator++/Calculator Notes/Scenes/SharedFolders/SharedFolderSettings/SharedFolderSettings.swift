import UIKit
import FirebaseStorage
import SnapKit

class SharedFolderSettings: UIViewController, SecretLinkCellDelegate {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let tutorialView = TutorialView()
    private let limitMessageLabel = UILabel()
    private var cellTitles: [String] = Defaults.getStringArray(.secretLinks) ?? []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupStackViewCells()
        showTutorialIfNeeded()
        updateLimitMessageVisibility()
    }
    
    private func setupNavigationBar() {
        title = cellTitles.isEmpty ? Text.secureSharing.localized() : Text.activeLinks.localized()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePressed)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGray6
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Adicionando views na ordem desejada
        contentView.addSubview(tutorialView)
        contentView.addSubview(limitMessageLabel)
        contentView.addSubview(stackView)
        
        tutorialView.isHidden = true
        tutorialView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        limitMessageLabel.text = Text.limitMessage.localized()
        limitMessageLabel.numberOfLines = 0
        limitMessageLabel.font = UIFont.systemFont(ofSize: 14)
        limitMessageLabel.textColor = .red
        limitMessageLabel.textAlignment = .center
        limitMessageLabel.isHidden = true
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupStackViewCells() {
        stackView.addArrangedSubview(limitMessageLabel)
        for title in cellTitles {
            let cellView = SecretLinkCell(title: title)
            cellView.delegate = self
            stackView.addArrangedSubview(cellView)
        }
    }
    
    private func showTutorialIfNeeded() {
        tutorialView.isHidden = !cellTitles.isEmpty
    }
    
    private func updateLimitMessageVisibility() {
        limitMessageLabel.isHidden = cellTitles.count < 5
    }
    
    @objc private func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - SecretLinkCellDelegate
    func removeCell(withTitle title: String) {
        let alertController = UIAlertController(
            title: Text.deleteLinkConfirmationTitle.localized(),
            message: Text.deleteConfirmationMessage.localized(),
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: Text.deleteConfirmationCancel.localized(), style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: Text.deleteConfirmationDelete.localized(), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let folderId = title
                .replacingOccurrences(of: "secrets://shared_photos/", with: "")
                .replacingOccurrences(of: "@@", with: "")
            
            self.loadingAlert.startLoading {
                FirebasePhotoSharingService.deleteSharedFolderWithPhotos(folderId: folderId) { error in
                    if let error = error {
                        self.loadingAlert.stopLoading {
                            Alerts.showGenericError(controller: self)
                        }
                        return
                    }
                    
                    self.loadingAlert.stopLoading {
                        var updatedCellTitles = Defaults.getStringArray(.secretLinks) ?? []
                        
                        if let index = updatedCellTitles.firstIndex(of: title) {
                            updatedCellTitles.remove(at: index)
                            Defaults.setStringArray(.secretLinks, updatedCellTitles)
                            self.cellTitles = updatedCellTitles
                            
                            self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                            self.setupStackViewCells()
                            self.showTutorialIfNeeded()
                            self.updateLimitMessageVisibility()
                        }
                    }
                }
            }
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDetails(withTitle title: String) {
        let folderId = title
            .replacingOccurrences(of: "secrets://shared_photos/", with: "")
            .replacingOccurrences(of: "@@", with: "")
        loadPhotosAndShowModal(folderId: folderId)
    }
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
    func loadPhotosAndShowModal(folderId: String) {
        let folderRef = Storage.storage().reference().child("shared_photos/\(folderId)")
        
        loadingAlert.startLoading {
            folderRef.listAll { result, error in
                if let error = error {
                    self.loadingAlert.stopLoading()
                    Alerts.showGenericError(controller: self)
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
                    self.loadingAlert.stopLoading {
                        guard !photoURLs.isEmpty else {
                            return
                        }
                        let photoViewController = PhotoViewController(photoURLs: photoURLs, fileID: folderId, hideDeleteButton: true)
                        let navigationController = UINavigationController(rootViewController: photoViewController)
                        self.present(navigationController, animated: true)
                    }
                }
            }
        }
    }
    
    func copyLink() {
        showSavedAnimation()
    }
    
    private func showSavedAnimation() {
        let savedLabel = UILabel()
        savedLabel.text = Text.linkCopied.localized()
        savedLabel.font = .boldSystemFont(ofSize: 16)
        savedLabel.textColor = .white
        savedLabel.textAlignment = .center
        savedLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        savedLabel.layer.cornerRadius = 10
        savedLabel.clipsToBounds = true
        
        view.addSubview(savedLabel)
        
        savedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        savedLabel.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            savedLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                savedLabel.alpha = 0
            }) { _ in
                savedLabel.removeFromSuperview()
            }
        }
    }
}
