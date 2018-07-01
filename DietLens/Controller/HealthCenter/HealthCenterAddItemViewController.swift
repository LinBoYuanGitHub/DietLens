//
//  AddHealthItemViewCOntroller.swift
//  DietLens
//
//  Created by linby on 2018/6/29.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class HealthCenterAddItemViewController:UIViewController {
    //recordType
    var recordType = ""
    var recordName = ""
    //component
    @IBOutlet weak var TFValue:UITextField!
    @IBOutlet weak var TFDate:UITextField!
    @IBOutlet weak var TFTime:UITextField!
    //3 type of input dialog(UISlider,ruler,keyboard)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        //add record name
        self.navigationController?.navigationBar.topItem?.title = "Add" + recordName
        let textColor = UIColor(red: CGFloat(67/255), green: CGFloat(67/255), blue: CGFloat(67/255), alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: textColor, kCTFontAttributeName: UIFont(name: "PingFangSC-Regular", size: 18)!] as! [NSAttributedStringKey: Any]
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    
}
