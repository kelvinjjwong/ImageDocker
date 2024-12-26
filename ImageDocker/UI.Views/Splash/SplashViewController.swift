//
//  SplashViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/13.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import SwiftyGifMac

class SplashViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "Startup", subCategory: "Splash")
    
    @IBOutlet weak var Gif1: NSImageView!
    @IBOutlet weak var Gif2: NSImageView!
    @IBOutlet weak var Gif3: NSImageView!
    @IBOutlet weak var Gif4: NSImageView!
    @IBOutlet weak var Gif5: NSImageView!
    @IBOutlet weak var Gif6: NSImageView!
    @IBOutlet weak var Gif7: NSImageView!
    
    
    // MARK: PROPERTIES
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnRetry: NSButton!
    @IBOutlet weak var btnQuit: NSButton!
    @IBOutlet weak var btnAbort: NSButton!
    @IBOutlet weak var lblProgress: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var lblSubMessage: NSTextField!
    @IBOutlet weak var lblSubProgress: NSTextField!
    @IBOutlet weak var subProgressIndicator: NSProgressIndicator!
    
    required init?(coder: NSCoder) {
        self.onStartup = {}
        self.onCompleted = {}
        super.init(coder: coder)
    }
    
    fileprivate var onStartup: (() -> Void)
    fileprivate var onCompleted: (() -> Void)
    
    init(onStartup: @escaping (() -> Void), onCompleted: @escaping (() -> Void)) {
        self.onStartup = onStartup
        self.onCompleted = onCompleted
        super.init(nibName: "SplashViewController", bundle: nil)
    }
    
    var screenDockHeight = -1
    var screenDockPosition = "N/A"
    
    func onScreenDockHeightDetected(position:String, height:Int) {
        var changed = (position != self.screenDockPosition || height != self.screenDockHeight)
        self.screenDockHeight = height
        self.screenDockPosition = position
        // do on changed
        if(changed) {
            // ....
        }
    }
    
    func whereIsDock() {
        
        if let screen = self.view.window?.screen {
            let visibleFrame = screen.visibleFrame
            let screenFrame = screen.frame
            
            if (visibleFrame.origin.x > screenFrame.origin.x) {
                self.onScreenDockHeightDetected(position: "LEFT", height: Int(visibleFrame.origin.x - screenFrame.origin.x))
                self.logger.log(.trace, "[SPLASH-VIEW] Dock is positioned on the LEFT")
                self.logger.log(.trace, "[SPLASH-VIEW] Dock width: \(visibleFrame.origin.x - screenFrame.origin.x)")
            } else if (visibleFrame.origin.y > screenFrame.origin.y) {
                self.onScreenDockHeightDetected(position: "BOTTOM", height: Int(visibleFrame.origin.y - screenFrame.origin.y))
                self.logger.log(.trace, "[SPLASH-VIEW] Dock is positioned on the BOTTOM")
                self.logger.log(.trace, "[SPLASH-VIEW] Dock height: \(visibleFrame.origin.y - screenFrame.origin.y)")
            } else if (visibleFrame.size.width < screenFrame.size.width) {
                self.onScreenDockHeightDetected(position: "RIGHT", height: Int(screenFrame.size.width - visibleFrame.size.width))
            } else {
                self.onScreenDockHeightDetected(position: "HIDDEN", height: 0)
                self.logger.log(.trace, "[SPLASH-VIEW] Dock is HIDDEN");
            }
        }else {
            self.onScreenDockHeightDetected(position: "N/A", height: -1)
            self.logger.log(.trace, "[SPLASH-VIEW] CANNOT DETECT DOCK")
        }
    }
    
    override func viewDidAppear() {
        whereIsDock()
        if !(self.view.window?.isZoomed ?? true) {
            self.view.window?.performZoom(self)
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
//        whereIsDock()
        if !(self.view.window?.isZoomed ?? true) {
            self.view.window?.performZoom(self)
        }
        self.view.layer?.backgroundColor = Colors.DarkGray.cgColor
        
        self.btnAbort.isHidden = true
        self.btnRetry.isHidden = true
        self.btnQuit.isHidden = true
        
        self.lblSubMessage.isHidden = true
        self.lblSubProgress.isHidden = true
        self.subProgressIndicator.isHidden = true
        
        self.lblProgress.stringValue = "0 %"
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = 100
        self.progressIndicator.doubleValue = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(beginSubProgress(notification:)), name: NSNotification.Name(rawValue: "FOLDERSETTER_BEGIN"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setTotalOfSubProgress(notification:)), name: NSNotification.Name(rawValue: "FOLDERSETTER_TOTAL"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(increSubProgress(notification:)), name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
        
        self.Gif1.alphaValue = 0.1
        self.Gif2.alphaValue = 0.1
        self.Gif3.alphaValue = 0.1
        self.Gif4.alphaValue = 0.1
        self.Gif5.alphaValue = 0.1
        self.Gif6.alphaValue = 0.1
        self.Gif7.alphaValue = 0.1
        Icons.show_gif(name: "running2", view: self.Gif1)
        Icons.show_gif(name: "running", view: self.Gif2)
        Icons.show_gif(name: "sailing", view: self.Gif3)
        Icons.show_gif(name: "boating", view: self.Gif4)
        Icons.show_gif(name: "flying", view: self.Gif5)
        Icons.show_gif(name: "forward", view: self.Gif6)
        Icons.show_gif(name: "open-box", view: self.Gif7)
        
        self.onStartup()
    }
    
    func showSubMessage(message: String) {
        DispatchQueue.main.async {
            self.lblSubMessage.isHidden = false
            self.lblSubMessage.stringValue = message
        }
    }
    
    func hideSubMessage() {
        DispatchQueue.main.async {
            self.lblSubMessage.stringValue = ""
            self.lblSubMessage.isHidden = true
        }
    }
    
    @objc func beginSubProgress(notification:Notification){
//        self.logger.log(.trace, "BEGIN SUB PROGRESS")
        DispatchQueue.main.async {
            self.subProgressIndicator.minValue = 0
            self.subProgressIndicator.maxValue = 100
            self.subProgressIndicator.doubleValue = 0
            
            self.lblSubMessage.stringValue = Words.splash_prepareingFolders.word()
            self.lblSubMessage.isHidden = false
            self.lblSubProgress.isHidden = true
            self.subProgressIndicator.isHidden = false
        }
    }
    
    @objc func increSubProgress(notification:Notification){
        
//        self.logger.log(.trace, "INCREASE SUB PROGRESS BY 1")
        DispatchQueue.main.async {
            self.subProgressIndicator.increment(by: 1)
            let value = Int(self.subProgressIndicator.doubleValue)
            let total = Int(self.subProgressIndicator.maxValue)
            self.lblSubProgress.stringValue = "\(value) / \(total)"
            
//            self.logger.log(.trace, "value=\(value), total=\(total)")
            
            if value == total {
                self.lblSubMessage.isHidden = true
                self.lblSubProgress.isHidden = true
                self.subProgressIndicator.isHidden = true
                
                self.message(Words.splash_preparingUI.word(), progress: 6)
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FOLDERSETTER_BEGIN"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FOLDERSETTER_TOTAL"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
            }
        }
    }
    
    @objc func setTotalOfSubProgress(notification:Notification){
        if let obj = notification.object {
            let total = obj as? Int ?? 0
//            self.logger.log(.trace, "SET SUB TOTAL TO \(total)")
            DispatchQueue.main.async {
                self.subProgressIndicator.minValue = 0
                self.subProgressIndicator.maxValue = Double(total)
                self.subProgressIndicator.doubleValue = 0
                self.lblSubProgress.stringValue = "0 / \(total)"
                self.lblSubProgress.isHidden = false
            }
        }
    }
    
    func progressWillEnd(at:Int) {
        self.progressEnd = at
        DispatchQueue.main.async {
            self.progressIndicator.maxValue = Double(at)
            self.progressIndicator.isHidden = false
        }
    }
    
    fileprivate var progressEnd = 0
    var progressStage = 0
    var progressStep = 0
    
    func message(_ value:String, progress:Int){
        DispatchQueue.main.async {
            self.lblMessage.stringValue = value
            
//            self.logger.log(.trace, "progressStage=\(self.progressStage)")
            
            if self.progressStage != progress {
                // progress indicator + 1
                self.progressStep += 1
                
                let ratio = self.progressStep * 100 / self.progressEnd
                self.lblProgress.stringValue = "\(ratio) %"
                self.progressIndicator.increment(by: 1)
                
                self.progressStage = progress
                
//                self.logger.log(.trace, "message=\(value)")
//                self.logger.log(.trace, "progress=\(progress), step=\(self.progressStep), end=\(self.progressEnd)")
                
                if self.progressStep >= self.progressEnd {
                    self.onCompleted()
                }
            }
        }
    }
    
    var cancelWaiting = false
    var decideQuit = false
    
    func showRetry(_ countdown:Int){
        DispatchQueue.main.async {
            self.btnRetry.title = "Retry (\(countdown))"
            self.btnRetry.isHidden = false
            self.btnQuit.isHidden = true
            self.btnAbort.isHidden = false
        }
    }
    
    func hideRetry() {
        DispatchQueue.main.async {
            self.btnRetry.isHidden = true
            self.btnQuit.isHidden = true
            self.btnAbort.isHidden = true
        }
    }
    
    func showQuit(disableButton:Bool = false) {
        DispatchQueue.main.async {
            self.btnQuit.isHidden = false
            self.btnRetry.isHidden = true
            self.btnAbort.isHidden = true
            if disableButton {
                self.btnQuit.isEnabled = false
            }
        }
    }
    
    func showQuit(countdown:Int, disableButton:Bool = false, onComplete: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            let quitTitle = self.btnQuit.title
            self.btnQuit.isHidden = false
            self.btnRetry.isHidden = true
            self.btnAbort.isHidden = true
            if disableButton {
                self.btnQuit.isEnabled = false
            }
            
            var secondsRemaining = countdown
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
                    if secondsRemaining > 0 {
                        print ("Countdown \(secondsRemaining) seconds to Quit")
                        secondsRemaining -= 1
                        DispatchQueue.main.async {
                            self.btnQuit.title = "\(quitTitle) (\(secondsRemaining))"
                        }
                    } else {
                        Timer.invalidate()
                        DispatchQueue.main.async {
                            onComplete()
                        }
                    }
                }
        }
    }
    
    @IBAction func onQuitClicked(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func onRetryClicked(_ sender: NSButton) {
        self.cancelWaiting = true
    }
    
    @IBAction func onAbortClicked(_ sender: NSButton) {
        self.cancelWaiting = true
        self.decideQuit = true
        DispatchQueue.main.async {
            self.lblMessage.stringValue = "Quiting ..."
            self.btnRetry.isHidden = true
            self.btnQuit.isHidden = true
            self.btnAbort.isHidden = true
            self.lblProgress.isHidden = true
            self.progressIndicator.isHidden = true
        }
    }
    
}
