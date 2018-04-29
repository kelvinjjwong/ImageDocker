//
//  OutlineViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class TreeAdditionObj: NSObject {
    var indexPath:NSIndexPath?
    let nodeURL:NSURL?
    let nodeName:String?
    let selectItsParent:Bool
    
    init(_ url:NSURL, withName name:String, select selectItsParent:Bool){
        self.nodeURL = url
        self.nodeName = name
        self.selectItsParent = selectItsParent
    }
}

class OutlineViewController: NSViewController {
    
    @IBOutlet weak var treeController:NSTreeController?
    @IBOutlet weak var myOutlineView:NSOutlineView?
    @IBOutlet weak var placeHolderView:NSView?
    
    var dragNodesArray:NSArray?
    var contents:NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myOutlineView?.enclosingScrollView?.verticalScroller?.floatValue = 0.0
        self.myOutlineView?.enclosingScrollView?.contentView.scroll(to: NSMakePoint(0, 0))
        
        self.myOutlineView?.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.sourceList
    }
    
    func selectParentFromSelection() {
        if self.treeController!.selectedNodes.count > 0 {
            let firstSelectedNode:NSTreeNode = (self.treeController?.selectedNodes[0])!
            if let parentNode:NSTreeNode = firstSelectedNode.parent! {
                self.treeController?.setSelectionIndexPath(parentNode.indexPath)
            }else{
                self.treeController?.removeSelectionIndexPaths((self.treeController?.selectionIndexPaths)!)
            }
        }
    }
    
    func performAddFolder(_ treeAddition:TreeAdditionObj) {
        var indexPath:IndexPath
        if self.treeController?.selectedObjects.count == 0 {
            indexPath = IndexPath(index: (self.contents?.count)!)
        }else{
            indexPath = (self.treeController?.selectionIndexPath)!
            let selectedObj:BaseNode = self.treeController?.selectedObjects[0] as! BaseNode
            if selectedObj.isLeaf {
                self.selectParentFromSelection()
            }else{
                let childrenIndexPath:IndexPath = IndexPath(index: selectedObj.children.count)
                indexPath.append(childrenIndexPath)
            }
        }
        
        let node:ChildNode = ChildNode()
        node.nodeTitle = treeAddition.nodeName!
        self.treeController?.insert(node, atArrangedObjectIndexPath: indexPath)
    }
    
    func performAddChild(_ treeAddition:TreeAdditionObj) {
        if (self.treeController?.selectedObjects.count)! > 0 {
            let selectedObj:BaseNode = self.treeController?.selectedObjects[0] as! BaseNode
            if selectedObj.isLeaf {
                self.selectParentFromSelection()
            }
        }
        var indexPath:IndexPath
        if (self.treeController?.selectedObjects.count)! > 0 {
            let selectedObj:BaseNode = self.treeController?.selectedObjects[0] as! BaseNode
            indexPath = IndexPath(index: selectedObj.children.count)
        }else {
            indexPath = IndexPath(index: (self.contents?.count)!)
        }
        
        let node:ChildNode = ChildNode()
        node.setLeaf(true)
        node.url = treeAddition.nodeURL
        
        if treeAddition.nodeURL != nil {
            if treeAddition.nodeName != nil && treeAddition.nodeName != "" {
                node.nodeTitle = treeAddition.nodeName!
            }else{
                node.nodeTitle = FileManager.default.displayName(atPath: (node.url?.absoluteString)!)
            }
        }
        
        self.treeController?.insert(node, atArrangedObjectIndexPath: indexPath)
        
        if treeAddition.selectItsParent == true {
            self.selectParentFromSelection()
        }
    }
    
    func addChild(_ url:NSURL, withName nameStr:String, selectParent select:Bool) {
        let treeObjInfo:TreeAdditionObj = TreeAdditionObj(url, withName: nameStr, select: select)
        self.performAddChild(treeObjInfo)
    }
    
    func addFolderWithName(_ folderName:String) {
        let treeObjInfo:TreeAdditionObj = TreeAdditionObj(NSURL(), withName: folderName, select: false)
        self.performAddFolder(treeObjInfo)
    }
    
    func addPlacesSection() {
        self.addFolderWithName(BaseNode.placesName()!)
        self.addChild(NSURL(fileURLWithPath: NSHomeDirectory()), withName: "Home", selectParent: true)
        
        let appsDirectory:[String] = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .localDomainMask, true) as [String]
        self.addChild(NSURL(fileURLWithPath: appsDirectory[0]), withName: "", selectParent: true)
        
        self.selectParentFromSelection()
    }
    
    func populateOutlineContents() {
        self.myOutlineView?.isHidden = true
        
        self.addPlacesSection()
        
        let selection:[IndexPath] = (self.treeController?.selectionIndexPaths)!
        self.treeController?.removeSelectionIndexPaths(selection)
        
        self.myOutlineView?.isHidden = false
    }
    
    func viewController(forSelection selection:[BaseNode]) -> NSViewController? {
        var returnViewController:NSViewController? = nil
        if selection != nil && selection.count == 1 {
            let node:BaseNode = selection[0]
            if node.url != nil && node.url != NSURL() {
                if node.isBookmark() {
                    // bookmark
                    returnViewController = NSViewController()
                }else {
                    if node.isDirectory() {
                        // directory
                        returnViewController = NSViewController()
                    }else {
                        // file
                        returnViewController = NSViewController()
                    }
                }
            }else{
                // non-file icon
            }
        }else {
            // no selection
        }
        return returnViewController
    }
    
}

extension OutlineViewController:NSOutlineViewDelegate {
    
    func outlineView(_ outlinewView:NSOutlineView, shouldSelectItem item:Any) -> Bool {
        if let node:BaseNode = item as? BaseNode {
            return (!node.isSpecialGroup() && !node.isSeparator())
        } else {
            return false
        }
    }
    
    func outlineView(_ outlineView:NSOutlineView, isGroupItem item:Any) -> Bool {
        if let node:BaseNode = item as? BaseNode {
            return node.isSpecialGroup() ? true : false
        } else {
            return false
        }
    }
    
    func outlineView(_ outlineView:NSOutlineView, viewFor tableColumn:NSTableColumn?, item:Any) -> NSView? {
        if let node:BaseNode = item as? BaseNode {
            if self.outlineView(outlineView, isGroupItem: item) {
                let identifier:String = outlineView.tableColumns[0].identifier.rawValue
                if let result = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView {
                    let value:String = node.nodeTitle.uppercased()
                    result.textField?.stringValue = value
                    return result
                }
            }
        }else{
            let identifier:String = outlineView.tableColumns[0].identifier.rawValue
            if let node:BaseNode = item as? BaseNode,
                let result = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView {
                result.textField?.stringValue = node.nodeTitle
                result.imageView?.image = node.nodeIcon()
                
                if node.isLeaf {
                    result.textField?.isEditable = true
                }
                return result
            }
        }
        let identifier:String = outlineView.tableColumns[0].identifier.rawValue
        if let result = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), owner: self) as? NSTableCellView {
            return result
        }else{
            return nil
        }
        
    }
    
    func control(_ control:NSControl, textShouldEndEditing fieldEditor:NSText) -> Bool {
        return fieldEditor.string.lengthOfBytes(using: String.Encoding.utf8) == 0 ? false : true
    }
}

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        //1
        if let node = item as? BaseNode {
            return node.children.count
        }
        //2
        return 2
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let node = item as? BaseNode {
            return node.children.count > 0
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let node = item as? BaseNode {
            return node.children[index]
        }
        
        return item
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let node = item as? BaseNode {
            return node.nodeTitle
        }
        return ""
    }
    
    
}
