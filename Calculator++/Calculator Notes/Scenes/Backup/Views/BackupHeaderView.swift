import UIKit
import SnapKit
import Network
import Photos
//import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
//import ImageViewer
import StoreKit
import GoogleMobileAds
import SceneKit
import simd
import Photos
import StoreKit
import Foundation
import AVFoundation
import AVKit
import CloudKit
import GoogleSignIn
import UIKit
import SnapKit

class BackupHeaderView: UIView {
    lazy var modalTitleView: UIView = {
        let label = UILabel()
        label.text = Text.backupSettings.localized()
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var modalSubtitleView: UILabel = {
        let label = UILabel()
        label.text = Text.backupNavigationSubtitle.localized()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        addSubview(modalTitleView)
        addSubview(modalSubtitleView)
    }
    
    private func setupConstraints() {
        modalTitleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        modalSubtitleView.snp.makeConstraints { make in
            make.top.equalTo(modalTitleView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
