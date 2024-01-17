//
//  ChoiceViewController.swift
//  Calculator Notes
//
//  Created by mac on 1/12/24.
//  Copyright © 2024 MakeSchool. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class ChoiceViewController: UIViewController {
    
    weak var delegate: PurchaseViewControllerDelegate?
    
    // MARK: - Variables
    private var products: [SKProduct] = []
    private var timerLoad: Timer?
    
    @IBOutlet weak var monthly: UIButton!
    @IBOutlet weak var annual: UIButton!
    @IBOutlet weak var restore: UIButton!
    
    @IBOutlet weak var close: UIBarButtonItem!
    
    lazy var headerView = PurchaseHeaderView()
    lazy var purchaseBenetList = PurchaseBenetList()
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
    lazy var monthlyActionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 232/255.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.clipsToBounds = true
        button.setTitle(Text.monthlyPlanText.localized(), for: .normal)
        
        button.addTarget(self, action: #selector(didTapMonthly), for: .touchUpInside)
        return button
    }()
    
    lazy var yearlyActionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 232/255.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.clipsToBounds = true
        button.setTitle(Text.yearlyPlanText.localized(), for: .normal)
        
        button.addTarget(self, action: #selector(didTapYearly), for: .touchUpInside)
        return button
    }()
    
    lazy var restoreActionButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 232/255.0, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.clipsToBounds = true
        button.setTitle(Text.restore.localized(), for: .normal)
        
        button.addTarget(self, action: #selector(didTapRestore), for: .touchUpInside)
        return button
    }()
        
    override func viewDidLoad() {
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postNotification(named: "alertWillBePresented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        postNotification(named: "alertHasBeenDismissed")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadAndCheckPurchaseStatus()
    }
    
    // MARK: - Helper Methods
    private func setupObservers() {
        setupNotificationObserver()
    }
    
    private func postNotification(named name: String) {
        NotificationCenter.default.post(name: NSNotification.Name(name), object: nil)
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    @objc private func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String, products.contains(where: { $0.productIdentifier == productID }) else { return }
        confirmCheckmark()
    }
    
    private func reloadAndCheckPurchaseStatus() {
        reload()
        confirmCheckmark()
    }
    
    @objc private func reload() {
        products = []
        RazeFaceProducts.store.requestProducts { [weak self] success, products in
            guard let self = self, let products = products else { return }
            DispatchQueue.main.async {
                self.products = products
                self.updateUI(with: products.first)
                self.confirmCheckmark()
            }
        }
    }
    
    private func updateUI(with product: SKProduct?) {
        guard let product = product else { return }
        headerView.title.text  = "Adquira a versão premium"
        
        
        guard let monthlyProduct = products.filter({ $0.productIdentifier == "Calc.noads.mensal" }).first else {
            return
        }
        priceFormatter.locale = monthlyProduct.priceLocale
        monthlyActionButton.setTitle("\(monthlyProduct.localizedTitle) / \(priceFormatter.string(from: monthlyProduct.price) ?? "")", for: .normal)
        
        
        guard let yearlyProduct = products.filter({ $0.productIdentifier == "calcanual" }).first else {
            return
        }
        
        priceFormatter.locale = yearlyProduct.priceLocale
        yearlyActionButton.setTitle("\(yearlyProduct.localizedTitle) / \(priceFormatter.string(from: yearlyProduct.price) ?? "")", for: .normal)
        
    }
    
    func setupUI() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(56)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(monthlyActionButton)
        monthlyActionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.top.equalTo(headerView.snp.bottom).offset(255)
        }
        
        view.addSubview(yearlyActionButton)
        yearlyActionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.top.equalTo(headerView.snp.bottom).offset(325)
        }
        
        view.addSubview(restoreActionButton)
        restoreActionButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.top.equalTo(headerView.snp.bottom).offset(395)
        }
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func didTapRestore() {
        loadingAlert.startLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.loadingAlert.stopLoading()
            }
        }
        RazeFaceProducts.store.restorePurchases()
        confirmCheckmark()
    }
    
    @objc func didTapMonthly() {
        loadingAlert.startLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.loadingAlert.stopLoading()
            }
        }
        guard let product = products.filter({ $0.productIdentifier == "Calc.noads.mensal" }).first else {
            return
        }
        performPurchase(product: product)
    }
    
    @objc func didTapYearly() {
        loadingAlert.startLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.loadingAlert.stopLoading()
            }
        }
        guard let product = products.filter({ $0.productIdentifier == "calcanual" }).first else {
            return
        }
        performPurchase(product: product)
    }
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private func confirmCheckmark() {
        DispatchQueue.main.async {
            if RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") {
                self.monthlyActionButton.setTitle("✓✓✓", for: .normal)
                self.monthlyActionButton.backgroundColor  = .systemGreen
                self.monthlyActionButton.isUserInteractionEnabled = false
                Defaults.setBool(.montlyPlanPurchased, true)
                self.delegate?.purchased()
            }
            if RazeFaceProducts.store.isProductPurchased("calcanual") {
                self.yearlyActionButton.setTitle("✓✓✓", for: .normal)
                self.yearlyActionButton.backgroundColor  = .systemGreen
                self.yearlyActionButton.isUserInteractionEnabled = false
                Defaults.setBool(.yearlyPlanPurchased, true)
                self.delegate?.purchased()
            }
        }
    }
    
    private func performPurchase(product: SKProduct?) {
        guard let product = product else { return }
        RazeFaceProducts.store.buyProduct(product)
        confirmCheckmark()
    }
}

extension ChoiceViewController: PurchaseViewControllerDelegate {
    func purchased() {
        viewWillAppear(false)
    }
}
