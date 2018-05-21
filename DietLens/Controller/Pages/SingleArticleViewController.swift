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
import AlamofireImage
import WebKit

class SingleArticleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WKNavigationDelegate {

    @IBOutlet weak var article: UITableView!
    weak var parallaxHeaderView: UIView?

    var contentHeight: CGFloat = 0.0

    var articleData: Article?

    let headerDarkAlpha = 0.6

    var shouldReload = true

    override func viewDidLoad() {
        super.viewDidLoad()

        article.dataSource = self
        article.delegate = self

        article.parallaxHeader.progress = 0
        setupParallaxHeader()
        // Do any additional setup after loading the view.
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
        if shouldReload {
            article.reloadData()
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "articleMainBody") as? SinglePageArticleBodyCell {
            cell.setupCell(type: .body, data: articleData?.articleContent)
            cell.webView.navigationDelegate = self
            cell.webView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: contentHeight)
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if contentHeight != 0 {
            shouldReload = false
        }
        return contentHeight
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let tableView = scrollView as? UITableView {
//            for cell in tableView.visibleCells {
//                guard let cell = cell as? SinglePageArticleBodyCell else { continue }
//                cell.webView?.setNeedsLayout()
//            }
//        }
//    }

    func setupParallaxHeader() {
        //let image = newsArticle.newsImage
        let imageView = UIImageView()
        //imageView.image = image
        if articleData?.articleImageURL != "" {
            imageView.af_setImage(withURL: URL(string: (articleData?.articleImageURL)!)!, placeholderImage: #imageLiteral(resourceName: "runner"), filter: nil, imageTransition: .crossDissolve(0.5), completion: nil)
        } else {
            imageView.image = #imageLiteral(resourceName: "runner")
        }
        imageView.contentMode = .scaleAspectFill
        parallaxHeaderView = imageView

        imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: CGFloat(headerDarkAlpha)).enable()
        article.parallaxHeader.view = imageView
        article.parallaxHeader.height = 400
        article.parallaxHeader.minimumHeight = 65
        article.parallaxHeader.mode = .centerFill

        let backButton = ExpandedUIButton()
        backButton.setImage(#imageLiteral(resourceName: "Back Arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.imageView?.tintColor = UIColor.white
        imageView.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalTo(view.snp.top).offset(39)
        }
        article.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            //backButton.snp.updateConstraints({ (make) in
                //make.centerY.equalTo(self.view.snp.top).offset(30)
            //})
            parallaxHeader.view.blurView.alpha = CGFloat(self.headerDarkAlpha) - parallaxHeader.progress
            //backButton.imageView?.alpha = parallaxHeader.progress
        }
//        let originalLabel = UILabel()
//        originalLabel.text = articleData?.articleTitle
//        originalLabel.numberOfLines = 1
//        originalLabel.font = UIFont.systemFont(ofSize: 35.0)
//        originalLabel.sizeToFit()
//        originalLabel.textAlignment = .left
//        originalLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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
           make.centerY.equalTo(view.snp.top).offset(39)
        }
//        imageView.addSubview(originalLabel)
        //add constraints using SnapKit library
        vibrantLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 5))
        }

//        originalLabel.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.left.equalToSuperview().offset(5)
//            make.right.equalToSuperview().offset(5)
//        }

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
        self.dismiss(animated: true, completion: nil)
    }
}
