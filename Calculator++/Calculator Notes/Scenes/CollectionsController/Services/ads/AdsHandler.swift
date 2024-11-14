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
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        let couter = Counter()
        guard couter.count % 4 == 0 && couter.count > 30,
              !Defaults.getBool(.monthlyPurchased), !Defaults.getBool(.yearlyPurchased) else {
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
