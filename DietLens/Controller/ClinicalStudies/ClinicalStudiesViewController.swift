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

    var studyList = [ClinicStudyEntity]() // type changed to ClinicStudyEntity
    override func viewDidLoad() {
        super.viewDidLoad()
        studyTableView.delegate = self
        studyTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        studyTableView.tableFooterView = UIView()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        //test
        for _ in 0..<2 {
            let entity = ClinicStudyEntity.init(id: "", date: "5 Nov 2018", icon: "", itemName: "Food Recommendation for thyroid disordrs")
            studyList.append(entity)
        }
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
            cell.setUpCell(recordType: entity.id, icon: "", study_Name: entity.itemName, studyStartOnDate: entity.date)
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
