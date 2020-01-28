//
//  BaseViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class CustomStackView : NSStackView {
    
    override var isFlipped: Bool { return true }
}

class StackBodyViewController : NSViewController, StackItemBody {
    
    static let StackItemBackgroundColor = NSColor.darkGray // NSColor(calibratedRed: 244/255, green:244/255, blue:244/255, alpha:1)
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    var initialWidth:CGFloat = 0
    var initialHeight:CGFloat = 0
    var savedDefaultHeight: CGFloat = 0
    var disclosureState: StackItemContainer.DisclosureState = .open
    
    // Subclasses determine the header title.
    func headerTitle() -> String { return "" }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if initialWidth > 0 {
            self.view.setWidth(initialWidth)
        }
        if initialHeight > 0 {
            self.view.setHeight(initialHeight)
        }
        savedDefaultHeight = view.bounds.height
        
        view.wantsLayer = true
        view.layer?.backgroundColor = StackBodyViewController.StackItemBackgroundColor.cgColor
    }
    
    // MARK: - StackItemBody
    
    lazy var stackItemContainer: StackItemContainer? = {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("StackHeaderViewController"), bundle: nil)
        guard let header = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("HeaderTriangleViewController")) as? StackHeaderViewController else {
            return .none
        }
        header.title = self.headerTitle()
        
        
        return StackItemContainer(header: header, body: self, state: self.disclosureState)
    }()
    
}
