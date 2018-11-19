//
//  WebViewController.swift
//  DietLens
//
//  Created by linby on 23/11/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit
import WebKit
//import PBRevealViewController
import SnapKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webViewContainer: UIView!

    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height))
        webView.navigationDelegate = self

//        webView.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.left.equalToSuperview()
//            make.right.equalToSuperview()
//            make.top.equalToSuperview()
//        }

        self.webViewContainer.addSubview(webView)
        configWebView()
        configNavigator()
    }

    @objc func clearButtonPressed(sender: UIBarButtonItem) {
        webView.evaluateJavaScript("HomePage.testFunction()", completionHandler: nil)
        print("clearly")
    }

    func configNavigator() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]

//        leftBarButton.target = self.revealViewController()
//        leftBarButton.action = #selector(PBRevealViewController.revealLeftView)
        rightBarButton.target = self
        rightBarButton.action = #selector(clearButtonPressed(sender:))
    }

    func configWebView() {
        if let url = URL(string: "http://192.168.1.2/ionic") {
            let urlreq = URLRequest(url: url)
            webView.load(urlreq)
            webView.allowsBackForwardNavigationGestures = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
