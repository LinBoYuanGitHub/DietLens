//
//  SingleArticleViewController.swift
//  DietLens
//
//  Created by next on 11/11/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit
import ParallaxHeader
import SnapKit
import WebKit

class ArticleDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, WKNavigationDelegate {

    @IBOutlet weak var article: UITableView!
    weak var parallaxHeaderView: UIView?

    var contentHeight: CGFloat = 0.0

    var articleData: Article?

    let headerDarkAlpha = 0.6

    var shouldReload = true
    var loadCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        article.dataSource = self
        article.delegate = self

        article.parallaxHeader.progress = 0
        setupParallaxHeader()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        contentHeight = webView.scrollView.contentSize.height
        print("webview content height: \(contentHeight)")
        if shouldReload {
            article.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "articleMainBody") as? SinglePageArticleBodyCell {
            cell.setupCell(type: .body, data: articleData?.articleContent)
            cell.webView.contentMode = .scaleAspectFit
            cell.webView.navigationDelegate = self
            cell.webView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: contentHeight)
            cell.webView.bounds = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: contentHeight)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if loadCount == 4 { //load 5 times to determine the height of the tableView cell height
            shouldReload = false
        }
        loadCount += 1
        return contentHeight
    }

    func setupParallaxHeader() {
        //let image = newsArticle.newsImage
        let imageView = UIImageView()
        //imageView.image = image
        if articleData?.articleImageURL != nil && articleData?.articleImageURL != "" {
            imageView.kf.setImage(with: URL(string: (articleData?.articleImageURL)!)!, placeholder: #imageLiteral(resourceName: "runner"), options: [], progressBlock: nil, completionHandler: nil)
//            imageView.af_setImage(withURL: URL(string: (articleData?.articleImageURL)!)!, placeholderImage: #imageLiteral(resourceName: "runner"), filter: nil, imageTransition: .crossDissolve(0.5), completion: nil)
        } else {
            imageView.image = #imageLiteral(resourceName: "runner")
        }
        imageView.contentMode = .scaleAspectFill
        parallaxHeaderView = imageView

        imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: CGFloat(headerDarkAlpha)).enable()
        article.parallaxHeader.view = imageView
        article.parallaxHeader.height = 400
        article.parallaxHeader.minimumHeight = 100
        article.parallaxHeader.mode = .centerFill

        let backButton = ExpandedUIButton()
        backButton.setImage(#imageLiteral(resourceName: "Back Arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.imageView?.tintColor = UIColor.white
        imageView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left).offset(20)
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            } else {
                // Fallback on earlier versions
                make.left.equalTo(self.view.snp.left).offset(20)
                make.top.equalTo(self.view.snp.top).offset(40)
            }
        }
        article.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            //backButton.snp.updateConstraints({ (make) in
                //make.centerY.equalTo(self.view.snp.top).offset(30)
            //})
            parallaxHeader.view.blurView.alpha = CGFloat(self.headerDarkAlpha) - parallaxHeader.progress
            //backButton.imageView?.alpha = parallaxHeader.progress
        }
        // Label for vibrant text
        let vibrantLabel = UILabel()
        vibrantLabel.text = articleData?.articleTitle
        vibrantLabel.numberOfLines = 1
        vibrantLabel.font = UIFont.systemFont(ofSize: 17.0)
        vibrantLabel.sizeToFit()
        vibrantLabel.textAlignment = .left
        vibrantLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.blurView.blurContentView?.addSubview(vibrantLabel)
        vibrantLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton.snp.centerY).offset(0)
            make.left.equalTo(self.view.snp.left).offset(50)
            make.trailing.equalTo(self.view.snp.trailing).offset(10)
        }
        //calculation
        imageView.bringSubview(toFront: backButton)
        imageView.isUserInteractionEnabled = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func backButtonAction(sender: UIButton!) {
//        let btnsendtag: UIButton = sender
//        if btnsendtag.tag == 1 {
//            //do anything here
//        }
        print("click click")
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
}
