import UIKit
import SnapKit
import Network
import Photos
import AssetsPickerViewController
import DTPhotoViewerController
import CoreData
import NYTPhotoViewer
import ImageViewer
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

class CustomLabelButtonView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    init(text: String, backgroundColor: UIColor) {
        super.init(frame: .zero)
        self.label.text = text
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 8
        self.setupView()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(label)
    }
    
    private func setupConstraints() {
        label.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    func setTapAction(target: Any?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(tapGesture)
    }
}
