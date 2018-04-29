//
//  FolderSplitViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class FolderSplitViewController : NSSplitViewController {
    
    var verticalConstraints:[NSLayoutConstraint]?
    var horizontalConstraints:[NSLayoutConstraint]?
    
    func outlineViewController() -> OutlineViewController? {
        let leftSplitViewItem:NSSplitViewItem = splitViewItems[0]
        return leftSplitViewItem.viewController as? OutlineViewController
    }
    
    func detailViewController() -> NSViewController? {
        let rightSplitViewItem:NSSplitViewItem = splitViewItems[1]
        return rightSplitViewItem.viewController
    }

    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.outlineViewController()?.treeController?.addObserver(self, forKeyPath: "selectedObjects", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    deinit {
        self.outlineViewController()?.treeController?.removeObserver(self, forKeyPath: "selectedObjects")
    }
    
    func hasChildViewController() -> Bool {
        return (self.detailViewController()?.childViewControllers.count)! > 0
    }
    
    func embedChildViewController(_ childViewController:NSViewController) {
        let currentDetailVC:NSViewController = self.detailViewController()!
        currentDetailVC.addChildViewController(childViewController)
        currentDetailVC.view.addSubview(childViewController.view)
        
        let views:[String : Any] = ["targetView" : childViewController.view]
        horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[targetView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[targetView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: views)
        
        NSLayoutConstraint.activate(self.horizontalConstraints!)
        NSLayoutConstraint.activate(self.verticalConstraints!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "selectedObjects") {
            var currentDetailVC: NSViewController? = detailViewController()
            var treeController = object as? NSTreeController
            // let the outline view controller handle the selection (helps us decide which detail view to use)
            /*
            var vcForDetail: NSViewController? = outlineViewController()?.viewController(forSelection: treeController?.selectedNodes)
            if vcForDetail != nil {
                if hasChildViewController() && currentDetailVC?.childViewControllers[0] != vcForDetail {
                    // the incoming child view controller is different from the one we currently have,
                    // remove the old one and add the new one
                    //
                    currentDetailVC?.removeChildViewController(at: 0)
                    detailViewController.view.subviews[0].removeFromSuperview()
                    embedChildViewController(vcForDetail)
                }else{
                    if !hasChildViewController() {
                        // we don't have a child view controller so embed the new one
                        embedChildViewController(vcForDetail)
                    }
                }
            }else{
                // we don't have a child view controller to embed (no selection), so remove current child view controller
                
                if hasChildViewController() {
                    currentDetailVC.removeChildViewController(at: 0)
                    detailViewController.view.subviews[0].removeFromSuperview()
                }

            }
 */
        }
    }
}
