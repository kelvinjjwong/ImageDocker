//
//  TreeViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/11/2.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class TreeViewController : StackBodyViewController {
    
    private var stackTitle = "Tree"
    
    override func headerTitle() -> String { return self.stackTitle }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var collectionLoader:((TreeCollection?) -> [TreeCollection])?
    var actionIcon:NSImage?
    var collectionTitle:((TreeCollection) -> (NSImage, String))?
    var collectionValue:((TreeCollection) -> Int)?
    var collectionActionIcon:((TreeCollection) -> NSImage)?
    var collectionAction:((TreeCollection, NSButton) -> Void)?
    var collectionSelected:((TreeCollection) -> Void)?
    
    var minWidth:CGFloat = 150
    
    init(_ title:String? = nil, width:CGFloat = 0.0, height:CGFloat = 0.0){
        super.init(nibName: NSNib.Name(rawValue: "TreeViewController"), bundle: nil)
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
    }
    
    private var trees:[TreeCollection] = []
    
    func show() {
        DispatchQueue.global().async {
            if self.collectionLoader != nil {
                self.trees = self.collectionLoader!(nil)
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
                self.outlineView.expandItem(node)
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

extension TreeViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
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
            return collection.childrenCount > 0 //collection.children.count > 0
        }
        return self.trees.count > 0
    }

    
    func outlineViewSelectionDidChange(_ notification:Notification) {
        if let collection = self.outlineView.item(atRow: self.outlineView.selectedRow) as? TreeCollection {
            if self.collectionSelected != nil {
                self.collectionSelected!(collection)
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let collection = item as? TreeCollection, let id = tableColumn?.identifier {
            if id == NSUserInterfaceItemIdentifier("button") {
                let colView:KSTableActionCellView = outlineView.makeView(withIdentifier: id, owner: self) as! KSTableActionCellView
                if self.collectionActionIcon != nil {
                    let icon = self.collectionActionIcon!(collection)
                    colView.button.image = icon
                    colView.collection = collection
                    colView.toolTip = collection.path
                    colView.buttonAction = { collection, button in
                        if self.collectionAction != nil {
                            self.collectionAction!(collection, button)
                        }
                    }
                    collection.button = colView.button
                }
                return colView
            }else if id == NSUserInterfaceItemIdentifier("name") {
                let colView:KSTableCellView = outlineView.makeView(withIdentifier: id, owner: self) as! KSTableCellView
                if self.collectionTitle != nil {
                    let (icon, title) = self.collectionTitle!(collection)
                    colView.imgView.image = icon
                    colView.txtField.stringValue = title
                    colView.txtField.lineBreakMode = .byWordWrapping
                    colView.autoresizesSubviews = true
                    
                    // auto adjust column width
                    var width = self.view.frame.width - 120 // minus column width of value + button
                    if width < self.minWidth {
                        width = self.minWidth
                    }
                    if let column = tableColumn {
                        column.width = width
                        //print("column width set to \(width)")
                        colView.txtField.sizeToFit()
                    }
                }
                return colView
            }else{
                // number badge
                let colView = outlineView.makeView(withIdentifier: id, owner: self) as! NSTableCellView
                if self.collectionValue != nil {
                    let value = self.collectionValue!(collection)
                    colView.textField?.stringValue = "\(value)"
                    
                    // rounded corner with background
                    colView.textField?.wantsLayer = true
                    colView.textField?.layer?.cornerRadius = 8
                    colView.textField?.layer?.masksToBounds = true
                    colView.textField?.alignment = .center
                    colView.textField?.backgroundColor = NSColor(calibratedWhite: 0.5, alpha: 0.7)
                    colView.textField?.textColor = NSColor(calibratedWhite: 0.9, alpha: 0.9)
                    colView.textField?.frame.origin.x = 2
                    colView.textField?.frame.size.width = 56 - 4
                    colView.textField?.frame.origin.y = 1
                    colView.textField?.frame.size.height = 17 - 2
                }
                colView.textField?.lineBreakMode = .byWordWrapping
                
                // auto adjust column width
                if let column = tableColumn {
                    let textWidth = colView.textField?.bounds.width ?? 0
                    if textWidth > column.width {
                        column.width = textWidth + 10
                    }
                }
                return colView
            }
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        if let node = item as? TreeCollection {
            
            if node.childrenCount > 0  {
                if node.children.count == 0 {
                    DispatchQueue.global().async {
                        if self.collectionLoader != nil {
                            node.children = self.collectionLoader!(node)
                            DispatchQueue.main.async {
                                outlineView.expandItem(item)
                            }
                        }
                    }
                    return false
                }else{
                    return true
                }
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
}
