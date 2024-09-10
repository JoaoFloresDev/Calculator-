import StoreKit
import Network

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
  static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperPurchaseNotificationStopLoading = Notification.Name("IAPHelperPurchaseNotificationStopLoading")
}

open class IAPHelper: NSObject  {
  
  private let productIdentifiers: Set<ProductIdentifier>
  private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
  private var productsRequest: SKProductsRequest?
  private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
  
  public init(productIds: Set<ProductIdentifier>) {
    productIdentifiers = productIds
    for productIdentifier in productIds {
      let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
      if purchased {
        purchasedProductIdentifiers.insert(productIdentifier)
        print("Previously purchased: \(productIdentifier)")
      } else {
        print("Not purchased: \(productIdentifier)")
      }
    }
    super.init()

    SKPaymentQueue.default().add(self)
  }
}

// MARK: - StoreKit API

extension IAPHelper {
  
  public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler

    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest?.delegate = self
    productsRequest?.start()
  }

  public func buyProduct(_ product: SKProduct) {
    print("Buying \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProductIdentifiers.contains(productIdentifier)
  }
  
  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  public func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {

  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    print("Loaded list of products...")
    let products = response.products
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()

    for p in products {
      print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
    }
  }

  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Failed to load list of products.")
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }

  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {

  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
          NotificationCenter.default.post(name: .IAPHelperPurchaseNotificationStopLoading, object: nil)
          fail(transaction: transaction)
          break
      case .restored:
          NotificationCenter.default.post(name: .IAPHelperPurchaseNotificationStopLoading, object: nil)
          restore(transaction: transaction)
          break
      case .deferred:
          NotificationCenter.default.post(name: .IAPHelperPurchaseNotificationStopLoading, object: nil)
        break
      case .purchasing:
          NotificationCenter.default.post(name: .IAPHelperPurchaseNotificationStopLoading, object: nil)
        break
      }
    }
  }

  private func complete(transaction: SKPaymentTransaction) {
    print("complete...")
    deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func restore(transaction: SKPaymentTransaction) {
    guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }

    print("restore... \(productIdentifier)")
    deliverPurchaseNotificationFor(identifier: productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func fail(transaction: SKPaymentTransaction) {
    print("fail...")
    if let transactionError = transaction.error as NSError?,
      let localizedDescription = transaction.error?.localizedDescription,
        transactionError.code != SKError.paymentCancelled.rawValue {
        print("Transaction Error: \(localizedDescription)")
      }

    SKPaymentQueue.default().finishTransaction(transaction)
  }

    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
        handleFinishDate(identifier: identifier)
    }
    
    private func handleFinishDate(identifier: String) {
        let dateManager = DateManager()
        dateManager.saveDateForEightDaysLater()
        switch identifier {
        case "Calc.noads.mensal":
            dateManager.saveDateForTwoMonthsLater()
        case "calcanual":
            dateManager.saveDateForOneYearAndOneMonthLater()
        default:
            return
        }
    }
}

struct DateManager {
    private let userDefaultsKey = "savedDates"
    
    // Salva a data no UserDefaults
    func saveDate(_ date: Date) {
        var dates = getSavedDates()
        dates.append(date)
        UserDefaults.standard.set(dates, forKey: userDefaultsKey)
    }
    
    // Busca todas as datas salvas
    func getSavedDates() -> [Date] {
        guard let savedDates = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Date] else {
            return []
        }
        return savedDates
    }
    
    // Salvar a data para 8 dias após a data atual
    func saveDateForEightDaysLater() {
        let eightDaysLater = Calendar.current.date(byAdding: .day, value: 9, to: Date())!
        saveDate(eightDaysLater)
    }
    
    // Salvar a data para um ano e um mês após a data atual
    func saveDateForOneYearAndOneMonthLater() {
        if let oneYearAndOneMonthLater = Calendar.current.date(byAdding: .month, value: 13, to: Date()) {
            saveDate(oneYearAndOneMonthLater)
        }
    }
    
    // Salvar a data para dois meses após a data atual
    func saveDateForTwoMonthsLater() {
        let twoMonthsLater = Calendar.current.date(byAdding: .month, value: 2, to: Date())!
        saveDate(twoMonthsLater)
    }
    
    // Verifica se existem datas salvas anteriores ao dia de hoje
    func hasDatesBeforeToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let savedDates = getSavedDates()
        return savedDates.contains { Calendar.current.startOfDay(for: $0) < today }
    }
    
    // Deleta todas as datas inferiores ao dia de hoje
    func deleteDatesBeforeToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let filteredDates = getSavedDates().filter { Calendar.current.startOfDay(for: $0) >= today }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(filteredDates), forKey: userDefaultsKey)
    }
}

class Connectivity {
    static let shared = Connectivity()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "Monitor")
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    func checkConnection(completion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        startMonitoring()
    }
}
