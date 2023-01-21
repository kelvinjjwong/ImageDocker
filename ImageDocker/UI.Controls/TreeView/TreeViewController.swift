//
//  TreeViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/11/2.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class TreeViewController : StackBodyViewController {
    
    let logger = ConsoleLogger(category: "TreeViewController")
    
    var notificationPopover:NSPopover?
    var notificationViewController:NotificationViewController!
    
    private var stackTitle = "Tree"
    
    override func headerTitle() -> String { return self.stackTitle }
    
    @IBOutlet weak var outlineView: TreeOutlineView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var collectionLoader:((TreeCollection?, SearchCondition) -> ([TreeCollection], String?))?
    var collectionIcon:((TreeCollection) -> NSImage)?
    var collectionTitle:((TreeCollection) -> String)?
    var collectionValue:((TreeCollection) -> String)?
    var collectionActionIcon:((TreeCollection) -> NSImage)?
    var collectionAction:((TreeCollection, NSButton) -> Void)?
    var collectionSelected:((TreeCollection) -> Void)?
    
    var minWidth:CGFloat = 150
    
    var notificationHolder:NSButton? = nil
    
    init(_ title:String? = nil, width:CGFloat = 0.0, height:CGFloat = 0.0, notificationHolder:NSButton? = nil){
        super.init(nibName: "TreeViewController", bundle: nil)
        self.notificationHolder = notificationHolder
        if let t = title {
            self.stackTitle = t
        }
        
        // initialize stack-view body's size, handled by parent class StackBodyViewController
        if height > 0 {
            self.initialHeight = height
        }
        if width > 0 {
            self.initialWidth = width
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.clickDelegate = self
    }
    
    private var trees:[TreeCollection] = []
    
    // show roots
    func show() {
        let condition = SearchCondition.get(from: stackItemContainer!.header.searchCondition, separator: "|") // search includes hidden images
        DispatchQueue.global().async {
            if self.collectionLoader != nil {
                let (treeNodes, message) = self.collectionLoader!(nil, condition)
                self.trees = treeNodes
                
                if let msg = message {
                    MessageEventCenter.default.showMessage(message: msg)
                }
            }
            DispatchQueue.main.async {
                self.outlineView.reloadData()
            }
        }
    }
    
    func filter(keyword:String) {
        // TODO filter
    }
    
    func findNode(keyword:String) {
        // TODO find node
    }
    
    func find(path:String) -> TreeCollection? {
        let paths = self.getPaths(path: path)
        var i = 0
        var nodes:[TreeCollection] = []
        var collectionForSearch:[TreeCollection] = self.trees
        while(i < paths.count) {
            let p = paths[i]
            var node:TreeCollection? = nil
            for c in collectionForSearch {
                if c.path == p {
                    node = c
                }
            }
            if let n = node {
                nodes.append(n)
                collectionForSearch = n.children
                i += 1
            }else{
                break
            }
        }
        if nodes.count == paths.count {
            return nodes[nodes.count - 1]
        }else{
            return nil
        }
    }
    
    func expand(path:String) {
        let paths = self.getPaths(path: path)
        for p in paths {
            if let node = self.find(path: p) {
                self.expandTreeNode(node)
            }
        }
    }
    
    private func getPaths(path:String) -> [String]{
        var paths:[String] = []
        let parts = path.components(separatedBy: "/")
        var p = ""
        for i in 0..<parts.count {
            if i > 0 {
                p += "/"
            }
            p += parts[i]
            paths.append(p)
        }
        return paths
    }
    
    func addChildNode(parent:TreeCollection, name:String) {
        parent.addChild(name)
        self.outlineView.reloadItem(parent, reloadChildren: true)
        self.outlineView.expandItem(parent)
    }
    
    
    
}

