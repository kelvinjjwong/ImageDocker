//
//  StackedTreeViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class StackedTreeViewController: NSViewController, StackItemHost {
    
    let logger = LoggerFactory.get(category: "StackedTreeViewController")
    
    @IBOutlet weak var stack: CustomStackView!
    
    var trees:[TreeViewController] = []
    var nameToTrees:[String:TreeViewController] = [:]
    
    var devideCount = 0
    
    init(divideTo:Int = 0){
        super.init(nibName: "StackedTreeViewController", bundle: nil)
        self.devideCount = divideTo
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stack.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
    }
    
    func calculateHeightOfTreeView(_ defaultHeight:CGFloat) -> CGFloat {
        var treeHeight = defaultHeight
        if self.devideCount > 0 {
            if let outerHeight = self.view.superview?.visibleRect.height {
                treeHeight = outerHeight / CGFloat(self.devideCount) - 100
            }
        }
        return treeHeight
    }
    
    func calculateMaxHeightOfTreeView(maxExpandable:Int = 1) -> CGFloat {
        return CGFloat( ( 700 - 36 * self.devideCount ) / maxExpandable ) - 40
    }
    
    func addTreeView(title:String, dataSource:TreeDataSource, width:CGFloat = 400.0, height:CGFloat = 360.0,
                     disableFilter: Bool = false,
                     nodeIcon:((TreeCollection) -> NSImage)? = nil,
                     nodeValue:((TreeCollection) -> String)? = nil,
                     onNodeSelected:((TreeCollection) -> Void)? = nil,
                     moreActionOnHeader: ((NSButton) -> ())? = nil,
                     moreActionOnNode:((TreeCollection, NSButton) -> Void)? = nil,
                     notificationHolder:NSButton? = nil) {
        
        let treeHeight = self.calculateMaxHeightOfTreeView()
        
        let treeView = TreeViewController(title, width: width, height: treeHeight, notificationHolder: notificationHolder)
        
        
        // MARK: loader and actions
        treeView.collectionLoader = { collection, condition in
            if disableFilter {
                return dataSource.loadChildren(collection, condition: nil)
            }else{
                DispatchQueue.main.async {
                }
                return dataSource.loadChildren(collection, condition: condition)
            }
        }
        if nodeIcon != nil {
            treeView.collectionIcon = nodeIcon!
        }else{
            treeView.collectionIcon = { collection in
                return Icons.photos
            }
        }
        treeView.collectionTitle = { collection in
            return collection.name
        }
        treeView.collectionValue = { collection in
            if nodeValue != nil {
                return nodeValue!(collection)
            }else{
                return "\(collection.childrenCount)"
            }
        }
        treeView.collectionActionIcon = { collection in
            return Icons.more
        }
        treeView.collectionSelected = onNodeSelected
//        { collection in
//            self.logger.log(.trace, "selected \(collection.path)")
//        }
        treeView.collectionAction = moreActionOnNode
        
        self.trees.append(treeView)
        self.nameToTrees[title] = treeView
        self.logger.log(.trace, "[\(title)] is just mapped in nameToTrees[]")
        
        // MARK: stack body
        
        // Setup the view controller's item container.
        let stackItem = treeView.stackItemContainer!
        
        // MARK: header actions
        
        // Set the appropriate action for toggling.
        stackItem.header.disclose = {
            self.disclose(treeView.stackItemContainer!)
        }
        
        stackItem.header.moreAction = moreActionOnHeader
        
        if !disableFilter {
            stackItem.header.filterAction = { 
                //treeView.filter(keyword: keyword)
                treeView.show()
            }
//            stackItem.header.gotoAction = { keyword in
//                treeView.findNode(keyword: keyword)
//            }
        }
        stackItem.header.beforeExpand = {
            self.hideAllTrees()
        }
        stackItem.header.afterExpand = {
            let (opened, closed) = self.countTreeStates()
            //self.logger.log(.trace, "opened: \(opened), closed: \(closed)")
        }
        
        // Add the header view.
        stack.addArrangedSubview(stackItem.header.viewController.view)
        
        // Add the main body content view.
        stack.addArrangedSubview(stackItem.body.viewController.view)
        
//        stackItem.body.viewController.view.boundXToSuperView(superview: stack)
        
        // Make sure the appropriate view controllers are added as children of the current controller.
        addChild(stackItem.body.viewController)
        addChild(stackItem.header.viewController)
        
        // collapse by default
        hide(stackItem, animated: true)
        
        // load data
        treeView.show()
        
        
    }
    
    func loadAllData() {
        if self.trees.count > 0 {
            for tree in self.trees {
                tree.show()
            }
        }
    }
    
    func countTreeStates() -> (Int, Int) {
        var opened = 0
        var closed = 0
        if self.trees.count > 0 {
            for tree in self.trees {
                if let stackItem = tree.stackItemContainer {
                    if stackItem.state == .closed {
                        closed += 1
                    }else{
                        opened += 1
                    }
                }
            }
        }
        return (opened, closed)
    }
    
    func hideAllTrees() {
        if self.trees.count > 0 {
            for tree in self.trees {
                if let stackItem = tree.stackItemContainer {
                    hide(stackItem, animated: true)
                }
            }
        }
    }
    
    func reloadTree(_ title:String) {
        self.logger.log(.trace, "reloadTree: \(title)")
        if let tree = self.nameToTrees[title] {
            tree.show()
        }else{
            self.logger.log(.error, "[\(title)] is missing in nameToTrees[]")
        }
    }
    
    func showTree(_ title:String){
        // expand the specified tree
        if let tree = self.nameToTrees[title] {
            if let stackItem = tree.stackItemContainer {
                show(stackItem, animated: true)
            }
        }
    }
    
    func expand(tree name: String, path:String) {
        if let t = self.nameToTrees[name] {
            t.expand(path: path)
        }
    }
    
    func findNode(_ path:String, tree treeView:TreeViewController) -> Bool{
        if let _ = treeView.find(path: path) {
            return true
        }else{
            return false
        }
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
}
