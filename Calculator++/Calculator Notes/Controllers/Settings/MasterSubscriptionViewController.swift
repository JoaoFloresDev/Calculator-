//
//  MasterSubscriptionViewController.swift
//  Calculator Notes
//
//  Created by Lucio Bueno Vieira Junior on 14/01/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//

import UIKit
import StoreKit
import Purchases

class MasterSubscriptionViewController: UIViewController {
    //    MARK: - Variables
    var products: [SKProduct] = []
    var timerLoad: Timer!
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    //    MARK: - IBOutlets
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teste: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buttonBuy: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    //    MARK: - IBAction
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        PurchaseService.purchase(productId: "cn_1_1m") {
            self.startLoading()
            self.timerLoad = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.loadingPlaying), userInfo: nil, repeats: false)
            
            self.confirmCheckmark()
        }
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        RazeFaceProducts.store.restorePurchases()
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadingPlaying), userInfo: nil, repeats: false)
        confirmCheckmark()
    }
    
    //    MARK: - UI
    @objc func loadingPlaying() {
        stopLoading()
    }
    
    func confirmCheckmark() {
        DispatchQueue.main.async {
            Purchases.shared.purchaserInfo { (info, error) in
                // Check if user is subscribed
                if info?.entitlements["premium"]?.isActive == true {
                    self.stopLoading()
                    self.buyLabel.text = "   ✓✓✓"
                    UserDefaults.standard.set(true, forKey:"cn_1_1m")
                }
            }
        }
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MasterSubscriptionViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        
        confirmCheckmark()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        confirmCheckmark()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
        confirmCheckmark()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reload()
        confirmCheckmark()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let _ = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        confirmCheckmark()
    }
    //    MARK: - UI
    func startLoading() {
        loadingView.alpha = 1
        loadingView.startAnimating()
    }
    
    func stopLoading() {
        loadingView.alpha = 0
        loadingView.stopAnimating()
    }
    
    //    MARK: - Data Management
    @objc func reload() {
        products = []
        
        RazeFaceProducts.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products!
                
                DispatchQueue.main.async {
                    self.teste.text = self.products[0].localizedTitle
                    self.teste.textColor = UIColor.black
                    
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    self.descriptionLabel.textColor = UIColor.black
                    
                    MasterViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = MasterViewController.self.priceFormatter.string(from: self.products[0].price)! + " /month"
                    
                }
            }
            else {
                if products?[0] != nil {
                    self.teste.text = self.products[0].localizedTitle
                    self.teste.textColor = UIColor.black
                    
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    self.descriptionLabel.textColor = UIColor.black
                    
                    MasterViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = MasterViewController.self.priceFormatter.string(from: self.products[0].price)!
                }
            }
        }
        
        confirmCheckmark()
    }
}
