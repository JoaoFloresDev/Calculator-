import UIKit
import StoreKit
import SnapKit

protocol PurchaseViewControllerDelegate: AnyObject {
    func purchased()
}

class PurchaseViewController: UIViewController {

    weak var delegate: PurchaseViewControllerDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet weak var customNavigator: UINavigationItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    lazy var loadingAlert = LoadingAlert(in: self)
    
    // MARK: - Variables
    private var products: [SKProduct] = []
    private var timerLoad: Timer?
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
        setupLocalizedText()
        setupUI()
    }
    
    lazy var headerView = PurchaseHeaderView()
    lazy var purchaseBenetList = PurchaseBenetList()
    
    lazy var monthlyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.clipsToBounds = true
        button.setTitle("Loading...", for: .normal)
        
        button.addTarget(self, action: #selector(didTapMonthlyButton), for: .touchUpInside)
        return button
    }()
    
    lazy var yearlyButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.clipsToBounds = true
        button.setTitle("Loading...", for: .normal)
        
        button.addTarget(self, action: #selector(didTabYearlyButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapMonthlyButton() {
        loadingAlert.startLoading()
        for p in products {
            if p.productIdentifier == "Calc.noads.mensal" {
                performPurchase(product: p)
            }
        }
        
    }
    
    @objc func didTabYearlyButton() {
        loadingAlert.startLoading()
        for p in products {
            if p.productIdentifier == "calcanual" {
                performPurchase(product: p)
            }
        }
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
    
    func setupUI() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(56)
            make.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(purchaseBenetList)
        purchaseBenetList.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(190)
            make.width.equalTo(240)
        }
        
        view.addSubview(monthlyButton)
        monthlyButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.top.equalTo(purchaseBenetList.snp.bottom).offset(16)
        }
        
//        view.addSubview(monthlyPromotionLabel)
//        monthlyPromotionLabel.snp.makeConstraints { make in
//            make.bottom.equalTo(monthlyButton.snp.bottom).offset(20)
//            make.trailing.equalTo(monthlyButton.snp.trailing).offset(-8)
//        }
        
        view.addSubview(yearlyButton)
        yearlyButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.top.equalTo(monthlyButton.snp.bottom).offset(40)
        }
        
//        view.addSubview(yearlyPromotionLabel)
//        yearlyPromotionLabel.snp.makeConstraints { make in
//            make.bottom.equalTo(yearlyButton.snp.bottom).offset(20)
//            make.trailing.equalTo(yearlyButton.snp.trailing).offset(-8)
//        }
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
    
    // MARK: - IBActions
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        loadingAlert.startLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.loadingAlert.stopLoading()
            }
        }
        RazeFaceProducts.store.restorePurchases()
        confirmCheckmark()
    }
    
    // MARK: - Helper Methods
    private func setupObservers() {
        setupNotificationObserver()
    }
    
    private func postNotification(named name: String) {
        NotificationCenter.default.post(name: NSNotification.Name(name), object: nil)
        self.confirmCheckmark()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: .IAPHelperPurchaseNotificationStopLoading, object: nil)
    }
    
    @objc private func stopLoading() {
        self.loadingAlert.stopLoading()
        confirmCheckmark()
    }
    
    @objc private func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String, products.contains(where: { $0.productIdentifier == productID }) else { return }
        reload()
        self.loadingAlert.stopLoading()
    }
    
    private func performPurchase(product: SKProduct?) {
        guard let product = product else { return }
        RazeFaceProducts.store.buyProduct(product)
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
                
                if RazeFaceProducts.store.isProductPurchased("calcanual") {
                    for p in products {
                        if p.productIdentifier == "calcanual" {
                            self.updateUI(with: p)
                        }
                    }
                } else if RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") {
                    for p in products {
                        if p.productIdentifier == "Calc.noads.mensal" {
                            self.updateUI(with: p)
                        }
                    }
                }  else {
                    for p in products {
                        if p.productIdentifier == "Calc.noads.mensal" {
                            self.updateUI(with: p)
                        }
                    }
                }
                
                self.confirmCheckmark()
            }
        }
    }
    
    private func confirmCheckmark() {
        DispatchQueue.main.async {
            if RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") {
                self.monthlyButton.backgroundColor  = .systemGreen
                self.monthlyButton.isUserInteractionEnabled = false
                Defaults.setBool(.monthlyPurchased, true)
            }
            if RazeFaceProducts.store.isProductPurchased("calcanual") {
                self.yearlyButton.backgroundColor  = .systemGreen
                self.yearlyButton.isUserInteractionEnabled = false
                Defaults.setBool(.yearlyPurchased, true)
            }
            if RazeFaceProducts.store.isProductPurchased("NoAds.Calc") {
                Defaults.setBool(.yearlyPurchased, true)
            }
            self.delegate?.purchased()
        }
    }
    
    private func updateUI(with product: SKProduct?) {
        for p in products {
            if p.productIdentifier == "Calc.noads.mensal" {
                monthlyButton.setTitle(Text.monthlySubscription.localized() + priceFormatter.string(from: p.price)!, for: .normal)
            }
            if p.productIdentifier == "calcanual" {
                yearlyButton.setTitle(Text.yearlySubscription.localized() + priceFormatter.string(from: p.price)!, for: .normal)
            }
        }
    }
    
    private func setupLocalizedText() {
        customNavigator.title = String()
        closeButton.title = Text.close.localized()
        restoreButton.title = Text.restore.localized()
    }
}

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }

    override func sizeToFit() {
        super.sizeToFit()
        self.frame.size = intrinsicContentSize
    }
}
