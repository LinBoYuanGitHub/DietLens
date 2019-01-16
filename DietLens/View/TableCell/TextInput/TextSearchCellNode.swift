//
//  TextSearchCellNode.swift
//  DietLens
//
//  Created by boyuan lin on 15/1/19.
//  Copyright © 2019 NExT++. All rights reserved.
//

import UIKit
import AsyncDisplayKit
class TextSearchCellNode: ASCellNode {

    let sampleImageNode = ASImageNode()
    let foodNameTextNode = ASTextNode()
    let foodPortionTextNode = ASTextNode()
    let calorieTextNode = ASTextNode()
    let calorieUnitNode = ASTextNode()

    override init() {
        super.init()
    }

    init(entity: TextSearchSuggestionEntity) {
        super.init()
        //node attribute setting
        sampleImageNode.style.preferredSize = CGSize(width: 50, height: 50)
       UIImageView().kf.setImage(with: URL(string: entity.expImagePath)!, placeholder: #imageLiteral(resourceName: "loading_img"), options: nil, progressBlock: nil) { (image, _, _, _) in
            self.sampleImageNode.image = image
        }
        foodNameTextNode.attributedText = NSAttributedString(
            string: entity.name,
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                NSAttributedStringKey.kern: -0.3
            ]
        )
        foodNameTextNode.maximumNumberOfLines = 2
        foodNameTextNode.frame.size.width = 500
        foodPortionTextNode.attributedText = NSAttributedString(
            string: entity.unit,
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                NSAttributedStringKey.kern: -0.3
            ]
        )
        calorieTextNode.attributedText = NSAttributedString(
            string: String(entity.calorie),
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                NSAttributedStringKey.kern: -0.3
            ]
        )
        calorieUnitNode.attributedText = NSAttributedString(
            string: "kcal",
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                NSAttributedStringKey.kern: -0.3
            ]
        )
        addSubnode(sampleImageNode)
        addSubnode(foodNameTextNode)
        addSubnode(foodPortionTextNode)
        addSubnode(calorieTextNode)
        addSubnode(calorieUnitNode)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let foodNameVerticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .center, children: [foodNameTextNode, foodPortionTextNode])
        foodNameVerticalSpec.flexWrap = .wrap
        let calorieVerticalSpec = ASStackLayoutSpec(direction: .vertical, spacing: 5, justifyContent: .center, alignItems: .center, children: [calorieTextNode, calorieUnitNode])
        let finalSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 10, justifyContent: .start, alignItems: .start, children: [sampleImageNode, foodNameVerticalSpec, calorieVerticalSpec])
//        let finalSpec = ASAbsoluteLayoutSpec(children: [sampleImageNode, foodNameVerticalSpec, calorieVerticalSpec])
        finalSpec.style.alignSelf = .stretch
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: finalSpec)
    }

}