extension TreeViewController: NSOutlineViewDataSource, NSOutlineViewDelegate, TreeOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let collection = item as? TreeCollection {
            return collection.childrenCount //collection.children.count
        }
        return self.trees.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let collection = item as? TreeCollection {
            return collection.children[index]
        }
        
        return self.trees[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let collection = item as? TreeCollection {
            return collection.expandable
            || collection.subContainersCount > 0
            || (collection.subContainersCount == 0 && collection.childrenCount > 0)
        }
        // tree-root
        return self.trees.count > 0
    }

    // click
    func outlineViewSelectionDidChange(_ notification:Notification) {
//        if let collection = self.outlineView.item(atRow: self.outlineView.selectedRow) as? TreeCollection {
//            if self.collectionSelected != nil {
//                self.collectionSelected!(collection)
//            }
//        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let collection = item as? TreeCollection, let id = tableColumn?.identifier {
            if id == NSUserInterfaceItemIdentifier("name") {
                let colView:KSTableCellView = outlineView.makeView(withIdentifier: id, owner: self) as! KSTableCellView
                if self.collectionIcon != nil {
                    let icon = self.collectionIcon!(collection)
                    colView.imgView.image = icon
                    colView.imgView.wantsLayer = true
                    colView.imgView.alphaValue = 0.6
                }else{
                    colView.imgView.image = Icons.photos
                    colView.imgView.wantsLayer = true
                    colView.imgView.alphaValue = 0.6
                }
                
                if self.collectionTitle != nil {
                    let title = self.collectionTitle!(collection)
                    colView.txtField.stringValue = title
                    colView.txtField.lineBreakMode = .byWordWrapping
                    colView.autoresizesSubviews = true
                }
                if self.collectionValue != nil {
                    let value = self.collectionValue!(collection)
                    if value == "" {
                        colView.valueField?.isHidden = true
                    }else{
                        colView.valueField?.isHidden = false
                        colView.valueField?.stringValue = "\(value)"
                        colView.valueField?.lineBreakMode = .byWordWrapping
                        colView.valueField?.isEditable = false
                        
                        // rounded corner with background
                        colView.valueField?.wantsLayer = true
                        colView.valueField?.layer?.cornerRadius = 8
                        colView.valueField?.layer?.masksToBounds = true
                        colView.valueField?.alignment = .center
                        colView.valueField?.backgroundColor = Colors.Tree_Badge_Background
                        colView.valueField?.textColor = Colors.Tree_Badge_Text
                        colView.valueField?.frame.size.width = 52
                        colView.valueField?.frame.size.height = 15
                    }
                }
                    
                if self.collectionAction != nil {
                    colView.button.isHidden = false
                    colView.buttonAction = { collection, button in
                        self.collectionAction!(collection, button)
                    }
                    if self.collectionActionIcon != nil {
                        let icon = self.collectionActionIcon!(collection)
                        colView.button.image = icon
                    }else{
                        colView.button.image = Icons.moreHorizontal
                    }
                    collection.button = colView.button
                }else{
                    colView.button.isHidden = true
                }
                
                colView.collection = collection
                colView.toolTip = collection.path
                
                return colView
            }
        }
        return nil
    }
    
    func expandTreeNode(_ item:TreeCollection){
        let condition = SearchCondition.get(from: self.stackItemContainer!.header.searchCondition, separator: "|") // search includes hidden images
        DispatchQueue.global().async {
            if self.collectionLoader != nil {
                let (treeNodes, message) = self.collectionLoader!(item, condition)
                
                if treeNodes.count > 0 {
                    DispatchQueue.main.async {
                        item.removeAllChildren()
                        let startTime = Date()
                        for node in treeNodes {
                            //self.logger.log("rendering tree node \(node.name)")
                            item.addChild(collection: node)
                        }
                        self.logger.timecost("tree collection insertion", fromDate: startTime)
                        self.outlineView.reloadItem(item, reloadChildren: true)
                        self.outlineView.expandItem(item)
                    }
                }else{
                    self.logger.log("loaded 0 child nodes")
                }
                if let msg = message {
                    MessageEventCenter.default.showMessage(message: msg)
                }
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        //self.logger.log("calling should expand item logic")
        if let node = item as? TreeCollection {
            if node.children.count == 0 {
                self.expandTreeNode(node)
                return false
            }else{
                return true
            }
        }else{
            return false
        }
    }
    
    func onClicked(row: Int, item: Any?) {
        if let collection = item as? TreeCollection {
            if self.collectionSelected != nil {
                self.collectionSelected!(collection)
            }
        }
    }
}

extension TreeViewController : NSPopoverDelegate {
    
    private func createNotificationPopover(message:String){
        var myPopover = self.notificationPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 600, height: 150))
            self.notificationViewController = NotificationViewController()
            self.notificationViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.notificationViewController
            myPopover!.appearance = NSAppearance(named: .aqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.notificationPopover = myPopover
        self.notificationViewController.lblMessage.stringValue = message
    }
    
    func popoverNotification(message:String){
        DispatchQueue.main.async {
            let currentMouseLocation = NSEvent.mouseLocation
            let posX = currentMouseLocation.x
            let posY = currentMouseLocation.y
            
            self.createNotificationPopover(message: message)
            let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
            invisibleWindow.backgroundColor = .red
            invisibleWindow.alphaValue = 0
            
            invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
            invisibleWindow.makeKeyAndOrderFront(self)
            
            self.notificationPopover?.show(relativeTo: invisibleWindow.contentView!.frame, of: invisibleWindow.contentView!, preferredEdge: .maxY)
        }
    }
    
    func popNotification(message:String) {
        if let holder = self.notificationHolder {
            DispatchQueue.main.async {
                holder.title = "  \(message)"
                holder.isHidden = false
            }
        }else{
            self.popoverNotification(message: message)
        }
    }
}
