//
//  NotificationViewController.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/4/16.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

class NotificationsViewController : NSViewController {
    
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var box: NSBox!
    
    private var notificationMessage:NotificationMessage = NotificationMessage(type: "", name: "")
    
    init() {
        super.init(nibName: "NotificationsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var id = ""
    var message = ""
    var onRemove: (() -> Void)? = nil
    var isNoMessage = false
    
    func noMessage() {
        self.id = Words.notifications_no_message.word()
        self.message = Words.notifications_no_message.word()
        self.isNoMessage = true
    }
    
    func initView(notificationMessage:NotificationMessage,
                  onRemove: (() -> Void)? = nil){
        self.notificationMessage = notificationMessage
        self.id = "\(notificationMessage.type.uppercased()): \(notificationMessage.name)"
        self.message = notificationMessage.message
        self.onRemove = onRemove
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.box.title = self.id
        self.lblMessage.stringValue = self.message
        if self.isNoMessage {
            self.btnRemove.isHidden = true
        }
        
    }
    
    @IBAction func onRemoveClicked(_ sender: NSButton) {
        if self.onRemove != nil {
            self.onRemove!()
        }
    }
    
}
