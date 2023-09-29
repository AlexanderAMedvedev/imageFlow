import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLogoView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
            switchToTabBarController()
        } else {
            // Show Auth Screen
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewControllerID") as! AuthViewController
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        // UIApplication - The centralized point of control and coordination for apps running in iOS.
        // shared - The singleton app instance.
        // windows - The app’s visible and hidden windows.
        // first - The first element of the collection.
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        // UIStoryboard(name: "Main", bundle: .main) -
        // - An encapsulation of the design-time view controller graph represented in an Interface Builder storyboard resource file.
        // instantiate(создать экземпляр)ViewController(withIdentifier: "TabBarViewController") -
        // - Creates the view controller with the specified identifier and initializes it with the data from the storyboard.
        window.rootViewController = tabBarController
        // rootViewController - The root view controller for the window.
    }
    private func addLogoView() {
        let logoView = UIImageView(image: UIImage(named: "logoLaunchScreen"))
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        NSLayoutConstraint.activate([
            logoView.heightAnchor.constraint(equalToConstant: 77.68),
            logoView.widthAnchor.constraint(equalToConstant: 75),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let token):
                    self.fetchProfile(token)
                    self.switchToTabBarController()
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    break
                    // break - When used inside a switch statement, break causes the switch statement to end its execution immediately and to transfer control to the code after the switch statement’s closing brace
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token+"token") { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success:
                        UIBlockingProgressHUD.dismiss()
                        self.switchToTabBarController()
                    case .failure:
                        UIBlockingProgressHUD.dismiss()
                        break
                }
            
        }
    }
}
