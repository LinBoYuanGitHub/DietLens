//
//  EmojiInputView.swift
//  DietLens
//
//  Created by linby on 2018/7/9.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

protocol EmojiInputDelegate: class {
    func onEmojiDidSelectItem(index: Int)
}

class EmojiInputView: UIView {
    @IBOutlet weak var emojiSlider: UISlider!
    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var emojiLabel: UILabel!

    weak var delegate: EmojiInputDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        let xibFileName = "EmojiLayout" // xib extension not included
        if let view =  Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as? UIView {
            self.addSubview(view)
            emojiImageView.center.x = self.frame.width/10
            view.frame = self.bounds
        }
    }

    @IBAction func onEmojiValueChange(_ sender: UISlider) {
        let index = Int(sender.value)
        if delegate != nil {
            delegate?.onEmojiDidSelectItem(index: index)
        }
        switch index {
        case 0:
            emojiLabel.text = "Bad"
            emojiImageView.image = #imageLiteral(resourceName: "healthCenter_badMood")
            emojiImageView.center.x = self.frame.width/10
        case 1:
            emojiLabel.text = "Not so good"
            emojiImageView.image = #imageLiteral(resourceName: "healthCenter_notSoGoodMood")
            emojiImageView.center.x = self.frame.width*3/10
        case 2:
            emojiLabel.text = "Ok"
            emojiImageView.image = #imageLiteral(resourceName: "healthCenter_okMood")
             emojiImageView.center.x = self.frame.width*1/2
        case 3:
            emojiLabel.text = "Happy"
            emojiImageView.image = #imageLiteral(resourceName: "healthCenter_happyMood")
            emojiImageView.center.x = self.frame.width*7/10
        case 4:
            emojiLabel.text = "Excellent"
            emojiImageView.image = #imageLiteral(resourceName: "healthCenter_excellent")
            emojiImageView.center.x = self.frame.width*9/10
        default:
            break
        }
    }

}
