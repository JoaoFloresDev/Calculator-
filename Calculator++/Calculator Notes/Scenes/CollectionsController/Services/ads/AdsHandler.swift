//import UIKit
//import GoogleMobileAds
//
//class AdsHandler {
//    var interstitial: GADInterstitial? = nil
//    let adsService = AdsService()
//
//    func setupAds(controller: UIViewController,
//                          bannerDelegate: GADBannerViewDelegate,
//                          interstitialDelegate: GADInterstitialDelegate) {
//        interstitial = adsService.createAndLoadInterstitial(delegate: interstitialDelegate)
//        guard var interstitial = interstitial else {
//            return
//        }
//        adsService.setupAds(controller: controller,
//                            interstitial: &interstitial,
//                            bannerDelegate: bannerDelegate,
//                            interstitialDelegate: interstitialDelegate)
//    }
//
//    func interstitialDidDismissScreen(delegate: GADInterstitialDelegate) {
//        let adsService = AdsService()
//        interstitial = adsService.createAndLoadInterstitial(delegate: delegate)
//    }
//
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//        let getAddPhotoCounter = Defaults.getInt(.launchCounter)
//        if getAddPhotoCounter > 5 {
//            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
//                ad.present(fromRootViewController: rootViewController)
//                Defaults.setInt(.launchCounter, 0)
//            }
//        }
//    }
//}

import UIKit
import GoogleMobileAds

class AdsHandler {
    var interstitial: GADInterstitial? = nil
    let adsService = AdsService()
    
    func setupAds(controller: UIViewController,
                  bannerDelegate: GADBannerViewDelegate,
                  interstitialDelegate: GADInterstitialDelegate) {
        interstitial = adsService.createAndLoadInterstitial(delegate: interstitialDelegate)
        guard var interstitial = interstitial else {
            return
        }
        adsService.setupAds(controller: controller,
                            interstitial: &interstitial,
                            bannerDelegate: bannerDelegate,
                            interstitialDelegate: interstitialDelegate)
    }
    
    func interstitialDidDismissScreen(delegate: GADInterstitialDelegate) {
        let adsService = AdsService()
        interstitial = adsService.createAndLoadInterstitial(delegate: delegate)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        guard Defaults.getInt(.launchCounter) > 5 else {
            return
        }
        
        if let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            
            if let presentedViewController = rootViewController.presentedViewController {
                ad.present(fromRootViewController: presentedViewController)
                 Defaults.setInt(.launchCounter, 0)
                NotificationCenter.default.post(name: NSNotification.Name("alertWillBePresented"), object: nil)
            } else {
                ad.present(fromRootViewController: rootViewController)
                 Defaults.setInt(.launchCounter, 0)
                NotificationCenter.default.post(name: NSNotification.Name("alertWillBePresented"), object: nil)
            }
        }
    }

}
