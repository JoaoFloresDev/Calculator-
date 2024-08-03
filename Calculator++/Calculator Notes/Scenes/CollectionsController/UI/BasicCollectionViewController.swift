//2
//  Created by Joao Victor Flores da Costa on 10/06/23.
//  Copyright © 2023 MakeSchool. All rights reserved.
//

import FirebaseAuth
import Foundation
import  UIKit

class BasicCollectionViewController: UICollectionViewController {
    let reuseIdentifier = "Cell"
    let folderReuseIdentifier = "FolderCell"
    var adsHandler: AdsHandler = AdsHandler()
    public var basePath = "@"
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var image: UIImage?
    var editLeftBarButtonItem: EditLeftBarButtonItem?
    var additionsRightBarButtonItem: AdditionsRightBarButtonItem?
    var foldersService = FoldersService(type: .image)

    var navigationTitle: String?
    
    var filesIsExpanded = false {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadSections(IndexSet(integer: 1))
            }
        }
    }
    
    typealias BarButtonItemDelegate = AdditionsRightBarButtonItemDelegate & EditLeftBarButtonItemDelegate
    
    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupCollectionViewLayout() {
        let screenWidth = self.view.frame.size.width - 100
        let flowLayout = FlowLayout(screenWidth: screenWidth)
        if basePath == Constants.deepSeparatorPath {
            flowLayout.headerReferenceSize = CGSize(width: screenWidth, height: 25)
        }
        collectionView?.collectionViewLayout = flowLayout
    }
    
    func setupNavigationItems(delegate: BarButtonItemDelegate) {
        self.navigationController?.setup()
        self.tabBarController?.setup()
        additionsRightBarButtonItem = AdditionsRightBarButtonItem(delegate: delegate)
        navigationItem.rightBarButtonItem = additionsRightBarButtonItem
        editLeftBarButtonItem = EditLeftBarButtonItem(basePath: basePath, delegate: delegate)
        navigationItem.leftBarButtonItem = editLeftBarButtonItem
    }
    
    func commonViewDidLoad() {
        setupCollectionViewLayout()
        
        collectionView?.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")
        collectionView?.register(FooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerView")
        
        if basePath != Constants.deepSeparatorPath {
            filesIsExpanded = true
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil && Auth.auth().currentUser?.email != nil
    }
    
    func commonViewWillAppear() {
        if isUserLoggedIn() {
            if let cloudImage = UIImage(systemName: "icloud.fill")?.withRenderingMode(.alwaysTemplate) {
                additionsRightBarButtonItem?.cloudButton.setImage(cloudImage, for: .normal)
            }
            additionsRightBarButtonItem?.cloudButton.tintColor = .systemBlue
        } else {
            if let cloudImage = UIImage(systemName: "exclamationmark.icloud")?.withRenderingMode(.alwaysTemplate) {
                additionsRightBarButtonItem?.cloudButton.setImage(cloudImage, for: .normal)
            }
            additionsRightBarButtonItem?.cloudButton.tintColor = .systemGray
        }
        
    }
}

extension BasicCollectionViewController: HeaderViewDelegate {
    func headerTapped(header: HeaderView) {
        filesIsExpanded.toggle()
        collectionView?.reloadSections(IndexSet(integer: 1))
    }
}

extension BasicCollectionViewController: BackupModalViewControllerDelegate {
    func enableBackupToggled(status: Bool) {
        if status {
            if let cloudImage = UIImage(systemName: "icloud.fill")?.withRenderingMode(.alwaysTemplate) {
                additionsRightBarButtonItem?.cloudButton.setImage(cloudImage, for: .normal)
            }
            additionsRightBarButtonItem?.cloudButton.tintColor = .systemBlue
        } else {
            if let cloudImage = UIImage(systemName: "exclamationmark.icloud")?.withRenderingMode(.alwaysTemplate) {
                additionsRightBarButtonItem?.cloudButton.setImage(cloudImage, for: .normal)
            }
            additionsRightBarButtonItem?.cloudButton.tintColor = .systemGray
        }
    }
}
