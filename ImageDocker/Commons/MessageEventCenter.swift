//
//  MessageEventCenter.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/30.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Foundation

struct MessageType {
    static let GLOBAL_NOTIFICATION = NSNotification.Name(rawValue: "GLOBAL_NOTIFICATION")
    static let DEVICE_CONNECT_NOTIFICATION = NSNotification.Name(rawValue: "DEVICE_CONNECT_NOTIFICATION")
    static let DEVICE_DISCONNECT_NOTIFICATION = NSNotification.Name(rawValue: "DEVICE_DISCONNECT_NOTIFICATION")
    static let IP_ADDRESS_NOTIFICATION = NSNotification.Name(rawValue: "IP_ADDRESS_NOTIFICATION")
}

class MessageEventCenter {
    
    static let `default` = MessageEventCenter()
    
    // mandatory functions
    var messagePresenter: ( (String) -> Void )?
    
    // event observers
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(showMessage(notification:)), name: MessageType.GLOBAL_NOTIFICATION, object: nil)
    }
    
    // event handlers
    @objc func showMessage(notification:Notification){
        if let msg = (notification.object as? String) {
            self.messagePresenter?(msg)
        }
    }
    
    // event pusher
    func showMessage(message:String){
        NotificationCenter.default.post(name: MessageType.GLOBAL_NOTIFICATION, object: message)
    }
    
    func showMessage(type:String, name:String, message:String){
//        NotificationCenter.default.post(name: MessageType.GLOBAL_NOTIFICATION, object: message)
        DispatchQueue.main.async {
            NotificationMessageManager.default.createNotificationMessage(type: type, name: name, message: message)
        }
    }
}
