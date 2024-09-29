//
//  TreeNodeData.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/29.
//  Copyright © 2024 nonamecat. All rights reserved.
//
import Cocoa

public protocol TreeNodeData {
    
    func getId() -> String
    
    func getText() -> String
    
    func setCheckState(state:Bool)
    
    func isCheckable() -> Bool
    
    func nodeIcon() -> NSImage
    
    func actionIcon() -> NSImage
    
    func isEditable() -> Bool
    
    func checked() -> Bool
    
    func expandable() -> Bool
    
    func getChildren() -> [TreeNodeData]
    
    func setParent(_ parent:TreeNodeData)
    
    func getParent() -> TreeNodeData?
    
    func addChild(_ child:TreeNodeData)
}


public class CoreMember : TreeNodeData {
    var id:String = ""
    var name:String = ""
    var nickname:String = ""
    var isChecked = false
    
    var groups:[PeopleGroup] = []
    
    public func getId() -> String {
        return self.id
    }
    
    public func getText() -> String {
        return self.nickname
    }
    
    public func setCheckState(state:Bool) {
        self.isChecked = state
    }
    
    public func checked() -> Bool {
        return self.isChecked
    }
    
    public func isCheckable() -> Bool {
        return false
    }
    
    public func nodeIcon() -> NSImage {
        return Icons.person
    }
    
    public func actionIcon() -> NSImage {
        return NSImage.init(named: NSImage.addTemplateName)!
    }
    
    public func isEditable() -> Bool {
        return false
    }
    
    public func expandable() -> Bool {
        return true
    }
    
    public func getChildren() -> [TreeNodeData] {
        return self.groups
    }
    
    public func setParent(_ parent:TreeNodeData) {}
    
    public func getParent() -> TreeNodeData? {
        return nil
    }
    
    public func addChild(_ child:TreeNodeData) {
        if let child = child as? PeopleGroup {
            self.groups.append(child)
        }
    }
}

public class PeopleGroup : TreeNodeData {
    var id:String = ""
    var name:String = ""
    var parent:CoreMember? = nil
    var members:[PeopleGroupMember] = []
    var isChecked = false
    
    public func getId() -> String {
        return self.id
    }
    
    public func getText() -> String {
        return self.name
    }
    
    public func setCheckState(state:Bool) {
        self.isChecked = state
    }
    
    public func checked() -> Bool {
        return self.isChecked
    }
    
    public func isCheckable() -> Bool {
        return true
    }
    
    public func nodeIcon() -> NSImage {
        return Icons.people
    }
    
    public func actionIcon() -> NSImage {
        return Icons.remove
    }
    
    public func isEditable() -> Bool {
        return true
    }
    
    public func expandable() -> Bool {
        return true
    }
    
    public func getChildren() -> [TreeNodeData] {
        return self.members
    }
    
    public func setParent(_ parent:TreeNodeData) {
        if let parent = parent as? CoreMember {
            self.parent = parent
        }
    }
    
    public func getParent() -> TreeNodeData? {
        return self.parent
    }
    
    public func addChild(_ child:TreeNodeData) {
        if let child = child as? PeopleGroupMember {
            self.members.append(child)
        }
    }
    
    public static let default_group_category = "亲友"
}

public class PeopleGroupMember : TreeNodeData {
    var id:String = ""
    var name:String = ""
    var nickname:String = ""
    var groupId:String = ""
    var groupName:String = ""
    var parent:PeopleGroup? = nil
    var isChecked = false
    
    public func getId() -> String {
        return self.id
    }
    
    public func getText() -> String {
        return self.nickname
    }
    
    public func setCheckState(state:Bool) {
        self.isChecked = state
    }
    
    public func checked() -> Bool {
        return self.isChecked
    }
    
    public func isCheckable() -> Bool {
        return true
    }
    
    public func nodeIcon() -> NSImage {
        return Icons.smile
    }
    
    public func actionIcon() -> NSImage {
        return Icons.remove
    }
    
    public func isEditable() -> Bool {
        return false
    }
    
    public func expandable() -> Bool {
        return false
    }
    
    public func getChildren() -> [TreeNodeData] {
        return []
    }
    
    public func setParent(_ parent:TreeNodeData) {
        if let parent = parent as? PeopleGroup {
            self.parent = parent
        }
    }
    
    public func getParent() -> TreeNodeData? {
        return self.parent
    }
    
    public func addChild(_ child:TreeNodeData) {}
}
