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
    //profile
    var profile = UserProfile()
    let weightDialog = UIView()
    let heightDialog = UIView()
    //tag
    let heightRulerTag = 0
    let weightRulerTag = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.tableFooterView = UIView()
        registerNib()
        hideKeyboardWhenTappedAround()
        initProfileEntity()
        setUpPicker()
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
        secondSectionHeader.sectionHeaderText = "Your basic information"
        let genderEntity =  ProfileEntity(profileName: "Gender", profileValue: "", profileType: 1)
        let birthDayEntity = ProfileEntity(profileName: "Date of Birth", profileValue: "17-Nov-1995", profileType: 1)
        let weightEntity =  ProfileEntity(profileName: "Weight", profileValue: "50kg", profileType: 1)
        let heightEntity =  ProfileEntity(profileName: "Height", profileValue: "165cm", profileType: 1)
        secondSectionHeader.profileList.append(genderEntity)
        secondSectionHeader.profileList.append(birthDayEntity)
        secondSectionHeader.profileList.append(weightEntity)
        secondSectionHeader.profileList.append(heightEntity)
        //third section
        let thirdSectionHeader = profileSection()
        thirdSectionHeader.sectionHeaderText = "Your Activity Level"
        let activityLevelEntity =  ProfileEntity(profileName: "Very heavy exercise", profileValue: "", profileType: 2)
        thirdSectionHeader.profileList.append(activityLevelEntity)
        //append all the header together
        profileSectionList.append(sectionHeader)
        profileSectionList.append(secondSectionHeader)
        profileSectionList.append(thirdSectionHeader)
    }

    func registerNib() {
        let nib = UINib(nibName: "profileViewHeader", bundle: nil)
        profileTableView.register(nib, forHeaderFooterViewReuseIdentifier: "profileSectionHeader")
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white

    }

    @IBAction func closePage() {
        self.dismiss(animated: true, completion: nil)
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

    @IBAction func save(_ sender: Any) {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        APIService.instance.updateProfile(userId: userId!, name: profile.name, gender: profile.gender, height: profile.height, weight: profile.weight, birthday: profile.birthday) { (isSuccess) in
            if isSuccess {
                NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
                NotificationCenter.default.post(name: .shouldRefreshSideBarHeader, object: nil)
                //refresh the profile sharedPreference
                AlertMessageHelper.dismissLoadingDialog(targetController: self) {
                    if isSuccess {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        //error alert
                        AlertMessageHelper.showMessage(targetController: self, title: "", message: "update profile failed")
                    }
                }
            }
        }
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let year = componenets.year {
            //set data into component
            let indxPath = IndexPath(row: 1, section: 1)
            if let dateCell = profileTableView.cellForRow(at: indxPath) as? ProfileTextFieldCell {
                let monthStr = DateUtil.formatMonthToString(
                    date: sender.date)
                let birthdayString = "\(day)-\(monthStr)-\(year)"
                profile.birthday = birthdayString
                dateCell.inptText.text = birthdayString
            }
        }
    }

}

extension PersonalProfileViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag ==  1 {
            profile.name = textField.text!
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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //gender fill in value
        let indxPath = IndexPath(row: 0, section: 1)
        if let dateCell = profileTableView.cellForRow(at: indxPath) as? ProfileTextFieldCell {
            dateCell.inptText.text = genderList[row]
            if(genderList[row] == "male") {
                profile.gender = 1
            } else {
                profile.gender = 0
            }
        }
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
        let profileEntity = profileSectionList[indexPath.section].profileList[indexPath.row]
        switch profileEntity.profileType {
        case 0:
            //avatar
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileAvatarCell", for: indexPath) as? ProfileAvatarCell {
                cell.setUpCell(textTitle: profileEntity.profileName)
                return cell
            }
        case 1:
            //textField
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileTextFieldCell", for: indexPath) as? ProfileTextFieldCell {
                cell.setUpCell(keyText: profileEntity.profileName, valueText: profileEntity.profileValue)
                if indexPath.row == 1 && indexPath.section == 0 {
                    cell.inptText.placeholder = ""
                }
                if indexPath.row == 0 && indexPath.section == 1 {
                    cell.inptText.inputView = genderPickerView
                    cell.inptText.placeholder = "Select Gender"
                } else if indexPath.row == 1 && indexPath.section == 1 {
                    cell.inptText.placeholder = "birthday"
                    cell.inptText.inputView = birthDayPickerView
                } else if indexPath.row == 2 && indexPath.section == 1 {
                    cell.inptText.inputView = weightDialog
                } else {
                    cell.inptText.inputView = heightDialog
                }
                return cell
            }
        case 2:
            //jump to dest
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileArrowCell", for: indexPath) as? ProfileArrowCell {
                cell.setUpCell(text: profileEntity.profileName)
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileEntity = profileSectionList[indexPath.section].profileList[indexPath.row]
        switch profileEntity.profileType {
            case 0:
                //avatar
                break
            case 1:
                //textField
                if let cell = tableView.cellForRow(at: indexPath) as? ProfileTextFieldCell {
                    cell.inptText.becomeFirstResponder()
                }
                break
            case 2:
                //jump to dest
                if let cell = tableView.cellForRow(at: indexPath) as? ProfileArrowCell {
                    //Navigate to dest
                    if let dest = storyboard?.instantiateViewController(withIdentifier: "activityLevelVC") as? ProfileActivityLvlViewController {
                         self.navigationController?.pushViewController(dest, animated: true)
                        dest.activitySelectDelegate = self
                    }
                }
                break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "profileSectionHeader") as? ProfileViewHeader else {
            return UITableViewHeaderFooterView()
        }
        header.profileHeaderText.text = profileSectionList[section].sectionHeaderText
        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && indexPath.section == 0 {
            return 66
        } else {
            return 44
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return 50
        }
    }

}

extension PersonalProfileViewController: activitySelectDelegate {

    func onActivitySelect(index: Int) {
        let indexPath = IndexPath(row: 0, section: 2)
        if let cell = profileTableView.cellForRow(at: indexPath) as? ProfileArrowCell {
            cell.textComponent.text = StringConstants.ExerciseLvlText.exerciseLvlArr[index]
        }
    }

}

extension PersonalProfileViewController: RulerViewDelegate {

    func didSelectItem(rulerView: RulerView, with index: Int) {

        if heightRulerTag == rulerView.tag {
            //weight
            let weightIndex = IndexPath(row: 2, section: 1)
            if let weightCell = profileTableView.cellForRow(at: weightIndex) as? ProfileTextFieldCell {
                weightCell.inptText.text = "\(index)kg"
            }
        } else {
            //height
            let heightIndex = IndexPath(row: 3, section: 1)
            if let heightCell = profileTableView.cellForRow(at: heightIndex) as? ProfileTextFieldCell {
                heightCell.inptText.text = "\(index)cm"
            }
        }
    }
}

extension PersonalProfileViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
