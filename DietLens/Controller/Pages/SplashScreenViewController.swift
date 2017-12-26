//
//  SplashScreenViewController.swift
//  DietLens
//
//  Created by next on 6/12/17.
//  Copyright © 2017 NExT++. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    let articleDatamanager = ArticleDataManager.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        APIService.instance.getArticleList { (articleList) in
            if articleList != nil {
                self.articleDatamanager.articleList = articleList!
            }
        }
        let preferences = UserDefaults.standard
        let key = "userId"
        var userId = preferences.object(forKey: key)
        if userId == nil {
            APIService.instance.getUUIDRequest { (_) in
                DispatchQueue.main.async {
                     self.performSegue(withIdentifier: "toMainPage", sender: self)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toMainPage", sender: self)
            }
        }
        // Do any additional setup after loading the view.
    }

    func getProfile() {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? HomeViewController {

        }
    }

}
