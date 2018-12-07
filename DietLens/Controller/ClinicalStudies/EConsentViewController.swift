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
    let code = VerificationCodeView(frame: CGRect(x: 20, y: 520, width: UIScreen.main.bounds.width - 20*2, height: 30))
    var verificationcode: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "Back Arrow"), style: .plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        self.navigationItem.title = "eConsent"

        code.callBacktext = { str in
            //设置按钮的状态变化，但是次数问题很大，比如回退的时候会导致逻辑不通
            self.code.textFiled.resignFirstResponder()
            self.verificationcode  = str
            self.nextbutton.backgroundColor = UIColor.init(displayP3Red: 236 / 255, green: 47 / 255, blue: 72 / 255, alpha: 1)
            self.nextbutton.layer.borderWidth = 0
            self.nextbutton.setTitleColor(UIColor.init(displayP3Red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
            self.nextbutton.isEnabled = true

        }
        //此处应该写一个删除验证码的时候 next的变化

        view.addSubview(code)
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

    @IBAction func next(_ sender: UIButton) {
        guard let clinicalstudies = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clinicalstudiesVC") as? ClinicalStudiesViewController else {
            return
        }
        self.navigationController?.pushViewController(clinicalstudies, animated: true)

    }

}
