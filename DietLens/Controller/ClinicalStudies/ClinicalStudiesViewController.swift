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
    @IBOutlet weak var scannerAreaView: UIView!

    @IBOutlet weak var emaptyIconView: UIImageView!
    @IBOutlet weak var emptyIconText: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var studyList = [ClinicalStudyEntity]() // type changed to ClinicStudyEntity
    override func viewDidLoad() {
        super.viewDidLoad()
        studyTableView.delegate = self
        studyTableView.dataSource = self
//        studyDataMockedUp()
        scannerAreaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onScanAreaTap)))
        //hide empty icon
        self.emaptyIconView.isHidden = true
        self.emptyIconText.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    @objc func onScanAreaTap() {

        guard let scanQRVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRScannerController") as? QRScannerController else {
            return
        }

        self.navigationController?.pushViewController(scanQRVC, animated: true)
    }

    func getClinicalStudyList() {
        APIService.instance.getClinicalStudyList { (studyList) in
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true

            if studyList.count != 0 {
                self.emaptyIconView.isHidden = true
                self.emptyIconText.isHidden = true
            }

            self.studyList = studyList
            self.studyTableView.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        studyTableView.tableFooterView = UIView()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.getClinicalStudyList()
    }

    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func scanQR(_ sender: UIButton) {

        guard let scanQRVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QRScannerController") as? QRScannerController else {
            return
        }

        self.navigationController?.pushViewController(scanQRVC, animated: true)
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
            cell.setUpCell(studyStatus: entity.status, name: entity.studyName)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        return UITableViewCell()

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        AlertMessageHelper.showLoadingDialog(targetController: self)
        let groupId = studyList[indexPath.row].studyId
        APIService.instance.getClinicalStudyDetail(groupId: groupId) { (studyDetailEntity) in
            AlertMessageHelper.dismissLoadingDialog(targetController: self)

            if studyDetailEntity == nil {
                return
            }

            guard let foodrecommendationVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FoodRecommendationVC") as? FoodRecommendationViewController else {
                return
            }

            foodrecommendationVC.entity = studyDetailEntity!

            self.navigationController?.pushViewController(foodrecommendationVC, animated: true)
        }
    }

}
