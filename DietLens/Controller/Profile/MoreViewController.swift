//
//  MoreViewController.swift
//  DietLens
//
//  Created by linby on 2018/10/17.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class MoreViewController: BaseViewController {

    @IBOutlet weak var protraitImageView: RoundedImage!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var moreItemCollectionView: UICollectionView!
    @IBOutlet weak var rightArrow: UIImageView!

//    let columnLayout = ColumnFlowLayout(
//        cellsPerRow: 4,
//        minimumInteritemSpacing: 10,
//        minimumLineSpacing: 10,
//        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    )

    override func viewDidLoad() {
        super.viewDidLoad()
        moreItemCollectionView.delegate = self
        moreItemCollectionView.dataSource = self
//        moreItemCollectionView.collectionViewLayout = columnLayout
        protraitImageView.isUserInteractionEnabled = true
//        rightArrow.addGestureRecognizer(tapGestureRecognizer)
        refreshUserName()
        loadAvatar()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshUserName), name: .shouldRefreshSideBarHeader, object: nil)
        //analytic screen name
        Analytics.setScreenName("MorePage", screenClass: "MoreViewController")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationController?.navigationBar.isHidden = false
    }

    func loadAvatar() {
        let preferences = UserDefaults.standard
        let facebookId = preferences.value(forKey: PreferenceKey.facebookId)
        let googleImageUrl = preferences.string(forKey: PreferenceKey.googleImageUrl)
        if facebookId != nil {
            let profileAvatarURL = URL(string: "https://graph.facebook.com/\(facebookId ?? "")/picture?type=normal")
            protraitImageView.layer.cornerRadius = protraitImageView.frame.size.width/2
            protraitImageView.clipsToBounds = true
            protraitImageView.kf.setImage(with: profileAvatarURL)
        } else if googleImageUrl != nil {
            protraitImageView.layer.cornerRadius = protraitImageView.frame.size.width/2
            protraitImageView.clipsToBounds = true
            protraitImageView.kf.setImage(with: URL(string: googleImageUrl!))
        }
    }

    @objc func refreshUserName() {
        let preferences = UserDefaults.standard
        guard let nickname =  preferences.string(forKey: PreferenceKey.nickNameKey) else {
            return
        }
        if nickname.isEmpty {
            nickNameLabel.text = "Profile"
        } else {
            nickNameLabel.text = nickname
        }
    }

    @IBAction func jumpToProfile(_ sender: Any) {
        if let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "personalProfileVC") as? PersonalProfileViewController {
            self.navigationController?.pushViewController(dest, animated: true)
        }
    }

}

extension MoreViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moreCollectionCell", for: indexPath) as? MoreCollectionCell {
            switch indexPath.row {
            case 0:cell.setUpCell(icon: UIImage(imageLiteralResourceName: "more_favorite_food_icon"), text: "Nutrition Database")
            case 1:cell.setUpCell(icon: UIImage(imageLiteralResourceName: "more_feedback_icon"), text: "Feedback")
            case 2:cell.setUpCell(icon: UIImage(imageLiteralResourceName: "more_share_icon"), text: "Share")
            default:
                break
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            //to text search view
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateInitialViewController() as? AddFoodViewController {
                dest.tabIndex = 1
                if let navigator = self.navigationController {
                    //clear controller to Bottom & add foodCalendar Controller
                    let transition = CATransition()
                    transition.duration = 0.3
                    //                transition.type = kCATransitionFromTop
                    transition.type = kCATransitionMoveIn
                    transition.subtype = kCATransitionFromTop
                    self.view.window?.layer.add(transition, forKey: kCATransition)
                    navigator.pushViewController(dest, animated: false)
                }
            }
        case 1:
            //to feedback page
            let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedbackVC")
            self.present(dest, animated: true, completion: nil)
        case 2:
            //share function
            let shareURL = URL(string: "https://download.dietlens.com")
            let shareText = "Welcome to dietlens"
            let shareActController = UIActivityViewController(activityItems: [shareURL, shareText], applicationActivities: nil)
            self.present(shareActController, animated: true, completion: nil)
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(100))
    }
}
