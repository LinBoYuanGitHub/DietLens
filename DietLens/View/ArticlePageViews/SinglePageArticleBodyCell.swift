//
//  SinglePageArticleBodyCell.swift
//  DietLens
//
//  Created by next on 12/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import WebKit

class SinglePageArticleBodyCell: UITableViewCell, WKNavigationDelegate {

    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configWebView()
    }

    func configWebView() {
        self.webView = WKWebView()
        webView.isUserInteractionEnabled = false
        webView.scrollView.isScrollEnabled = false
        self.webView.navigationDelegate = self
        webViewContainer.addSubview(self.webView!)
        self.webView?.frame = CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished navigating to url")
    }

    func setupCell(type: ArticleCellType, data: Any) {
        switch type {
        case .body:
            if let content = data as? String {
                DispatchQueue.main.async {
                    self.webView.loadHTMLString(content, baseURL: nil)
//                    let myURL = URL(string: "https://www.apple.com")
//                    let myRequest = URLRequest(url: myURL!)
//                    self.webView.load(myRequest)
                }
            }
        default:
            print("not supported as of now")
        }
    }
}

public enum ArticleCellType {
    case body
    case subheader
    case picture
}
