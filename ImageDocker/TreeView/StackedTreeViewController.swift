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
    
    func addTreeView(title:String, dataSource:TreeDataSource, width:CGFloat = 290.0, height:CGFloat = 360.0,
                     onNodeSelected:((TreeCollection) -> Void)? = nil,
                     moreActionOnHeader: (() -> ())? = nil,
                     moreActionOnNode:((TreeCollection, NSButton) -> Void)? = nil) {
        
        var treeHeight = height
        if self.devideCount > 0 {
            if let outerHeight = self.view.superview?.frame.height {
                treeHeight = outerHeight / CGFloat(self.devideCount) - 40
            }
        }
        
        let treeView = TreeViewController(title, width: width, height: treeHeight)
        
        
        // MARK: loader and actions
        treeView.collectionLoader = { collection in
            return dataSource.loadChildren(collection)
        }
        treeView.collectionTitle = { collection in
            return (nodeIcon, collection.name)
        }
        treeView.collectionValue = { collection in
            return collection.childrenCount
        }
        treeView.collectionActionIcon = { collection in
            return moreIcon
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
        
        // Add the header view.
        stack.addArrangedSubview(stackItem.header.viewController.view)
        
        // Add the main body content view.
        stack.addArrangedSubview(stackItem.body.viewController.view)
        
//        stackItem.body.viewController.view.boundXToSuperView(superview: stack)
        
        // Make sure the appropriate view controllers are added as children of the current controller.
        addChildViewController(stackItem.body.viewController)
        addChildViewController(stackItem.header.viewController)
        
        // Set the current disclosure state.
        switch stackItem.state {
        case .open: show(stackItem, animated: true)
        case .closed: hide(stackItem, animated: true)
        }
        
        
        treeView.show()
        //treeView.expand(path: "root_3/leaf_3/grand_b")
        
        // Check if we stored the disclosure state from a previous launch (default state is open).
        if let defaultDisclosureState = UserDefaults().value(forKey: treeView.headerTitle()) {
            if defaultDisclosureState as! Int != 0 {
                treeView.disclosureState = .closed
            }
        }
        
//        treeView.view.boundXToSuperView(superview: self.stack)
//        treeView.scrollView.boundXToSuperView(superview: self.stack)
//        treeView.outlineView.boundXToSuperView(superview: treeView.scrollView)
//
//        treeView.outlineView.autoresizingMask = .width
//        treeView.scrollView.autoresizesSubviews = true
//        treeView.view.autoresizesSubviews = true
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
