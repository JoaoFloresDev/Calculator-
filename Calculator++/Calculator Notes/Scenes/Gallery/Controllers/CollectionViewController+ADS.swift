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
    
    func createAndLoadInterstitial() -> GADInterstitial {
      let interstitial = GADInterstitial(adUnitID: "ca-app-pub-8858389345934911/8516660323")
      interstitial.delegate = self
      interstitial.load(GADRequest())
      return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
      interstitial = createAndLoadInterstitial()
    }
    
    func checkPurchase() {
            if(RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || (UserDefaults.standard.object(forKey: "NoAds.Calc") != nil)) {
                bannerView?.removeFromSuperview()
            } else {
                let getAddPhotoCounter = UserDefaultService().getAddPhotoCounter()
                if getAddPhotoCounter > 5 {
                    let request = GADRequest()
                    interstitial = createAndLoadInterstitial()
                    interstitial.load(request)
                    interstitial.delegate = self
                }
            }
        }
        
        func setupAds() {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["bc9b21ec199465e69782ace1e97f5b79"]
            
            bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
            addBannerViewToView(bannerView)
            
            bannerView.adUnitID = "ca-app-pub-8858389345934911/5265350806"
            bannerView.rootViewController = self
            
            bannerView.load(GADRequest())
            bannerView.delegate = self
            checkPurchase()
        }
        
        func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            view.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: bottomLayoutGuide,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        }
}
