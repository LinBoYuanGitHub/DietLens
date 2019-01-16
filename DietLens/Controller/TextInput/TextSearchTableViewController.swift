//
//  TextSearchTableViewController.swift
//  DietLens
//
//  Created by boyuan lin on 14/1/19.
//  Copyright © 2019 NExT++. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextSearchTableViewController: ASViewController<ASDisplayNode> {
    //data
    var textSerchResultList = [TextSearchSuggestionEntity]()

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

}
