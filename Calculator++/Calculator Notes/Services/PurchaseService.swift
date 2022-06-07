//
//  PurchaseService.swift
//  Calculator Notes
//
//  Created by Lucio Bueno Vieira Junior on 14/01/22.
//  Copyright © 2022 MakeSchool. All rights reserved.
//


//MARK: Purchase service for Revenue Cat subscription
//import Foundation
//
//class PurchaseService {
//    static func purchase(productId: String?, succesfulPurchase: @escaping () -> Void) {
//        guard productId != nil else {
//            return
//        }
//        // Get SKProduct
//        Purchases.shared.products([productId!]) { (products) in
//            if !products.isEmpty {
//                let skProduct = products[0]
//                // Purchase
//                Purchases.shared.purchaseProduct(skProduct) { transaction, purchaserInfo, error, userCancelled in
//                    if error == nil && !userCancelled {
//                        succesfulPurchase()
//                    }
//                }
//            }
//        }
//    }
//}
