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
    @IBAction func didTapShare(){
        // Setting description
        let firstActivityItem = "Share news"
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: myURL)!
        
        // If you want to use an image
        //        let image : UIImage = UIImage(named: "your-image-name")!
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        //activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        //activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        //activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
}
