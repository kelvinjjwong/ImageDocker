//
//  StackedTreeViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class StackedTreeViewController: NSViewController, StackItemHost {
    
    @IBOutlet weak var stack: CustomStackView!
    
    var trees:[TreeViewController] = []
    var nameToTrees:[String:TreeViewController] = [:]
    
    var devideCount = 0
    
    init(divideTo:Int = 0){
        super.init(nibName: NSNib.Name(rawValue: "StackedTreeViewController"), bundle: nil)
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
            if let outerHeight = self.view.superview?.frame.height {
                treeHeight = outerHeight / CGFloat(self.devideCount) - 40
            }
        }
        return treeHeight
    }
    
    func calculateMaxHeightOfTreeView(maxExpandable:Int = 1) -> CGFloat {
        return CGFloat( ( 700 - 36 * self.devideCount ) / maxExpandable )
    }
    
    func addTreeView(title:String, dataSource:TreeDataSource, width:CGFloat = 400.0, height:CGFloat = 360.0,
                     itemIcon:NSImage? = nil,
                     onNodeSelected:((TreeCollection) -> Void)? = nil,
                     moreActionOnHeader: (() -> ())? = nil,
                     moreActionOnNode:((TreeCollection, NSButton) -> Void)? = nil) {
        
        let treeHeight = self.calculateMaxHeightOfTreeView()
        
        let treeView = TreeViewController(title, width: width, height: treeHeight)
        
        
        // MARK: loader and actions
        treeView.collectionLoader = { collection in
            return dataSource.loadChildren(collection)
        }
        treeView.collectionTitle = { collection in
            return (itemIcon ?? Icons.photos, collection.name)
        }
        treeView.collectionValue = { collection in
            return collection.childrenCount
        }
        treeView.collectionActionIcon = { collection in
            return Icons.more
        }
        treeView.collectionSelected = onNodeSelected
//        { collection in
//            print("selected \(collection.path)")
//        }
        treeView.collectionAction = moreActionOnNode
            
        
        
        // MARK: stack body
        
        // Setup the view controller's item container.
        let stackItem = treeView.stackItemContainer!
        
        // MARK: header actions
        
        // Set the appropriate action for toggling.
        stackItem.header.disclose = {
            self.disclose(treeView.stackItemContainer!)
        }
        
        stackItem.header.moreAction = moreActionOnHeader
        stackItem.header.filterAction = { keyword in
            treeView.filter(keyword: keyword)
        }
        stackItem.header.gotoAction = { keyword in
            treeView.findNode(keyword: keyword)
        }
        stackItem.header.beforeExpand = {
            self.hideAllTrees()
        }
        stackItem.header.afterExpand = {
            let (opened, closed) = self.countTreeStates()
            print("opened: \(opened), closed: \(closed)")
        }
        
        // Add the header view.
        stack.addArrangedSubview(stackItem.header.viewController.view)
        
        // Add the main body content view.
        stack.addArrangedSubview(stackItem.body.viewController.view)
        
//        stackItem.body.viewController.view.boundXToSuperView(superview: stack)
        
        // Make sure the appropriate view controllers are added as children of the current controller.
        addChildViewController(stackItem.body.viewController)
        addChildViewController(stackItem.header.viewController)
        
        // collapse by default
        hide(stackItem, animated: true)
        
        // load data
        treeView.show()
        
        self.trees.append(treeView)
        self.nameToTrees[title] = treeView
        
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
    
    func showTree(_ title:String){
        // expand the specified tree
        if let tree = self.nameToTrees[title] {
            if let stackItem = tree.stackItemContainer {
                show(stackItem, animated: true)
            }
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
