import UIKit
import GoogleMobileAds

struct AdsService {
    let interstitialAdUnitID = "ca-app-pub-8858389345934911/8516660323"
    let bannerAdUnitID = "ca-app-pub-8858389345934911/5265350806"
    let testDeviceIdentifier = "bc9b21ec199465e69782ace1e97f5b79"
    
    func createAndLoadInterstitial(delegate: GADInterstitialDelegate) -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: interstitialAdUnitID)
        interstitial.delegate = delegate
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func checkPurchase(bannerView: GADBannerView?,
                       interstitial: inout GADInterstitial,
                       interstitialDelegate: GADInterstitialDelegate) {
        if RazeFaceProducts.store.isProductPurchased("Calc.noads.mensal") || Defaults.getBool(.monthlyPurchased) || RazeFaceProducts.store.isProductPurchased("calcanual") || Defaults.getBool(.yearlyPurchased) ||
            RazeFaceProducts.store.isProductPurchased("NoAds.Calc") || UserDefaults.standard.object(forKey: "NoAds.Calc") != nil
        {
            bannerView?.removeFromSuperview()
        } else {
            let getAddPhotoCounter = Defaults.getInt(.launchCounter)
            if getAddPhotoCounter > 5 {
                let request = GADRequest()
                interstitial = createAndLoadInterstitial(delegate: interstitialDelegate)
                interstitial.load(request)
                interstitial.delegate = interstitialDelegate
            }
        }
    }
    
    func setupAds(controller: UIViewController,
                  interstitial: inout GADInterstitial,
                  bannerDelegate: GADBannerViewDelegate,
                  interstitialDelegate: GADInterstitialDelegate) {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [testDeviceIdentifier]
        
        let bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        bannerView.tag = 100
        addBannerViewToView(bannerView, in: controller)
        
        bannerView.adUnitID = bannerAdUnitID
        bannerView.rootViewController = controller
        
        bannerView.load(GADRequest())
        bannerView.delegate = bannerDelegate
        checkPurchase(bannerView: bannerView,
                      interstitial: &interstitial,
                      interstitialDelegate: interstitialDelegate)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView,
                             in controller: UIViewController) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(bannerView)
        controller.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: controller.bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: controller.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
}
