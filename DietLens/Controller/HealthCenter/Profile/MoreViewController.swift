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
    @IBOutlet weak var guestView: UIView!

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
        guestView.isHidden = accountCheck()
        guestView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redirectToWelcomePage)))
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

    @objc func redirectToWelcomePage() {
        guard let welcomeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeVC") as? WelcomeViewController else {
            return
        }
        welcomeVC.shouldShowNavBtn = true
        self.navigationController?.pushViewController(welcomeVC, animated: true)
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
            case 3:cell.setUpCell(icon: UIImage(imageLiteralResourceName: "more_clinical studies_icon"), text: "Clinical studies")
            default:
                break
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if !accountCheck() {
                redirectToWelcomePage()
                return
            }
            if let dest = UIStoryboard(name: "AddFoodScreen", bundle: nil).instantiateViewController(withIdentifier: "textInputVC") as? TextInputViewController {
                dest.addFoodDate = Date()
                dest.isSearchMoreFlow = false
                dest.shouldShowCancel = true
                if let navigator = self.navigationController {
                    navigator.pushViewController(dest, animated: true)
                }
            }

        case 1:
            //to feedback page
            if !accountCheck() {
                redirectToWelcomePage()
                return
            }
            let dest = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feedbackVC")
            self.present(dest, animated: true, completion: nil)
        case 2:
            //share function
            let shareURL = URL(string: "https://download.dietlens.com")
            let shareText = "Welcome to dietlens"
            let shareActController = UIActivityViewController(activityItems: [shareURL, shareText], applicationActivities: nil)
            self.present(shareActController, animated: true, completion: nil)
        //clinical studies
        case 3:
            if !accountCheck() {
                redirectToWelcomePage()
                return
            }
            guard let clinicalstudies = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clinicalstudiesVC") as? ClinicalStudiesViewController else {
                return
            }
            self.navigationController?.pushViewController(clinicalstudies, animated: true)

        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(100), height: CGFloat(100))
    }
}

extension MoreViewController {

    //judge whether userId is Exist
    func accountCheck() -> Bool {
        let userId = UserDefaults.standard.string(forKey: PreferenceKey.userIdkey) ?? ""

        if userId.isEmpty {
            return false
        }
        return true
    }
}
