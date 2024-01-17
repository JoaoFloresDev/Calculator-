import Foundation

public struct RazeFaceProducts {
  
  private static let productIdentifiers: Set<ProductIdentifier> = ["NoAds.Calc", "Calc.noads.mensal", "calcanual"]

  public static let store = IAPHelper(productIds: RazeFaceProducts.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
