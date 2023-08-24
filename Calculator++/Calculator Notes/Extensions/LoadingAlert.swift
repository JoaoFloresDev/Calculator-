import UIKit

struct LoadingAlert {
    private var alert: UIAlertController?

    mutating func startLoading(in viewController: UIViewController) {
        alert = UIAlertController(title: String(), message: String(), preferredStyle: .alert)
        alert?.view.backgroundColor = .clear
        alert?.view.subviews.forEach({ view in
            view.removeFromSuperview()
        })
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .large)
        loadingIndicator.center = CGPoint(x: 0, y: 0)
        loadingIndicator.color = .systemBlue
        loadingIndicator.startAnimating()

        alert?.view.addSubview(loadingIndicator)
        viewController.present(alert!, animated: true, completion: nil)
    }
    
    func stopLoading(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.alert?.dismiss(animated: true, completion: completion)
        }
    }
}
