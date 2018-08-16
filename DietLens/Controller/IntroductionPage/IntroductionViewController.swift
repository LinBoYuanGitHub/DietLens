//
//  IntroductionViewController.swift
//  DietLens
//
//  Created by linby on 2018/7/26.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class IntroductionViewController: UIViewController {

//    var pageTitles: [String] = ["miscItems", "cannedSoup", "categoryBreads"]
    var pageImages: [UIImage] = [#imageLiteral(resourceName: "IntroductionPage1"), #imageLiteral(resourceName: "IntroductionPage2"), #imageLiteral(resourceName: "IntroductionPage3"), #imageLiteral(resourceName: "IntroductionPage4")]

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrMain: UIScrollView!
    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollerView()
    }

    func setUpScrollerView() {
        scrMain.backgroundColor = UIColor.clear
        scrMain.delegate = self as UIScrollViewDelegate
        scrMain.isPagingEnabled = true
        scrMain.contentSize = CGSize(width: self.view.frame.size.width * CGFloat(pageImages.count), height: scrMain.frame.size.height)
        scrMain.showsHorizontalScrollIndicator = false
        //set tap event
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        scrMain.addGestureRecognizer(tapGesture)
        //pageControl for the view
        pageControl.numberOfPages = pageImages.count
        pageControl.addTarget(self, action: #selector(self.pageChanged), for: .valueChanged)
        for index in 0..<pageImages.count {
            let image = UIImageView(frame: CGRect(x: self.view.frame.size.width * CGFloat(index), y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            image.image = pageImages[index]
            image.contentMode = UIViewContentMode.scaleToFill
            self.scrMain.addSubview(image)
        }
    }

    @objc func handleTap() {
        if currentIndex == pageImages.count - 1 {
            redirectToLoginPage()
        }
    }

    @objc func pageChanged() {
        let pageNumber = pageControl.currentPage
        var frame = self.view.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        frame.origin.y = 0
        scrMain.scrollRectToVisible(frame, animated: true)
    }

    func redirectToLoginPage() {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginViewController {
             self.present(dest, animated: true, completion: nil)
        }
    }

}

extension IntroductionViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewWidth: CGFloat = scrollView.frame.size.width
        // content offset - tells by how much the scroll view has scrolled.
        let pageNumber = floor((scrollView.contentOffset.x - viewWidth / 50) / viewWidth) + 1
        pageControl.currentPage = Int(pageNumber)
        currentIndex = Int(pageNumber)
    }

}
