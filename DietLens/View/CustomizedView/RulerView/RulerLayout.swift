//
//  RulerLayout.swift
//  DietLens
//
//  Created by linby on 2018/7/3.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

class RulerLayout: UICollectionViewFlowLayout {

    var usingScale = false

    private let _scale: CGFloat = 0.6

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let temp = super.layoutAttributesForElements(in: rect)
        if usingScale {
            for attribute in temp! {
                let distance = abs(attribute.center.x - collectionView!.frame.width * 0.5 - collectionView!.contentOffset.x)
                var scale: CGFloat = _scale
                let width = (collectionView!.frame.width + itemSize.width) * _scale
                if distance >= width {
                    scale = _scale
                } else {
                    scale += (1 - distance / width) * (1 - _scale)
                }
                attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return temp
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let rect = CGRect(origin: proposedContentOffset, size: collectionView!.frame.size)
        let temp = super.layoutAttributesForElements(in: rect)
        var gap: CGFloat = 1000
        var attr: CGFloat = 0
        let margin = proposedContentOffset.x + collectionView!.frame.width * 0.5
        for attribute in temp! {
            if gap > abs(attribute.center.x - margin) {
                gap = abs(attribute.center.x - margin)
                attr = attribute.center.x - margin
            }
        }

        return CGPoint(x: proposedContentOffset.x + attr, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
