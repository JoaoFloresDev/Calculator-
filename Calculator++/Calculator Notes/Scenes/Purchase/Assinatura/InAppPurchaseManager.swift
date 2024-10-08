import StoreKit

class InAppPurchaseManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = InAppPurchaseManager()  // Singleton para facilitar o acesso

    private var products: [String: SKProduct] = [:]

    func start() {
        SKPaymentQueue.default().add(self)
        let request = SKProductsRequest(productIdentifiers: Set(["Calc.noads.mensal", "calcanual"]))
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for product in response.products {
            products[product.productIdentifier] = product
        }
    }

    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async {  // Garantir que a UI é atualizada na main thread
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                default:
                    break
                }
            }
        }
    }
    
    func productForId(_ productId: String) -> SKProduct? {
        return products[productId]
    }

    deinit {
        SKPaymentQueue.default().remove(self)  // Remover como observador
    }
}
