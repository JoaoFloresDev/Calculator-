import UIKit

struct LoadingAlert {
    private var alert: UIAlertController
    private var viewController: UIViewController
    
    // Inicializador que recebe a ViewController
    init(in viewController: UIViewController) {
        self.viewController = viewController
        
        alert = UIAlertController(title: String(), message: String(), preferredStyle: .alert)
        alert.view.backgroundColor = .clear
        alert.view.subviews.forEach({ view in
            view.removeFromSuperview()
        })
        
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .large)
        loadingIndicator.center = CGPoint(x: 0, y: 0)
        loadingIndicator.color = .systemBlue
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
    }

    func startLoading(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: completion)
        }
    }
    
    func stopLoading(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.alert.dismiss(animated: true, completion: completion)
        }
    }
}
