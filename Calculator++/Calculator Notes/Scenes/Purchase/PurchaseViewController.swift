import UIKit
import StoreKit

class PurchaseViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teste: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var customNavigator: UINavigationItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    // MARK: - Variables
    private var products: [SKProduct] = []
    private var timerLoad: Timer!
    
    private lazy var priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationObserver()
        setupLocalizedText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("alertWillBePresented"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("alertHasBeenDismissed"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadAndCheckPurchaseStatus()
    }
    
    // MARK: - IBAction
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        performPurchase(product: products.first)
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        RazeFaceProducts.store.restorePurchases()
        startLoading()
        startTimer(with: 1)
        confirmCheckmark()
    }
    
    // MARK: - UI Management
    private func startLoading() {
        loadingView.alpha = 1
        loadingView.startAnimating()
    }
    
    @objc private func stopLoading() {
        loadingView.alpha = 0
        loadingView.stopAnimating()
    }
    
    private func startTimer(with interval: TimeInterval) {
        timerLoad = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(stopLoading), userInfo: nil, repeats: false)
    }
    
    @objc private func stopLoadingTimer() {
        stopLoading()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    private func setupLocalizedText() {
        customNavigator.title = Text.products.localized()
        closeButton.title = Text.close.localized()
        restoreButton.title = Text.restore.localized()
        buyLabel.text = Text.buy.localized()
        priceLabel.text  = Text.loading.localized()
    }
    
    // MARK: - Data Management
    private func performPurchase(product: SKProduct?) {
        guard let product = product else { return }
        RazeFaceProducts.store.buyProduct(product)
        startLoading()
        startTimer(with: 30)
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
            
            if success {
                self.products = products
                
                DispatchQueue.main.async {
                    self.updateUI(with: products.first)
                }
            } else {
                DispatchQueue.main.async {
                    self.updateUI(with: products.first)
                }
            }
            self.confirmCheckmark()
        }
    }

    @objc private func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let _ = products.firstIndex(where: { product -> Bool in
                product.productIdentifier == productID
            })
        else { return }
        
        confirmCheckmark()
    }

    private func confirmCheckmark() {
        DispatchQueue.main.async {
            if RazeFaceProducts.store.isProductPurchased("NoAds.Calc") {
                self.stopLoading()
                self.buyLabel.text = "   ✓✓✓"
                Defaults.setBool(.premiumPurchased, true)
                Defaults.setBool(.iCloudPurchased, true)
            }
        }
    }

    private func updateUI(with product: SKProduct?) {
        guard let product = product else { return }
        
        teste.text = product.localizedTitle
        teste.textColor = UIColor.black
        
        descriptionLabel.text = product.localizedDescription
        descriptionLabel.textColor = UIColor.black
        
        priceFormatter.locale = product.priceLocale
        priceLabel.text = priceFormatter.string(from: product.price)
    }

}
