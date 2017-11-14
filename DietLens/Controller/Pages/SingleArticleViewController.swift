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

class SingleArticleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var article: UITableView!
    weak var parallaxHeaderView: UIView?

    var articleData: Article?

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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "articleMainBody") as? SinglePageArticleBodyCell {
            cell.setupCell(type: .body, data: articleData?.articleContent)
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func setupParallaxHeader() {
        //let image = newsArticle.newsImage

        let imageView = UIImageView()
        //imageView.image = image
        imageView.af_setImage(withURL: URL(string: (articleData?.articleImageURL)!)!, placeholderImage: #imageLiteral(resourceName: "runner"), filter: nil,
                              imageTransition: .crossDissolve(0.5))
        imageView.contentMode = .scaleAspectFill
        parallaxHeaderView = imageView

        imageView.blurView.setup(style: UIBlurEffectStyle.dark, alpha: 1).enable()

        article.parallaxHeader.view = imageView
        article.parallaxHeader.height = 400
        article.parallaxHeader.minimumHeight = 80
        article.parallaxHeader.mode = .centerFill

        let backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "Back Arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        backButton.imageView?.tintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        imageView.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        article.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            //update alpha of blur view on top of image view
            //backButton.snp.updateConstraints({ (make) in
                //make.centerY.equalTo(self.view.snp.top).offset(30)
            //})

            parallaxHeader.view.blurView.alpha = 1 - parallaxHeader.progress
            //backButton.imageView?.alpha = parallaxHeader.progress
        }

        let originalLabel = UILabel()
        originalLabel.text = articleData?.articleTitle
        originalLabel.numberOfLines = 0
        originalLabel.font = UIFont.systemFont(ofSize: 35.0)
        originalLabel.sizeToFit()
        originalLabel.textAlignment = .left
        originalLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        // Label for vibrant text
        let vibrantLabel = UILabel()
        vibrantLabel.text = articleData?.articleTitle
        vibrantLabel.numberOfLines = 0
        vibrantLabel.font = UIFont.systemFont(ofSize: 17.0)
        vibrantLabel.sizeToFit()
        vibrantLabel.textAlignment = .left
        vibrantLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        imageView.blurView.blurContentView?.addSubview(vibrantLabel)
        imageView.addSubview(originalLabel)
        //add constraints using SnapKit library
        vibrantLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 45, bottom: 5, right: 5))
        }

        originalLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(5)
        }

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
