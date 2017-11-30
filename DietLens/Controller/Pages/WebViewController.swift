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
import PBRevealViewController

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var sideMenuButton: UIBarButtonItem!
    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: webViewContainer.frame)
        webView.navigationDelegate = self
        self.webViewContainer.addSubview(webView)
        configWebView()
        configNavigator()
    }

    func configNavigator() {
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: UIFont(name: "SignPainterHouseScript", size: 32)!, NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6347548905, green: 0.6361853982, blue: 0.6580147525, alpha: 1)]
        sideMenuButton.target = self.revealViewController()
        sideMenuButton.action = #selector(PBRevealViewController.revealLeftView)
    }

    func configWebView() {
        let url = URL(string: "https://www.google.com")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
