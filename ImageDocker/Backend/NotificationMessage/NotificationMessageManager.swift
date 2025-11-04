//
//  NotificationMessageManager.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/4/16.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory


class NotificationMessage {
    
    let logger = LoggerFactory.get(category: "NotificationMessage", types: [.debug])
    
    var type = "notification"
    var id = ""
    var name = ""
    var message = ""
    var time:Date
    var msgid = ""
    var state = ""
    
    var taskCode: ((NotificationMessage) -> Void)? = nil
    
    var stopTaskCode: ((NotificationMessage) -> Void)? = nil
    
    init(type:String, name:String) {
        self.id = UUID().uuidString
        self.msgid = "MSG_\(id)"
        self.name = name
        self.type = type
        self.time = Date()
    }
    
    func notifyChange(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: msgid), object: self)
    }
    
    @objc func onNotificationMessageChanged(notification: NSNotification) {
        NotificationMessageManager.default.onNotificationMessageChanged(notification: notification)
    }
    
    func changeListener(selector:Selector){
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: msgid), object: nil)
    }
    
    func removeListener() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: msgid), object: nil)
    }
    
    func toString() -> String {
        let str = """
{type:\(type), id:\(id), msgid:\(msgid), name:"\(name)", message:"\(message)", time:\(time)}
"""
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}



struct NotificationMessagesStatus {
    var totalCount = 0
    
    public init(total:Int) {
        self.totalCount = total
    }
}

class NotificationMessageManager {
    
    static let NOTIFICATION_KEY_MESSAGECOUNT = "Notification_Message_Count"
    
    let logger = LoggerFactory.get(category: "NotificationMessageManager", types: [.debug])
    
    static let `default` = NotificationMessageManager()
    
    var viewManager:NotificationMessageViewController? = nil
    
    func bindToView(view:NotificationMessageViewController) -> NotificationMessageManager {
        self.viewManager = view
        return self
    }
    
    var notificationMessages:[NotificationMessage] = []
    
    // MARK: - QUEUE for SINGLE MODE
    
    private var queue = Queue<NotificationMessage>()
    
    public init() {
    }
    
    // MARK: - SINGLE THREAD MODE QUEUE TIMER
    
    func isSingleMode() -> Bool {
        return false
    }
    
    func updateMessagesCountInMainWindow() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationMessageManager.NOTIFICATION_KEY_MESSAGECOUNT), object: NotificationMessagesStatus(total: self.notificationMessages.count))
    }
    
    func printQueuedMessages() {
        self.logger.log(.trace, "==========================")
        self.logger.log(.trace, "Queued messages: \(self.queue.list.count)")
        for notificationMessage in self.queue.list {
            self.logger.log(.trace, "\(notificationMessage.name) - \(notificationMessage.message)")
        }
        self.logger.log(.trace, "==========================")
    }
    
    private func pushMessageToQueue(message:NotificationMessage, toEnd:Bool = false) {
        if toEnd {
            self.queue.list.removeAll { (obj) -> Bool in
                return obj.id == message.id
            }
            self.queue.enqueue(message)
        }else{
            if !self.isInQueue(message: message) {
                self.queue.enqueue(message)
            }
        }
    }
    
    private func isInQueue(message:NotificationMessage) -> Bool {
        if self.queue.isEmpty {
            return false
        }else{
            return self.queue.list.contains(where: { obj -> Bool in
                return obj.id == message.id
            })
        }
    }
    
    // MARK: - GET NotificationMessage
    
    private func getMessage(type:String, name:String) -> NotificationMessage? {
        var t:NotificationMessage? = nil
        for notificationMessage in notificationMessages {
            if notificationMessage.name == name && notificationMessage.type == type {
                t = notificationMessage
                break
            }
        }
        return t
    }
    
    private func getMessage(id:String) -> NotificationMessage? {
        var t:NotificationMessage? = nil
        for notificationMessage in notificationMessages {
            if notificationMessage.id == id {
                t = notificationMessage
                break
            }
        }
        return t
    }
    
    // MARK: - CREATE NOTIFICATION MESSAGE
    
    func notificationMessage(type:String, name:String, message:String) -> NotificationMessage {
        if let msg = self.getMessage(type: type, name: name) {
            msg.state = "READY"
            return msg
        }else {
            let msg = NotificationMessage(type:type, name:name)
            msg.message = message
            msg.state = "READY"
            msg.changeListener(selector: #selector(self.onNotificationMessageChanged))
            self.notificationMessages.append(msg)
            if let view = self.viewManager {
                let _ = view.addMessage(notificationMessage: msg)
            }
            return msg
        }
    }
    
    // MARK: - TASK's CHANGE LISTENER
    
    @objc func onNotificationMessageChanged(notification: NSNotification) {
        for notificationMessage in notificationMessages {
            if notificationMessage.msgid == notification.name.rawValue {
                
//                self.logger.log(.trace, "onNotificationMessageChanged: \(notificationMessage.id)")
                //self.logger.log(.trace, "=== onTaskChanged - \(task.taskid) - \(task.state)")
                //self.logger.log(.trace, "viewManager is nil ? \(viewManager == nil)")
                if let stackViewManager = viewManager {
                    if let viewController = stackViewManager.messagesView[notificationMessage.id] {
                        DispatchQueue.main.async {
                            viewController.updateTimeElapsed()
                        }
                    }
                }
                break
            }
        }
    }
    
    func removeMessage(type:String, name:String) {
        if let message = self.getMessage(type: type, name: name) {
            self.removeMessage(notificationMessage: message)
        }
    }
    
    func removeMessage(id:String) {
        if let message = self.getMessage(id: id) {
            self.removeMessage(notificationMessage: message)
        }
    }
    
    private func removeMessage(notificationMessage:NotificationMessage) {
        notificationMessage.state = "REMOVED"
        self.notificationMessages.removeAll { (obj) -> Bool in
            return notificationMessage.id == obj.id
        }
        
        if let view = self.viewManager {
            view.removeNotificationMessage(notificationMessage: notificationMessage)
        }
        
        self.updateMessagesCountInMainWindow()
    }
    
    // MARK: - CREATE AND EXECUTE TASK
    
    func createNotificationMessage(type:String, name:String, message:String) -> NotificationMessage {
        let notificationMessage = self.notificationMessage(type: type, name: name, message: message)
        self.pushMessageToQueue(message: notificationMessage)
        self.updateMessagesCountInMainWindow()
        return notificationMessage
    }
    
    // MARK: - FOR ALL TASKS
    
    func loadMessages() {
        if let view = self.viewManager {
            for notificationMessage in self.notificationMessages {
                if view.addMessage(notificationMessage: notificationMessage) {
                    
                }
            }
            
            self.updateMessagesCountInMainWindow()
        }
    }
    
    func removeAllMessages() {
        if let view = self.viewManager {
            for notificationMessage in self.notificationMessages {
                self.removeMessage(notificationMessage: notificationMessage)
            }
        }
        
        self.updateMessagesCountInMainWindow()
    }
    
    func printAll() {
        self.logger.log(.trace, "===================================")
        self.logger.log(.trace, "Listing all messages ...")
        for notificationMessage in self.notificationMessages {
            self.logger.log(notificationMessage.toString())
        }
        self.logger.log(.trace, "===================================")
    }
    
}
