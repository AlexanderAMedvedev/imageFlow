//
//  WebViewViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 09.08.2023.
//

import Foundation
import UIKit
import WebKit


public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var webView: WKWebView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    weak var delegate: WebViewViewControllerDelegate?
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        estimatedProgressObservation = webView.observe(
                    \.estimatedProgress,
                    options: [],
                    changeHandler: { [weak self] _, _ in
                        guard let self = self else { return }
                        self.presenter?.didUpdateProgressValue(webView.estimatedProgress)
                    })
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
}
extension WebViewViewController: WKNavigationDelegate {
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url) }
            else { return nil }
    }
    // Организация Навигации в рамках webView
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
         if let code = code(from: navigationAction) { //1
             delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                decisionHandler(.cancel) //3
          } else {
              // необходимо задать decisionHandler
                decisionHandler(.allow) //4
            }
    }
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
