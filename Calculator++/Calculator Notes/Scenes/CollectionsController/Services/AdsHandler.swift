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
        let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
        if getAddPhotoCounter > 5 {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                ad.present(fromRootViewController: rootViewController)
                UserDefaultService().setAddPhotoCounter(status: 0)
            }
        }
        
        let disableRecoveryButtonCounter = UserDefaultService().getDisableRecoveryButtonCounter()
        UserDefaultService().setDisableRecoveryButtonCounter(status: disableRecoveryButtonCounter + 1)
        
        if disableRecoveryButtonCounter == 20 || disableRecoveryButtonCounter == 30 {
            UserDefaultService().setRecoveryStatus(status: true)
        }
    }
}
