//
//  RulerView.swift
//  DietLens
//
//  Created by linby on 2018/7/3.
//  Copyright © 2018 NExT++. All rights reserved.
//

import UIKit

func flat(_ value: CGFloat) -> CGFloat {
    let scale = UIScreen.main.scale
    return ceil(value * scale) / scale
}

let goldenRatio: CGFloat = 0.618

private let reulerViewHeight: CGFloat = 110

private let bottomLineMinY = (reulerViewHeight + itemHeight + titleSpace) / 2

private let itemWidth: CGFloat = 16
private let itemHeight: CGFloat = 66
private let padding: CGFloat = 0

private let itemCount = 10000

private let titleSpace: CGFloat = flat((1 - goldenRatio) * reulerViewHeight)

protocol RulerViewDelegate: class {
    func didSelectItem(rulerView: RulerView, with index: Int)
}

class RulerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    weak var rulerViewDelegate: RulerViewDelegate?
    var divisor: Int = 1
    var currentIndex: Int = 0
    //min & max
    var min = 0
    var max = 10000

    private lazy var collectionView: UICollectionView = {
        let layout = RulerLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = padding
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - titleSpace), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        let margin = (self.frame.width - itemWidth) / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()

    private lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: CGRect(x: self.frame.width / 2 - 40, y: bottomLineMinY, width: 80, height: titleSpace))
        textLabel.textAlignment = .center
        textLabel.text = "0.00"
        return textLabel
    }()

    private lazy var verticalLine: CALayer = {
        let verticalLine = CALayer()
        verticalLine.frame = CGRect(x: (self.frame.width - 1) / 2, y: 0, width: 1, height: 40)
        verticalLine.backgroundColor = UIColor.red.cgColor
        return verticalLine
    }()

    private lazy var bottomLine: CALayer = {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
        let lineColor = UIColor(red: CGFloat(227/255.0), green: CGFloat(228/255.0), blue: CGFloat(229/255.0), alpha: 1.0)
        bottomLine.backgroundColor = lineColor.cgColor
        return bottomLine
    }()

    convenience init(origin: CGPoint, max: Int, min: Int) {
        self.init(frame: CGRect(origin: origin, size: CGSize(width: UIScreen.main.bounds.width, height: reulerViewHeight)))
        self.max = max
        self.min = min
        backgroundColor = UIColor.white
        addSubview(collectionView)
        collectionView.register(RulerCollectionCell.self, forCellWithReuseIdentifier: "rulerCell")
        let indicatorImage = UIImageView(frame: CGRect(x: 0, y: 40, width: 15, height: 15))
        indicatorImage.center = CGPoint(x: (self.frame.width - 1) / 2, y: 40)
        indicatorImage.image = #imageLiteral(resourceName: "rulerIndicator")
//        addSubview(textLabel)
        addSubview(indicatorImage)
        layer.addSublayer(verticalLine)
        layer.addSublayer(bottomLine)
    }

    func setCurrentItem(position: Int, animated: Bool) {
        currentIndex = position - min * divisor
        if currentIndex < 0 {
            currentIndex = 0
        }
        let indexPath = IndexPath(row: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [], animated: animated)
    }

    func getCurrentIndex() -> Int {
        return currentIndex
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max*divisor - min*divisor + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rulerCell", for: indexPath)
        (cell as? RulerCollectionCell)?.min = self.min
        (cell as? RulerCollectionCell)?.divisor = divisor
        (cell as? RulerCollectionCell)?.index = indexPath.row
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = (scrollView.contentOffset.x + scrollView.contentInset.left)
        currentIndex = Int(index/itemWidth) + min*divisor
        if currentIndex < min*divisor || currentIndex > max*divisor {
            return
        }
        rulerViewDelegate?.didSelectItem(rulerView: self, with: currentIndex)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

//        let index = (scrollView.contentOffset.x + scrollView.contentInset.left) / itemWidth

//        textLabel.alpha = 0
//        UIView.animate(withDuration: 0.25) {
//            self.textLabel.alpha = 1
//            // 这里有次显示为负数，做一下特殊处理
//            self.textLabel.text = String(format: "%.2f", max(Double(index), 0))
//        }

//        rulerViewDelegate?.didSelectItem(rulerView: self, with: Int(index))
    }
}
