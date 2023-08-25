//
//  WebViewViewController.swift
//  imageFlow
//
//  Created by Александр Медведев on 09.08.2023.
//

import Foundation
import UIKit
import WebKit

fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"


final class WebViewViewController: UIViewController {
    
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var webView: WKWebView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        //Загрузка окна для ввода логина и пароля для unSplash
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!  //1
        urlComponents.queryItems = [
           URLQueryItem(name: "client_id", value: AccessKey),                  //2
           URLQueryItem(name: "redirect_uri", value: RedirectURI),             //3
           URLQueryItem(name: "response_type", value: "code"),                 //4
           URLQueryItem(name: "scope", value: AccessScope)                     //5
         ]
        let url = urlComponents.url!                                            //6
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        webView.removeObserver(self, forKeyPath:
        #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}
extension WebViewViewController: WKNavigationDelegate {
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,                         //1
            let urlComponents = URLComponents(string: url.absoluteString),  //2
            urlComponents.path == "/oauth/authorize/native",                //3
            let items = urlComponents.queryItems,                           //4
            let codeItem = items.first(where: { $0.name == "code" })        //5
        {
            //print("HERE \(navigationAction)")
            //print("HERE \(codeItem.value)")
            return codeItem.value                                           //6
        } else {
            return nil
        }
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
