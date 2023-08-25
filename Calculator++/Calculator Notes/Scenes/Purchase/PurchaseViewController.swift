import UIKit
import StoreKit

class PurchaseViewController: UIViewController {
    
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var teste: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var customNavigator: UINavigationItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var restoreButton: UIBarButtonItem!
    
    var products: [SKProduct] = []
    var timerLoad: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadProducts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reloadProducts()
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyPressed(_ sender: Any) {
        purchaseProduct()
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        restorePurchases()
    }
    
    private func purchaseProduct() {
        RazeFaceProducts.store.buyProduct(products[0])
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(loadingPlaying), userInfo: nil, repeats: false)
        confirmCheckmark()
    }
    
    private func restorePurchases() {
        RazeFaceProducts.store.restorePurchases()
        startLoading()
        timerLoad = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(loadingPlaying), userInfo: nil, repeats: false)
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
    
    @objc private func loadingPlaying() {
        stopLoading()
    }
    
    private func startLoading() {
        loadingView.alpha = 1
        loadingView.startAnimating()
    }
    
    private func stopLoading() {
        loadingView.alpha = 0
        loadingView.stopAnimating()
    }
    
    private func reloadProducts() {
        RazeFaceProducts.store.requestProducts { [weak self] success, products in
            guard let self = self else { return }
            if success {
                self.products = products ?? []
                self.updateUIWithProducts()
            }
        }
        confirmCheckmark()
    }
    
    private func updateUIWithProducts() {
        DispatchQueue.main.async {
            self.teste.text = self.products[0].localizedTitle
            self.teste.textColor = UIColor.black
            
            self.descriptionLabel.text = self.products[0].localizedDescription
            self.descriptionLabel.textColor = UIColor.black
            
            PurchaseViewController.priceFormatter.locale = self.products[0].priceLocale
            self.priceLabel.text = PurchaseViewController.priceFormatter.string(from: self.products[0].price)!
        }
    }
}

extension PurchaseViewController {
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
}
