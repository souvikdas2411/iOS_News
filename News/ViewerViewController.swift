//
//  ViewerViewController.swift
//  News
//
//  Created by Souvik Das on 28/12/20.
//

import UIKit
import WebKit
class ViewerViewController: UIViewController, WKUIDelegate {
    
    
    public var myURL = ""
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: myURL)!
        let myRequest = URLRequest(url: url)
        webView.load(myRequest)
        
        
        
    }
}
