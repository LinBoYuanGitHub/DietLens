//
//  ProfileActivityLvlViewController.swift
//  DietLens
//
//  Created by linby on 2018/7/4.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol activitySelectDelegate: class {
    func onActivitySelect(index: Int)
}

class ProfileActivityLvlViewController: BaseViewController {

    @IBOutlet weak var exerciseTable: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressText: UILabel!

    weak var activitySelectDelegate: activitySelectDelegate?
    var indexValue: Int  = 1

    //registration flow param
    var profile: UserProfile?
    var isInRegistrationFlow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        exerciseTable.delegate = self
        exerciseTable.dataSource = self
        exerciseTable.tableFooterView = UIView()
        //set the initial index value into profile
        profile?.activityLevel = indexValue
        progressBar.isHidden = !isInRegistrationFlow
        progressText.isHidden = !isInRegistrationFlow
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //back btn
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1.0)
        if isInRegistrationFlow {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: StringConstants.UIString.nextBtnText, style: .plain, target: self, action: #selector(toFavFoodSelectionPage))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 67.0/255.0, green: 67.0/255.0, blue: 67.0/255.0, alpha: 1.0)
        }
        //reload to remove selectorOverlay
        exerciseTable.reloadData()
    }

    @objc func toFavFoodSelectionPage() {
        //save profile, want to use promise here
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        if profile != nil {
            APIService.instance.updateProfile(userId: userId!, profile: profile!) { (isSuccess) in
                if isSuccess {
                    APIService.instance.getFoodSearchPopularity(mealtime: "", completion: { (popularList) in
                        guard let results =  popularList else {
                            return
                        }
                        if let dest = UIStoryboard(name: "Main", bundle: nil)
                            .instantiateViewController(withIdentifier: "PersonalFavouriteFoodVC") as? PersonalFavouriteFoodViewController {
                            dest.isInRegistrationFlow = self.isInRegistrationFlow
                            dest.popularFoodList = results
                            self.navigationController?.pushViewController(dest, animated: true)
                        }
                    }, nextPageCompletion: { (_) in
                        //consider next page scenario
                    })
                }
            }
        } else {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "update profile failed")
        }
    }

}

extension ProfileActivityLvlViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StringConstants.ExerciseLvlText.exerciseLvlArr.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //reuse id: activityLevelCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "activityLevelCell") as? ActvitityLevelCell else {
            return UITableViewCell()
        }
        cell.setUpCell(titleText: StringConstants.ExerciseLvlText.exerciseLvlArr[indexPath.row], descText: StringConstants.ExerciseLvlText.exerciseDescriptionArr[indexPath.row])
        setUpCellBorder(view: cell.borderView)
        if indexPath.row == indexValue {
            cell.activityLevelLabel.textColor = .white
            cell.activityLevelDesc.textColor = .white
            cell.borderView.backgroundColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(90.0/255.0), blue: CGFloat(90.0/255.0), alpha: 1.0)
        } else {
            cell.activityLevelLabel.textColor = .black
            cell.activityLevelDesc.textColor = .black
            cell.borderView.backgroundColor = .white
        }
        return cell
    }

    func setUpCellBorder(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 1
        view.layer.borderWidth = 1
        let borderColor: UIColor = UIColor(red: 228.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        view.layer.borderColor = borderColor.cgColor
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexValue = indexPath.row
        tableView.reloadData()
        if isInRegistrationFlow {
            profile?.activityLevel = indexValue
        } else {
            if activitySelectDelegate != nil {
                activitySelectDelegate?.onActivitySelect(index: indexValue)
            }
        }
    }

}
