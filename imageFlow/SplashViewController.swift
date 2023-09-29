import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
   /* private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen" */

    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    private var alertView: AlertPresenterProtocol?
    
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
            /* performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil) */
            
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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

/* extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
} */

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
                    print("LINE 101")
                    self.fetchProfile(token)
                    self.switchToTabBarController()
                    UIBlockingProgressHUD.dismiss()
                    
                case .failure:
                    print("LINE 105")
                    
                    UIBlockingProgressHUD.dismiss()
                    
                    alertView = AlertPresenter(delegate: self, alertSome: createAlertModel())
                    alertView?.show()
                //  break
                    // break - When used inside a switch statement, break causes the switch statement to end its execution immediately and to transfer control to the code after the switch statement’s closing brace
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success:
                    print("fetchPROFILE didNotFail")
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                case .failure:
                    UIBlockingProgressHUD.dismiss()
                    print("fetchPROFILE didFail")
                    let alert = UIAlertController(
                        title: "Что-то пошло не так(",     // заголовок всплывающего окна
                        message: "Не удалось войти в систему", // текст во всплывающем окне
                        preferredStyle: .alert      // preferredStyle может быть .alert или .actionSheet
                    )
                    //  кнопки с действием
                    let action = UIAlertAction(
                                               title: "Ок",
                                               style: .default,
                                               handler: { _ in }
                                               )
                    //  присутствие кнопки
                    alert.addAction(action)
                    //2)
                    present(alert, animated: true, completion: nil)
                   // break
            }
        }
    }
}

extension SplashViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController, completion: (() -> Void)?) {
        present(alert, animated: true, completion: completion)
    }
    func createAlertModel() -> AlertViewModel {
        var alertModel = AlertViewModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "Ок"
        )
        alertModel.handler = { _ in }
        return alertModel
    }
}
