//
//  EConsentViewController.swift
//  DietLens
//
//  Created by 马胖 on 7/12/18.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class EConsentViewController: UIViewController {

    @IBOutlet weak var nextbutton: UIButton!
    var studyEntity: ClinicalStudyEntity?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "eConsent"

    }
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func learnMore(_ sender: UIButton) {

        guard let learnmoreVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LearnMoreVC") as? LearnMoreViewController else {
            return
        }

        self.present(learnmoreVC, animated: true, completion: nil)
    }

    @IBAction func join(_ sender: UIButton) {

        guard let groupId = studyEntity?.studyId else {
            return
        }

        APIService.instance.connectToStudyGroup(groupId: groupId, completion: { (isSuccess) in

            if isSuccess {
                for vc in (self.navigationController?.viewControllers)! {
                    if let clinicalVC  = vc as? ClinicalStudiesViewController {
                        self.navigationController?.popToViewController(clinicalVC, animated: true)
                    }
                }
            }

        }) { (errMsg) in
            AlertMessageHelper.showMessage(targetController: self, title: "", message: errMsg)
        }
    }

}
