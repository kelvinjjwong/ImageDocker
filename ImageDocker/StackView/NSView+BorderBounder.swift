//
//  NSView+BorderBounder.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension NSView {
    
    func boundToSuperView(superview:NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.top, .bottom, .right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: self, attribute: $0, relatedBy: .equal, toItem: superview, attribute: $0, multiplier: 1, constant: 0)
        })
    }
    
    func boundXToSuperView() {
        if let superview = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            let attributes: [NSLayoutConstraint.Attribute] = [.right, .left]
            NSLayoutConstraint.activate(attributes.map {
                NSLayoutConstraint(item: self, attribute: $0, relatedBy: .equal, toItem: superview, attribute: $0, multiplier: 1, constant: 0)
            })
        }
    }
    
    func boundXToSuperView(superview:NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [.right, .left]
        NSLayoutConstraint.activate(attributes.map {
            NSLayoutConstraint(item: self, attribute: $0, relatedBy: .equal, toItem: superview, attribute: $0, multiplier: 1, constant: 0)
        })
    }
    
    func setHeight(_ height:CGFloat){
        let f = self.frame
        self.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.width, height: height);
        
    }
    
    
    
    func setWidth(_ width:CGFloat){
        let f = self.frame
        self.frame = CGRect(x: f.origin.x, y: f.origin.y, width: width, height: f.height);
        
    }

}
