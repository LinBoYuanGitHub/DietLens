//
//  PersonalProfileViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/27.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class PersonalProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!
    //dialog & picker
    var birthDayPickerView: UIDatePicker!
    var genderPickerView: UIPickerView!
    //profile entity list
    var profileSectionList = [profileSection]()
    let genderList = ["male", "female", "others"]

    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        registerNib()
    }

    func initProfileEntity() {
        //first section
        let sectionHeader = profileSection()
        let avatar = ProfileEntity(profileName: "Avatar", profileValue: "", profileType: 0)
        let userName = ProfileEntity(profileName: "Username", profileValue: "", profileType: 1)
        sectionHeader.profileList.append(avatar)
        sectionHeader.profileList.append(userName)
        //second section
        let secondSectionHeader = profileSection()
        let genderEntity =  ProfileEntity(profileName: "Gender", profileValue: "", profileType: 1)
        let birthDayEntity = ProfileEntity(profileName: "Date of Birth", profileValue: "17-Nov-1995", profileType: 1)
        let weightEntity =  ProfileEntity(profileName: "Date of Birth", profileValue: "50kg", profileType: 1)
        let heightEntity =  ProfileEntity(profileName: "Height", profileValue: "165cm", profileType: 1)
        secondSectionHeader.profileList.append(genderEntity)
        secondSectionHeader.profileList.append(birthDayEntity)
        secondSectionHeader.profileList.append(weightEntity)
        secondSectionHeader.profileList.append(heightEntity)
        //third section
        profileSectionList.append(sectionHeader)
        profileSectionList.append(secondSectionHeader)
    }

    func registerNib() {
        let nib = UINib(nibName: "profileViewHeader", bundle: nil)
        profileTableView.register(nib, forHeaderFooterViewReuseIdentifier: "profileSectionHeader")
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = "Profile"
    }

    @IBAction func closePage() {
        self.dismiss(animated: true, completion: nil)
    }

    func showGenderList() {

    }

    func setUpPicker() {
        birthDayPickerView = UIDatePicker()
        birthDayPickerView.datePickerMode = .date
        birthDayPickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        genderPickerView = UIPickerView()
        genderPickerView.showsSelectionIndicator = true
        genderPickerView.accessibilityViewIsModal = true
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            //set data into component

        }
    }

}

extension PersonalProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderList[row]
    }

}

extension PersonalProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return profileSectionList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileSectionList[section].profileList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileSectionHeader") as? ProfileViewHeader else {
            return UITableViewHeaderFooterView()
        }
        header.profileHeaderText.text = profileSectionList[section].sectionHeaderText
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 50
        }
    }

}
