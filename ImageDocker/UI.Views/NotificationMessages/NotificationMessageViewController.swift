//
//  NotificationMessageViewController.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/4/16.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa


import Cocoa

class NotificationMessageViewController: NSViewController {
    
    let logger = ConsoleLogger(category: "NotificationMessage")
    
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var btnRemoveAll: NSButton!
    
    init() {
        super.init(nibName: "NotificationMessageViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var notificationMessages:[NotificationMessage] = []
    var messagesView:[String:NotificationsViewController] = [:]
    
    // run only once
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.logger.log("popover did load")
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.btnRemoveAll.title = Words.notification_remove_all.word()
        
        self.addNoMessageNotice()
        
        NotificationMessageManager.default.bindToView(view: self).loadMessages()
        
    }
    
    func onPopoverShow() {
//        self.logger.log("popover show")
        for notificationMessage in notificationMessages {
            notificationMessage.notifyChange()
        }
    }
    
    func addNoMessageNotice() {
        let storyboard = NSStoryboard(name: "NotificationMessageStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "NotificationMessages") as! NotificationsViewController
        viewController.noMessage()
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addMessage(notificationMessage:NotificationMessage) -> Bool {
        
        if let _ = self.messagesView[notificationMessage.id] {
            return false
        }
        
        if self.notificationMessages.count == 0 && self.stackView.views.count > 0 {
            let noMessage = self.stackView.views[0]
            self.stackView.removeView(noMessage)
        }
        
        let storyboard = NSStoryboard(name: "NotificationMessageStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "NotificationMessages") as! NotificationsViewController
        
        viewController.initView(notificationMessage: notificationMessage, onRemove: {
            NotificationMessageManager.default.removeMessage(id: notificationMessage.id)
        })
        
        self.notificationMessages.append(notificationMessage)
        self.messagesView[notificationMessage.id] = viewController
        //task.state = "READY"
        stackView.insertArrangedSubview(viewController.view, at: 0)
        //addChildViewController(viewController)
        return true
    }
    
    func removeNotificationMessage(notificationMessage:NotificationMessage) {
        self.notificationMessages.removeAll(where: { (obj) -> Bool in
            return obj.id == notificationMessage.id
        })
        
        if let viewController = self.messagesView[notificationMessage.id] {
            NSLayoutConstraint.deactivate(viewController.view.constraints)
            self.stackView.removeView(viewController.view)
        }
        
        if self.notificationMessages.count == 0 {
            self.addNoMessageNotice()
        }
        
        self.messagesView.removeValue(forKey: notificationMessage.id)
    }
    
    
    @IBAction func onRemoveAllClicked(_ sender: NSButton) {
        NotificationMessageManager.default.removeAllMessages()
    }
    
    
}
