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
    
    @IBAction func buyPressed(_ sender: Any) {
        performPurchase(product: products.first)
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        RazeFaceProducts.store.restorePurchases()
        startLoading(with: 1)
        confirmCheckmark()
    }
    
    // MARK: - Helper Methods
    private func setupObservers() {
        setupNotificationObserver()
    }
    
    private func postNotification(named name: String) {
        NotificationCenter.default.post(name: NSNotification.Name(name), object: nil)
    }
    
    private func startLoading(with interval: TimeInterval) {
        startLoading()
        timerLoad = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            self.stopLoading()
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    private func startLoading() {
        loadingView.alpha = 1
        loadingView.startAnimating()
    }
    
    private func stopLoading() {
        loadingView.alpha = 0
        loadingView.stopAnimating()
    }
    
    @objc private func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String, products.contains(where: { $0.productIdentifier == productID }) else { return }
        confirmCheckmark()
    }
    
    private func performPurchase(product: SKProduct?) {
        guard let product = product else { return }
        RazeFaceProducts.store.buyProduct(product)
        startLoading(with: 30)
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
            self.products = products
            self.updateUI(with: products.first)
            self.confirmCheckmark()
        }
    }
    
    private func confirmCheckmark() {
        DispatchQueue.main.async {
            if RazeFaceProducts.store.isProductPurchased("NoAds.Calc") {
                self.stopLoading()
                self.buyLabel.text = "   ✓✓✓"
                Defaults.setBool(.premiumPurchased, true)
            }
        }
    }
    
    private func updateUI(with product: SKProduct?) {
        guard let product = product else { return }
        teste.text = product.localizedTitle
        descriptionLabel.text = product.localizedDescription
        priceFormatter.locale = product.priceLocale
        priceLabel.text = priceFormatter.string(from: product.price)
    }
    
    private func setupLocalizedText() {
        customNavigator.title = Text.products.localized()
        closeButton.title = Text.close.localized()
        restoreButton.title = Text.restore.localized()
        buyLabel.text = Text.buy.localized()
        priceLabel.text  = Text.loading.localized()
    }
}
