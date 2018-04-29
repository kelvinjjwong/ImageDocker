//
//  BaseNode.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class BaseNode : NSObject {
    
    let kIconSmallImageSize = 16.0
    let kIconLargeImageSize = 32.0
    let PLACES_NAME = "PLACES"
    let BOOKMARKS_NAME = "BOOKMARKS"
    // default grouping titles
    
    // node with not title set
    var nodeTitle = ""
    var children = [BaseNode]()
    var url: NSURL?
    var isLeaf = false
    var booleanDirectory = false
    var booleanBookmark = false
    private(set) var booleanSpecialGroup = false
    private(set) var booleanSeparator = false
    private(set) var isDraggable = false
    
    override init(){
        super.init()
        self.nodeTitle = "BaseNode Untitled"
        self.children = []
        self.isLeaf = false
    }
    
    func description() -> String {
        return "BaseNode"
    }
    
    class func placesName() -> String? {
        return "PLACES"
    }
    
    class func bookmarksName() -> String? {
        return "BOOKMARKS"
    }
    
    class func untitledName() -> String? {
        return "Untitled"
    }
    
    func initLeaf() -> Self {
        self.isLeaf = true
        return self
    }
    
    func setLeaf(_ flag: Bool) {
        isLeaf = flag
        if isLeaf {
            children = [self]
        } else {
            children = [BaseNode]()
        }
    }
    
    func isBookmark() -> Bool {
        let bookmark = false
        if url != nil {
            return url!.isFileURL
        }
        return bookmark
    }
    
    func setIsBookmark(_ bookmark: Bool) {
        self.booleanBookmark = bookmark
    }
    
    func isDirectory() -> Bool {
        var booleanDirectory = false
        if url != nil {
            var isURLDirectory: NSNumber? = nil
            try? isURLDirectory = url!.resourceValues(forKeys: [.isDirectoryKey]).values.first as! NSNumber
            booleanDirectory = isURLDirectory != 0
        }
        return booleanDirectory
    }
    func setIsDirectory(_ directory: Bool) {
        self.booleanDirectory = directory
    }
    
    func compare(_ aNode: BaseNode?) -> ComparisonResult {
        return nodeTitle.lowercased().compare(aNode?.nodeTitle.lowercased() ?? "")
    }
    
    func isSpecialGroup() -> Bool {
        return (nodeTitle == BOOKMARKS_NAME) || (nodeTitle == PLACES_NAME)
    }
    
    func isSeparator() -> Bool {
        return nodeIcon == nil && nodeTitle.count == 0
    }
    
    func nodeIcon() -> NSImage? {
        var icon: NSImage? = nil
        if isLeaf {
            // does it have a URL string?
            if url != nil {
                if isLeaf {
                    if booleanBookmark {
                        icon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericURLIcon)))
                    } else {
                        icon = NSWorkspace.shared.icon(forFile: (url?.path!)!)
                    }
                } else {
                    icon = NSWorkspace.shared.icon(forFile: (url?.path!)!)
                }
            } else {
                // it's a separator, don't bother with the icon
            }
            icon?.size = NSMakeSize(CGFloat(kIconSmallImageSize), CGFloat(kIconSmallImageSize))
        } else if !isSpecialGroup() {
            // it's a folder, use the folderImage as its icon
            icon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(OSType(kGenericFolderIcon)))
            icon?.size = NSMakeSize(CGFloat(kIconSmallImageSize), CGFloat(kIconSmallImageSize))
        }
        return icon
    }
    
    func removeObject(fromChildren obj: NSObject) {
        // remove object from children or the children of any sub-nodes
        for node in children {
            if node == obj {
                children = children.filter({ ($0) as AnyObject !== (obj) as AnyObject })
                return
            }
            if node.isLeaf == false {
                node.removeObject(fromChildren: obj)
            }
        }
    }
    
    func descendants() -> [BaseNode] {
        var descendants:[BaseNode] = [BaseNode]()
        for node:BaseNode in children {
            descendants.append(node)
            if node.isLeaf == false {
                for n:BaseNode in node.descendants() {
                    descendants.append(n)
                }
                // Recursive - will go down the chain to get all
            }
        }
        return descendants
    }
    
    func allChildLeafs() -> [BaseNode] {
        var childLeafs = [BaseNode]()
        for node in children {
            if node.isLeaf == true {
                childLeafs.append(node)
            } else {
                for n in node.allChildLeafs() {
                    childLeafs.append(n)
                }
                // Recursive - will go down the chain to get all
            }
        }
        return childLeafs
    }
    
    func groupChildren() -> [BaseNode]? {
        var groupChildren = [BaseNode]()
        for child in children {
            if child.isLeaf == false {
                groupChildren.append(child)
            }
        }
        return groupChildren
    }
    
    func isDescendantOfOrOne(ofNodes nodes: [BaseNode]?) -> Bool {
        // returns YES if we are contained anywhere inside the array passed in, including inside sub-nodes
        for node in nodes ?? [BaseNode]() {
            if node == self {
                return true
            }
            // we found ourselves
            // check all the sub-nodes
            if node.isLeaf == false {
                if isDescendantOfOrOne(ofNodes: node.children) {
                    return true
                }
            }
        }
        return false
    }
    
    func isDescendantOfNodes(_ nodes: [BaseNode]?) -> Bool {
        for node in nodes ?? [BaseNode]() {
            // check all the sub-nodes
            if node.isLeaf == false {
                if isDescendantOfOrOne(ofNodes: node.children) {
                    return true
                }
            }
        }
        return false
    }
    
    public func mutableKeys() -> [String] {
        return ["nodeTitle", "isLeaf",     // isLeaf MUST come before children for initWithDictionary: to work
            "children", "nodeIcon", "urlString", "isBookmark"]
    }
    
    
    
}
