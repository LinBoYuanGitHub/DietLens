//
//  IngredientSearchController.swift
//  DietLens
//
//  Created by linby on 06/12/2017.
//  Copyright © 2017 NExT++. All rights reserved.
//

import Foundation
import UIKit

class IngredientSearchController: UIViewController {

    @IBOutlet weak var TFaddIngredient: DesignableUITextField!
    var addIngredientDelegate: AddIngredientDelegate!

    @IBAction func doneButtonPressed(_ sender: Any) {
        if addIngredientDelegate != nil && !(TFaddIngredient.text?.isEmpty)! {
            addIngredientDelegate.onAddIngredient(TFaddIngredient.text!)
        }
         dismiss(animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
