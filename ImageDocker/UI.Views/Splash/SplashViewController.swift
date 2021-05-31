//
//  SplashViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/13.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class SplashViewController: NSViewController {
    
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
    
    override func viewDidAppear() {
        if !(self.view.window?.isZoomed ?? true) {
            self.view.window?.performZoom(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
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
        
        self.onStartup()
    }
    
    @objc func beginSubProgress(notification:Notification){
//        print("BEGIN SUB PROGRESS")
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
        
//        print("INCREASE SUB PROGRESS BY 1")
        DispatchQueue.main.async {
            self.subProgressIndicator.increment(by: 1)
            let value = Int(self.subProgressIndicator.doubleValue)
            let total = Int(self.subProgressIndicator.maxValue)
            self.lblSubProgress.stringValue = "\(value) / \(total)"
            
//            print("value=\(value), total=\(total)")
            
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
//            print("SET SUB TOTAL TO \(total)")
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
            
//            print("progressStage=\(self.progressStage)")
            
            if self.progressStage != progress {
                // progress indicator + 1
                self.progressStep += 1
                
                let ratio = self.progressStep * 100 / self.progressEnd
                self.lblProgress.stringValue = "\(ratio) %"
                self.progressIndicator.increment(by: 1)
                
                self.progressStage = progress
                
//                print("message=\(value)")
//                print("progress=\(progress), step=\(self.progressStep), end=\(self.progressEnd)")
                
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
    
    func showQuit() {
        DispatchQueue.main.async {
            self.btnQuit.isHidden = false
            self.btnRetry.isHidden = true
            self.btnAbort.isHidden = true
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
