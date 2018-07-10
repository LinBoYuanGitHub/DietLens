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
    let weightInputView = RulerInputView()
    let heightInputView = RulerInputView()
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
        //test
        getProfile()
    }

    func getProfile() {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        APIService.instance.getProfile(userId: userId!) { (userProfile) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
            //set userProfile
            if userProfile == nil {
                return
            }
            self.profile = userProfile!
            self.profileTableView.reloadData()
            let birthDate = DateUtil.normalStringToDate(dateStr: (userProfile?.birthday)!)
            self.birthDayPickerView.setDate(birthDate, animated: false)
        }
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
        let birthDayEntity = ProfileEntity(profileName: "Date of Birth", profileValue: "", profileType: 1)
        let weightEntity =  ProfileEntity(profileName: "Weight", profileValue: "", profileType: 1)
        let heightEntity =  ProfileEntity(profileName: "Height", profileValue: "", profileType: 1)
        secondSectionHeader.profileList.append(genderEntity)
        secondSectionHeader.profileList.append(birthDayEntity)
        secondSectionHeader.profileList.append(weightEntity)
        secondSectionHeader.profileList.append(heightEntity)
        //third section
        let thirdSectionHeader = profileSection()
        thirdSectionHeader.sectionHeaderText = "Your Activity Level"
        let activityLevelEntity =  ProfileEntity(profileName: "moderate exercise", profileValue: "", profileType: 2)
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

    func setUpPickerToolBar(text: String) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.barTintColor = UIColor.white
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)
        toolBar.sizeToFit()
        let textButton = UIBarButtonItem(title: text, style: UIBarButtonItemStyle.plain, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        doneButton.setBackgroundImage(#imageLiteral(resourceName: "RedOvalBackgroundImage"), for: .normal, barMetrics: UIBarMetrics.default)
        doneButton.width = CGFloat(56)
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white, kCTFontAttributeName as NSAttributedStringKey: UIFont(name: "PingFangSC-Regular", size: 16)!], for: .normal)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([textButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

    @objc func donePicker() {
        view.endEditing(true)
    }

    @IBAction func save(_ sender: Any) {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        //add profile name
        let profileNameIndexPath = IndexPath(row: 1, section: 0)
        if let cell = profileTableView.cellForRow(at: profileNameIndexPath) as? ProfileTextFieldCell {
            profile.name = cell.inptText.text!
        }
        APIService.instance.updateProfile(userId: userId!, profile: profile) { (isSuccess) in
            if isSuccess {
                NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
                NotificationCenter.default.post(name: .shouldRefreshSideBarHeader, object: nil)
                    //refresh the profile sharedPreference
                    self.dismiss(animated: true, completion: nil)
                    } else {
                        //error alert
                        AlertMessageHelper.showMessage(targetController: self, title: "", message: "update profile failed")
                    }
                }
        }

    @objc func dateChanged(_ sender: UIDatePicker) {
        let componenets = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        if let day = componenets.day, let month = componenets.month, let year = componenets.year {
            //set data into component
            let indxPath = IndexPath(row: 1, section: 1)
            if let dateCell = profileTableView.cellForRow(at: indxPath) as? ProfileTextFieldCell {
                let birthdayString = "\(year)-\(month)-\(day)"
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
                    cell.inptText.text = profile.name
                    cell.inptText.keyboardType = .asciiCapable
                }
                if indexPath.row == 0 && indexPath.section == 1 {
                    cell.inptText.inputView = genderPickerView
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Gender")
                    cell.inptText.placeholder = "Select Gender"
                    if profile.gender == 0 {
                        cell.inptText.text = "female"
                    } else {
                        cell.inptText.text = "male"
                    }
                } else if indexPath.row == 1 && indexPath.section == 1 {
                    cell.inptText.placeholder = "birthday"
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Date of Birth")
                    cell.inptText.inputView = birthDayPickerView
                    cell.inptText.text = profile.birthday
                } else if indexPath.row == 2 && indexPath.section == 1 {
                    let weightInputView = RulerInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220))
                    weightInputView.unit = "kg"
                    weightInputView.rulerView.setCurrentItem(position: Int(profile.weight), animated: false)
                    weightInputView.textLabel.text = "\(Int(profile.weight))kg"
                    weightInputView.delegate = self
                    weightInputView.rulerTag = weightRulerTag
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Weight")
                    cell.inptText.inputView = weightInputView
                    cell.inptText.placeholder = "input weight"
                    cell.inptText.text = "\(Int(profile.weight))kg"
                } else if indexPath.row == 3 && indexPath.section == 1 {
                     let heightInputView = RulerInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220))
                    heightInputView.unit = "cm"
                    heightInputView.rulerView.setCurrentItem(position: Int(profile.height), animated: false)
                    heightInputView.textLabel.text = "\(Int(profile.height))cm"
                    heightInputView.delegate = self
                    heightInputView.rulerTag = heightRulerTag
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Height")
                    cell.inptText.inputView = heightInputView
                    cell.inptText.placeholder = "input height"
                    cell.inptText.text = "\(Int(profile.height))cm"
                }
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileArrowCell", for: indexPath) as? ProfileArrowCell {
                let activityName =  StringConstants.ExerciseLvlText.exerciseLvlArr[profile.activityLevel]
                cell.setUpCell(text: activityName)
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
                        dest.indexValue = profile.activityLevel
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
        //set profile activity lvl value
        profile.activityLevel = index
        //set value in cell
        let indexPath = IndexPath(row: 0, section: 2)
        if let cell = profileTableView.cellForRow(at: indexPath) as? ProfileArrowCell {
            cell.textComponent.text = StringConstants.ExerciseLvlText.exerciseLvlArr[index]
        }
    }

}

extension PersonalProfileViewController: RulerInputDelegate {

    func onRulerDidSelectItem(tag: Int, index: Int) {

        if weightRulerTag == tag {
            //weight
            let weightIndex = IndexPath(row: 2, section: 1)
            if let weightCell = profileTableView.cellForRow(at: weightIndex) as? ProfileTextFieldCell {
                weightCell.inptText.text = "\(index)kg"
                profile.weight = Double(index)
            }
        } else {
            //height
            let heightIndex = IndexPath(row: 3, section: 1)
            if let heightCell = profileTableView.cellForRow(at: heightIndex) as? ProfileTextFieldCell {
                heightCell.inptText.text = "\(index)cm"
                profile.height = Double(index)
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
