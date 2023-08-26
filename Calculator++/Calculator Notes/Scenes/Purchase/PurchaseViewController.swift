import UIKit
import StoreKit

class PurchaseViewController: UIViewController {
    
    //    MARK: - IBOutlets
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teste: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var customNavigator: UINavigationItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    //    MARK: - IBAction
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        RazeFaceProducts.store.buyProduct(self.products[0])
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.loadingPlaying), userInfo: nil, repeats: false)
        
        confirmCheckmark()
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        RazeFaceProducts.store.restorePurchases()
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loadingPlaying), userInfo: nil, repeats: false)
        confirmCheckmark()
        
    }
    
    //    MARK: - Variables
    var products: [SKProduct] = []
    var timerLoad: Timer!
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    //    MARK: - UI
    @objc func loadingPlaying() {
        stopLoading()
    }
    
    func confirmCheckmark() {
        DispatchQueue.main.async {
            if(RazeFaceProducts.store.isProductPurchased("NoAds.Calc")) {
                self.stopLoading()
                self.buyLabel.text = "   ✓✓✓"
                Defaults.setBool(.premiumPurchased, true)
            }
        }
    }
    
    //    MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PurchaseViewController.handlePurchaseNotification(_:)),
                                               name: .IAPHelperPurchaseNotification,
                                               object: nil)
        confirmCheckmark()
        customNavigator.title = Text.products.localized()
        closeButton.title = Text.close.localized()
        restoreButton.title = Text.restore.localized()
        buyLabel.text = Text.buy.localized()
        priceLabel.text  = Text.loading.localized()
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
                    
                    PurchaseViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = PurchaseViewController.self.priceFormatter.string(from: self.products[0].price)!
                    
                }
            } else {
                if products?[0] != nil {
                    self.teste.text = self.products[0].localizedTitle
                    self.teste.textColor = UIColor.black
                    
                    self.descriptionLabel.text = self.products[0].localizedDescription
                    self.descriptionLabel.textColor = UIColor.black
                    
                    PurchaseViewController.self.priceFormatter.locale = self.products[0].priceLocale
                    self.priceLabel.text = PurchaseViewController.self.priceFormatter.string(from: self.products[0].price) ?? "..."
                }
            }
        }
        confirmCheckmark()
    }
}
