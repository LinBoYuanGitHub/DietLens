//
//  ClinicalStudiesViewController.swift
//  DietLens
//
//  Created by 马胖 on 5/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class ClinicalStudiesViewController: BaseViewController {

    @IBOutlet weak var studyTableView: UITableView!

    var studyList = [ClinicalStudyEntity]() // type changed to ClinicStudyEntity
    override func viewDidLoad() {
        super.viewDidLoad()
        studyTableView.delegate = self
        studyTableView.dataSource = self
//        getClinicalStudyList()
        studyDataMockedUp()
    }

    func getClinicalStudyList() {
        APIService.instance.getClinicalStudyList { (studyList) in
            self.studyList = studyList
            self.studyTableView.reloadData()
        }
    }

    func studyDataMockedUp() {
        let entity1 = ClinicalStudyEntity.init(studyId: "", studyName: "Food recommendation for thyroid disorders", startDate: Date(), status: .pending)
        let entity2 = ClinicalStudyEntity.init(studyId: "", studyName: "Diabetes (Type 2)", startDate: Date(), status: .process)
        let entity3 = ClinicalStudyEntity.init(studyId: "", studyName: "Knee pain (Osteoarthritis)", startDate: Date(), status: .expiry)
        studyList.append(entity1)
        studyList.append(entity2)
        studyList.append(entity3)
        self.studyTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        studyTableView.tableFooterView = UIView()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

}
extension ClinicalStudiesViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studyList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "clinicalStudyCell") as? ClinicalStudyTableViewCell {
            let entity = studyList[indexPath.row]
            cell.setUpCell(studyStatus: entity.status, name: entity.studyName, startDate: DateUtil.formatGMTDateToString(date: entity.startDate))
            //cell.setUpCell(recordType: "Food Recommendation", study_Name: "Food Recommendation for thyroid disordrs", studyStartOnDate: "5 Nov 2018")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("被选中的是：\(indexPath)")
        guard let foodrecommendationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodRecommendationVC") as? FoodRecommendationViewController else {
                    return
                }
        self.navigationController?.pushViewController(foodrecommendationVC, animated: true)

        //此处要写入一些传值

    }

}
