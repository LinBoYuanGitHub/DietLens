//
//  ActionDisabledTextField
//  DietLens
//
//  Created by linby on 2018/7/25.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation
import UIKit  // don't forget this

class ActionDisabledTextField: UITextField {

    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }

    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {

        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        } else if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
