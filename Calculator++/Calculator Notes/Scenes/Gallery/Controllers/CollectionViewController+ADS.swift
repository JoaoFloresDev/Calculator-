import UIKit
import GoogleMobileAds

extension CollectionViewController {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
        if getAddPhotoCounter > 5 {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                ad.present(fromRootViewController: rootViewController)
                UserDefaultService().setAddPhotoCounter(status: 0)
            }
        }
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        let adsService = AdsService()
        interstitial = adsService.createAndLoadInterstitial(delegate: self)
    }

}
