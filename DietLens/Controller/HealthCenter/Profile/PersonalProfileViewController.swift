//
//  PersonalProfileViewController.swift
//  DietLens
//
//  Created by linby on 2018/6/27.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit
import Reachability
import FirebaseAnalytics

class PersonalProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!
    //dialog & picker
    var birthDayPickerView: UIDatePicker!
    var genderPickerView: UIPickerView!
    var ethnicityPickerView: UIPickerView!
    //profile entity list
    var profileSectionList = [ProfileSection]()
    let genderList = [StringConstants.GenderText.MALE, StringConstants.GenderText.FEMALE]
    let ethnicityList = [StringConstants.EnthnicityText.CHINESE, StringConstants.EnthnicityText.MALAYS, StringConstants.EnthnicityText.INDIANS, StringConstants.EnthnicityText.OTHER]
    //profile
    var profile = UserProfile()
    var calorieGoal  = 0.0
    let weightInputView = RulerInputView()
    let heightInputView = RulerInputView()
    //tag
    let heightRulerTag = 0
    let weightRulerTag = 1
    @IBOutlet weak var saveBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.tableFooterView = UIView()
        registerNib()
        hideKeyboardWhenTappedAround()
        initProfileEntity()
        setUpPicker()
        getProfile()
        //analytic screen name
        Analytics.setScreenName("ProfilePage", screenClass: "PersonalProfileViewController")
    }

    func getProfile() {
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        APIService.instance.getProfile(userId: userId!) { (userProfile) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)
            //set userProfile
            if userProfile == nil {
                let cachedProfile =  ProfileDataManager.instance.getCachedProfile()
                if let profile = cachedProfile {
                    self.loadProfileCache(userProfile: profile)
                }
                return
            }
            self.loadProfileCache(userProfile: userProfile!)
        }
        APIService.instance.getDietGoal { (dietGoalDict) in
            guard let calorieGoal = dietGoalDict["energy"] else {
                return
            }
            self.profile.dietGoal.calorie = calorieGoal
            self.calorieGoal = calorieGoal
            let indexPath = IndexPath(row: 0, section: 3)//calorie goal row
            if let cell = self.profileTableView.cellForRow(at: indexPath) as? ProfileArrowCell {
                DispatchQueue.main.async {
                     cell.textComponent.text = "Calorie Goal: " + String(Int(calorieGoal)) + " kcal"
                }
            }
        }
    }

    func loadProfileCache(userProfile: UserProfile) {
        self.profile = userProfile
        self.profile.dietGoal.calorie = calorieGoal
        self.profileTableView.reloadData()
        let birthDate = DateUtil.normalStringToDate(dateStr: (userProfile.birthday))
        self.birthDayPickerView.setDate(birthDate, animated: false)
    }

    func initProfileEntity() {
        //first section
        let sectionHeader = ProfileSection()
        let avatar = ProfileEntity(profileName: "Avatar", profileValue: "", profileType: 0)
        let userName = ProfileEntity(profileName: "Nickname", profileValue: "", profileType: 1)
        let email = ProfileEntity(profileName: "Email", profileValue: "", profileType: 1)
        let phone = ProfileEntity(profileName: "Phone", profileValue: "", profileType: 1)
        sectionHeader.profileList.append(avatar)
        sectionHeader.profileList.append(userName)
        sectionHeader.profileList.append(email)
        sectionHeader.profileList.append(phone)
        //second section
        let secondSectionHeader = ProfileSection()
        secondSectionHeader.sectionHeaderText = "Your Basic Information"
        let genderEntity =  ProfileEntity(profileName: "Gender", profileValue: "", profileType: 1)
        let birthDayEntity = ProfileEntity(profileName: "Date of Birth", profileValue: "", profileType: 1)
        let ethnicityEntity = ProfileEntity(profileName: "Ethnicity", profileValue: "", profileType: 1)
        let weightEntity =  ProfileEntity(profileName: "Weight", profileValue: "", profileType: 1)
        let heightEntity =  ProfileEntity(profileName: "Height", profileValue: "", profileType: 1)
        secondSectionHeader.profileList.append(genderEntity)
        secondSectionHeader.profileList.append(birthDayEntity)
        secondSectionHeader.profileList.append(ethnicityEntity)
        secondSectionHeader.profileList.append(weightEntity)
        secondSectionHeader.profileList.append(heightEntity)
        //third section
        let thirdSectionHeader = ProfileSection()
        thirdSectionHeader.sectionHeaderText = "Your Activity Level"
        let activityLevelEntity =  ProfileEntity(profileName: "Moderate exercise", profileValue: "", profileType: 2)
        thirdSectionHeader.profileList.append(activityLevelEntity)
        //forth section
        let forthSectionHeader = ProfileSection()
        forthSectionHeader.sectionHeaderText = "Goals"
        let calorieGoalEntity =  ProfileEntity(profileName: "", profileValue: "", profileType: 2)
        forthSectionHeader.profileList.append(calorieGoalEntity)
        //append all the header together
        profileSectionList.append(sectionHeader)
        profileSectionList.append(secondSectionHeader)
        profileSectionList.append(thirdSectionHeader)
        profileSectionList.append(forthSectionHeader)
    }

    func registerNib() {
        let nib = UINib(nibName: "profileViewHeader", bundle: nil)
        profileTableView.register(nib, forHeaderFooterViewReuseIdentifier: "profileSectionHeader")
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = false
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        if let attributeGroup = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as?  [NSAttributedStringKey: Any] {
            self.navigationController?.navigationBar.titleTextAttributes = attributeGroup
        }
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    @IBAction func closePage() {
        view.endEditing(true)
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    func setUpPicker() {
        birthDayPickerView = UIDatePicker()
        birthDayPickerView.datePickerMode = .date
        birthDayPickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        setDateLimitation()
        //gender
        genderPickerView = UIPickerView()
        genderPickerView.showsSelectionIndicator = true
        genderPickerView.accessibilityViewIsModal = true
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        //ethnicity
        ethnicityPickerView = UIPickerView()
        ethnicityPickerView.dataSource = self
        ethnicityPickerView.delegate = self
        ethnicityPickerView.showsSelectionIndicator = true
        ethnicityPickerView.accessibilityViewIsModal = true
    }

    func setDateLimitation() {
        var minComp = DateComponents()
        minComp.year = -BirthDayLimitation.maxAge
        var maxComp = DateComponents()
        maxComp.year = -BirthDayLimitation.minAge
        let minDate = Calendar.current.date(byAdding: minComp, to: Date())
        let maxDate = Calendar.current.date(byAdding: maxComp, to: Date())
        birthDayPickerView.maximumDate = maxDate
        birthDayPickerView.minimumDate = minDate
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
        //Internet judgement
        if Reachability()!.connection == .none {
            AlertMessageHelper.showMessage(targetController: self, title: "", message: "No Internet connection found")
            return
        }
        let preferences = UserDefaults.standard
        let key = "userId"
        let userId = preferences.string(forKey: key)
        //add profile name
        let profileNameIndexPath = IndexPath(row: 1, section: 0)
        if let cell = profileTableView.cellForRow(at: profileNameIndexPath) as? ProfileTextFieldCell {
            profile.name = cell.inptText.text!
        }
        saveBtn.isEnabled = false
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appdelegate.showLoadingDialog()
        APIService.instance.updateProfile(userId: userId!, profile: profile) { (isSuccess) in
            self.saveBtn.isEnabled = true
            appdelegate.dismissLoadingDialog()
            if isSuccess {
                //save only when web interface upload succeed
                ProfileDataManager.instance.cacheUserProfile(profile: self.profile)
                NotificationCenter.default.post(name: .shouldRefreshMainPageNutrition, object: nil)
                NotificationCenter.default.post(name: .shouldRefreshSideBarHeader, object: nil)
                    //refresh the profile sharedPreference
//                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
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
                let dayString = day > 9 ? "\(day)" : "0\(day)"
                let monthString = month > 9 ? "\(month)" : "0\(month)"
                let birthdayString = "\(dayString)-\(monthString)-\(year)"
//                profile.birthday = birthdayString
                profile.birthday = "\(year)-\(month)-\(day)"
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

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension PersonalProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderPickerView {
            return genderList.count
        } else if pickerView == ethnicityPickerView {
            return ethnicityList.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            return genderList[row]
        } else if pickerView == ethnicityPickerView {
            return ethnicityList[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //gender fill in value
        if pickerView == genderPickerView {
            let indxPath = IndexPath(row: 0, section: 1)
            if let dateCell = profileTableView.cellForRow(at: indxPath) as? ProfileTextFieldCell {
                dateCell.inptText.text = genderList[row]
                profile.gender  = row + 1
            }
        } else if pickerView == ethnicityPickerView {
            let indxPath = IndexPath(row: 2, section: 1)
            if let dateCell = profileTableView.cellForRow(at: indxPath) as? ProfileTextFieldCell {
                dateCell.inptText.text = ethnicityList[row]
                profile.ethnicity = row + 1
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
                loadAvatar(profileAvatar: cell.avatarImageView)
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
                } else if indexPath.row == 2 && indexPath.section == 0 {
                    cell.inptText.placeholder = ""
                    cell.inptText.text = profile.email
                    cell.inptText.textColor = UIColor(red: 148/255, green: 148/255, blue: 148/255, alpha: 1)
                    cell.inptText.isEnabled = false
                } else if indexPath.row == 3 && indexPath.section == 0 {
                    cell.inptText.placeholder = ""
                    cell.inptText.textColor = UIColor(red: 148/255, green: 148/255, blue: 148/255, alpha: 1)
                    cell.inptText.isEnabled = false
                    //hide the previous 4 phone number digit when matching the phone format
                    let phoneText: String = profile.phone.count >= 11 ? profile.phone.prefix(3) + "****" + profile.phone.dropFirst(7) : profile.phone
                    cell.inptText.text = phoneText
                } else if indexPath.row == 0 && indexPath.section == 1 {
                    cell.inptText.inputView = genderPickerView
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Gender")
                    cell.inptText.delegate = self
                    cell.inptText.placeholder = "Select Gender"
                    if profile.gender == 2 {
                        cell.inptText.text = "Female"
                        genderPickerView.selectRow(1, inComponent: 0, animated: false)
                    } else if profile.gender == 1 {
                        cell.inptText.text = "Male"
                        genderPickerView.selectRow(0, inComponent: 0, animated: false)
                    } else {
                        cell.inptText.text = "Others"
                        genderPickerView.selectRow(2, inComponent: 0, animated: false)
                    }
                } else if indexPath.row == 1 && indexPath.section == 1 {
                    cell.inptText.placeholder = "birthday"
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Date of Birth")
                    cell.inptText.delegate = self
                    cell.inptText.inputView = birthDayPickerView
                    cell.inptText.text = DateUtil.formatSinDateToString(date: birthDayPickerView.date)
                } else if indexPath.row == 2 && indexPath.section == 1 {
                    cell.inptText.inputView = ethnicityPickerView
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Ethnicity")
                    cell.inptText.delegate = self
                    cell.inptText.placeholder = "Select Ethnicity"
                    if profile.ethnicity < 1 {
                        profile.ethnicity = 1
                    }
                    cell.inptText.text = ethnicityList[profile.ethnicity - 1]
                    ethnicityPickerView.selectRow(profile.ethnicity - 1, inComponent: 0, animated: false)
                } else if indexPath.row == 3 && indexPath.section == 1 {
                    let weightInputView = RulerInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220), divisor: 1, max: HealthDeviceSetting.maxWeight, min: HealthDeviceSetting.minWeight)
                    weightInputView.unit = "kg"
                    weightInputView.rulerView.setCurrentItem(position: Int(profile.weight), animated: false)
                    weightInputView.textLabel.text = "\(Int(profile.weight))kg"
                    weightInputView.delegate = self
                    weightInputView.rulerTag = weightRulerTag
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Weight")
                    cell.inptText.delegate = self
                    cell.inptText.inputView = weightInputView
                    cell.inptText.placeholder = "input weight"
                    setAttributeText(textStr: "\(Int(profile.weight))kg", textField: cell.inptText)
                } else if indexPath.row == 4 && indexPath.section == 1 {
                    let heightInputView = RulerInputView(frame: CGRect(x: 0, y: 0, width: 0, height: 220), divisor: 1, max: HealthDeviceSetting.maxHeight, min: HealthDeviceSetting.minHeight)
                    heightInputView.unit = "cm"
                    heightInputView.rulerView.setCurrentItem(position: Int(profile.height), animated: false)
                    heightInputView.textLabel.text = "\(Int(profile.height))cm"
                    heightInputView.delegate = self
                    heightInputView.rulerTag = heightRulerTag
                    cell.inptText.inputAccessoryView = setUpPickerToolBar(text: "Height")
                    cell.inptText.delegate = self
                    cell.inptText.inputView = heightInputView
                    cell.inptText.placeholder = "input height"
                    setAttributeText(textStr: "\(Int(profile.height))cm", textField: cell.inptText)
                }
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileArrowCell", for: indexPath) as? ProfileArrowCell {
                if indexPath.row == 0 && indexPath.section == 2 {
                    let activityName =  StringConstants.ExerciseLvlText.exerciseLvlArr[profile.activityLevel]
                    cell.setUpCell(text: activityName)
                } else if indexPath.row == 0 && indexPath.section == 3 {
                    let activityName =  "Calorie Goal: " + String(Int(profile.dietGoal.calorie)) + " kcal"
                    cell.setUpCell(text: activityName)
                }
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
        case 2:
            //jump to dest
            if let cell = tableView.cellForRow(at: indexPath) as? ProfileArrowCell {
                //Navigate to dest
                if indexPath.row == 0 && indexPath.section == 2 {
                    if let dest = storyboard?.instantiateViewController(withIdentifier: "activityLevelVC") as? ProfileActivityLvlViewController {
                        self.navigationController?.pushViewController(dest, animated: true)
                        dest.activitySelectDelegate = self
                        dest.indexValue = profile.activityLevel
                    }
                } else if indexPath.row == 0 && indexPath.section == 3 {
                    //to set calorie goal page
                    if let dest = storyboard?.instantiateViewController(withIdentifier: "calorieGoalVC") as? CalorieGoalViewController {
                        self.navigationController?.pushViewController(dest, animated: true)
                        dest.calorieGoalSetDelegate = self
//                        dest.calorieGoal = Int(profile.dietGoal.calorie)
                    }
                }
            }
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

    func loadAvatar(profileAvatar: UIImageView) {
        let preferences = UserDefaults.standard
        let facebookId = preferences.value(forKey: PreferenceKey.facebookId)
        let googleImageUrl = preferences.string(forKey: PreferenceKey.googleImageUrl)
        if facebookId != nil {
            let profileAvatarURL = URL(string: "https://graph.facebook.com/\(facebookId ?? "")/picture?type=normal")
            profileAvatar.layer.cornerRadius = profileAvatar.frame.size.width/2
            profileAvatar.clipsToBounds = true
            profileAvatar.kf.setImage(with: profileAvatarURL)
        } else if googleImageUrl != nil {
            profileAvatar.layer.cornerRadius = profileAvatar.frame.size.width/2
            profileAvatar.clipsToBounds = true
            profileAvatar.kf.setImage(with: URL(string: googleImageUrl!))
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

extension PersonalProfileViewController: CalorieGoalSetDelegate {

    func onCalorieGoalSet(goalValue: Int) {
        let indexPath = IndexPath(row: 0, section: 3)//calorie goal row
        if let cell = self.profileTableView.cellForRow(at: indexPath) as? ProfileArrowCell {
            cell.textComponent.text = "Calorie Goal: " + String(goalValue) + " kcal"
            profile.dietGoal.calorie = Double(goalValue)
        }
    }
}

extension PersonalProfileViewController: RulerInputDelegate {

    func onRulerDidSelectItem(tag: Int, value: Double) {

        if weightRulerTag == tag {
            //weight
            let weightIndex = IndexPath(row: 3, section: 1)
            if let weightCell = profileTableView.cellForRow(at: weightIndex) as? ProfileTextFieldCell {
                setAttributeText(textStr: "\(value)kg", textField: weightCell.inptText)
                profile.weight = value
            }
        } else {
            //height
            let heightIndex = IndexPath(row: 4, section: 1)
            if let heightCell = profileTableView.cellForRow(at: heightIndex) as? ProfileTextFieldCell {
                setAttributeText(textStr: "\(value)cm", textField: heightCell.inptText)
                profile.height = value
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

    func setAttributeText(textStr: String, textField: UITextField) {
        let textAttr = NSMutableAttributedString.init(string: textStr)
        textAttr.setAttributes([ kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray, NSAttributedStringKey.font: UIFont(name: "PingFangSC-Light", size: 14.0) as Any
            ], range: NSRange(location: textStr.count - 2, length: 2))
        textField.attributedText = textAttr
    }
}
