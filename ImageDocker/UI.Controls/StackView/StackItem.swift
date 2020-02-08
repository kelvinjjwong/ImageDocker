//
//  StackItem.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

// MARK: Protocol Delarations -

// The hosting object containing both the header and body.
protocol StackItemHost : class {
    
    func disclose(_ stackItem: StackItemContainer)
}

// The object containing the header portion.
protocol StackItemHeader : class {
    
    var viewController: NSViewController { get }
    var disclose: (() -> ())? { get set }
    
    var beforeExpand: (() -> ())? { get set }
    
    var afterExpand: (() -> ())? { get set }
    
    var gotoAction: ((String) -> ())? { get set }
    
    var filterAction: ((String) -> ())? { get set }
    
    var moreAction: ((NSButton) -> ())? { get set }
    
    func update(toDisclosureState: StackItemContainer.DisclosureState)
}

// The object containing the main body portion.
protocol StackItemBody : class {
    
    var viewController: NSViewController { get }
    
    func show(animated: Bool)
    func hide(animated: Bool)
}

// MARK: - Protocol implementations -

extension StackItemHost {
    
    func disclose(_ stackItem: StackItemContainer) {
        
        switch stackItem.state {
        case .open:
            hide(stackItem, animated: true)
            
        case .closed:
            show(stackItem, animated: true)
        }
    }
    
    func show(_ stackItem: StackItemContainer, animated: Bool) {
        
        // TODO: close others first
        
        if stackItem.header.beforeExpand != nil {
            stackItem.header.beforeExpand!()
        }
        
        // Show the stackItem's body content.
        stackItem.body.show(animated: animated)
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .open)
        stackItem.state = .open
        
        if stackItem.header.afterExpand != nil {
            stackItem.header.afterExpand!()
        }
    }
    
    func hide(_ stackItem: StackItemContainer, animated: Bool) {
        // Hide the stackItem's body content.
        stackItem.body.hide(animated: animated)
        
        // Update the stackItem's header button state.
        stackItem.header.update(toDisclosureState: .closed)
        stackItem.state = .closed
    }
    
}

// MARK:
extension StackItemHeader where Self : NSViewController {
    
    var viewController: NSViewController { return self }
}

// MARK: -
extension StackItemBody where Self : NSViewController {
    
    var viewController: NSViewController { return self }
    
    func animateDisclosure(disclose: Bool, animated: Bool) {
        let viewController = self as! StackBodyViewController
        if let constraint = viewController.heightConstraint {
            
            let heightValue = disclose ? viewController.savedDefaultHeight : 0

            if animated {
                NSAnimationContext.runAnimationGroup({ (context) -> Void in
                    context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    constraint.animator().constant = heightValue
                    
                }, completionHandler: { () -> Void in
                    // animation completed
                })
            }
            else {
                constraint.constant = heightValue
            }
        }else{
            print("no constraint")
        }
    }
    
    func show(animated: Bool) {
        animateDisclosure(disclose: true, animated: animated)
    }
    
    func hide(animated: Bool) {
        animateDisclosure(disclose: false, animated: animated)
    }
    
}

// MARK: -
class StackItemContainer {
    
    // Content view disclosure states.
    enum DisclosureState : Int {
        case open = 0
        case closed = 1
    }
    
    let header: StackItemHeader
    var state: DisclosureState
    
    let body: StackItemBody
    
    init(header: StackItemHeader, body: StackItemBody, state: DisclosureState) {
        self.header = header
        self.body = body
        self.state = state
    }
    
}



