import UIKit
import GoogleMobileAds

extension CollectionViewController {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
        if getAddPhotoCounter > 5 {
            interstitial.present(fromRootViewController: self)
            UserDefaultService().setAddPhotoCounter(status: 0)
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = AdsService().createAndLoadInterstitial(delegate: self)
    }
}
