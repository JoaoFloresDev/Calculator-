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

class ChangeIconViewController: UIViewController {
    lazy var modalTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.text = "Selecione o icone desejado"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return view
    }()

    func createIconImage(_ image: UIImage?, action: Selector) -> UIView {
        let view = UIView()
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        
        view.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        
        // Adiciona interatividade
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        imageView.addGestureRecognizer(tapGesture)

        return view
    }
    
    func setIcon(name: String) {
        let app = UIApplication.shared
        if #available(iOS 10.3, *) {
            if app.supportsAlternateIcons {
                app.setAlternateIconName(name, completionHandler: { (error) in
                    if error != nil {
                        print("error => \(String(describing: error?.localizedDescription))")
                    } else {
                        print("Changed Icon Sucessfully.")
                    }
                })
            }
        }
    }
    
    @objc func metodoExemplo() {
        setIcon(name: "Icon1")
    }
    
    @objc func metodoExemplo2() {
        setIcon(name: "Icon2")
    }
    
    @objc func metodoExemplo3() {
        setIcon(name: "Icon3")
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                createIconImage(UIImage(named: "Icon1"), action: #selector(metodoExemplo)),
                createIconImage(UIImage(named: "Icon2"), action: #selector(metodoExemplo2)),
                createIconImage(UIImage(named: "Icon3"), action: #selector(metodoExemplo3))
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    // Constants
    let defaultHeight: CGFloat = 240
    var currentContainerHeight: CGFloat = 460
    
    // Dynamic container constraint
    var containerViewHeightConstraint: Constraint?
    var containerViewBottomConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        // Adiciona um gesto de tap para fechar o modal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        // Adiciona um gesto de swipe para baixo
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    func setupView() {
        view.backgroundColor = .clear
    }
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(modalTitleView)
        
        modalTitleView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().offset(8)
            make.height.equalTo(44)
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerViewBottomConstraint = make.bottom.equalTo(view.snp.bottom).offset(defaultHeight).constraint
            containerViewHeightConstraint = make.height.equalTo(defaultHeight).constraint
        }
        
        containerView.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(modalTitleView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(containerView).inset(24)
        }
        
        // Activate constraints
        containerViewHeightConstraint?.activate()
        containerViewBottomConstraint?.activate()
    }
    
    @objc func handleSwipeDown(_ gesture: UISwipeGestureRecognizer) {
        animateDismissView()
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.update(offset: height)
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: 0)
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.update(offset: self.defaultHeight)
            self.view.layoutIfNeeded()
        }
    }
}
