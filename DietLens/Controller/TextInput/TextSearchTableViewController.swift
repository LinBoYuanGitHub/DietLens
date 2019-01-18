//
//  TextSearchTableViewController.swift
//  DietLens
//
//  Created by boyuan lin on 14/1/19.
//  Copyright © 2019 NExT++. All rights reserved.
//

import UIKit
import AsyncDisplayKit

protocol TextSearchTableDelegate: class {
    func onTextSearchItemSelect(dietItem:DietItem)
    func onLoadMore()
}

class TextSearchTableViewController: ASViewController<ASDisplayNode> {
    //data & delegate
    var textSerchResultList = [TextSearchSuggestionEntity]()
    weak var delegate: TextSearchTableDelegate?
    
    struct State {
        var itemCount: Int
        var fetchingMore: Bool
        static let empty = State(itemCount: 0, fetchingMore: false)
    }
    
    var state: State = .empty

    //node
    var tableNode: ASTableNode {
        guard let returnNode = node as? ASTableNode else {
            return ASTableNode()
        }
        return returnNode
    }

    enum TableState {
        case idle
        case scrolling
        case fectchingMore
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init() {
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

}

extension TextSearchTableViewController: ASTableDataSource, ASTableDelegate {

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return textSerchResultList.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let node = TextSearchCellNode(entity: textSerchResultList[indexPath.row])
        return node
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let targetEntity = textSerchResultList[indexPath.row]
        requestFoodDetail(foodId: targetEntity.id)
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        DispatchQueue.main.async {
             context.completeBatchFetching(true)
        }
    }

    
    func requestFoodDetail(foodId:Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.showLoadingDialog()
        APIService.instance.getFoodDetail(foodId: foodId) { (dietItem) in
            appDelegate.dismissLoadingDialog()
            if self.delegate != nil && dietItem != nil  {
                self.delegate?.onTextSearchItemSelect(dietItem: dietItem!)
            } else {
                //error flow
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //dismiss keyboard when scroller in accelerate status
        if scrollView.isDecelerating {
            view.endEditing(true)
        }
        //scroll part of code
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            delegate?.onLoadMore()
        }
    }

}
