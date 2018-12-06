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
        // titemableview.separatorStyle = .none

        //set naviagation bav back button style
        //        self.navigationController?.navigationItem.backBarButtonItem?.image = UIImage(imageLiteralResourceName: "Back Arrow")
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
        return studyList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //        let cell : CumstomItemCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CumstomItemCell
        //        //cell = CumstomItemCell.init(style: .default, reuseIdentifier: "cell")
        //
        //        cell.imageview.image = UIImage(named: "pain")
        //        cell.namelabel.text = ScanResultViewController.name //这里存在问题应该以传值的方式 不应该用静态的变量存值
        return UITableViewCell()

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "clinicalStudyCell", for: indexPath) as? clinicalStudyTableViewCell else {
            return UITableViewCell()
        }
        //cell.setuUpCell(article: nil)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("被选中的是：\(indexPath)")
        //let foodrecommendationVC = FoodRecommendationViewController()

        //navigationController?.pushViewController(foodrecommendationVC, animated: true)

        //        let foodrecommendationVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: type(of: FoodRecommendationViewController())))
        //            as! FoodRecommendationViewController
        //        self.navigationController?.pushViewController(foodrecommendationVC, animated: true)
        //
        //在此处可以传一些值吧但是目前不会

    }

}
