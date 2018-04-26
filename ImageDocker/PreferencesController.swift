//
//  PreferencesController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

final class PreferencesController: NSViewController {
    
    static let baiduAKKey = "BaiduAKKey"
    static let baiduSKKey = "BaiduSKKey"
    
    // MARK: Properties
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    
    
    // MARK: Actions
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    class func baiduAK() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: baiduAKKey) else {return ""}
        return txt
    }
    
    class func baiduSK() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: baiduSKKey) else {return ""}
        return txt
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        defaults.set(txtBaiduAK.stringValue,
                     forKey: PreferencesController.baiduAKKey)
        defaults.set(txtBaiduSK.stringValue,
                     forKey: PreferencesController.baiduSKKey)

    }
    
    class func healthCheck() {
        
        if baiduAK() == "" || baiduSK() == "" {
            
            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
            alert.messageText = NSLocalizedString("Please setup API keys", comment: "Please setup API keys")
            alert.informativeText = NSLocalizedString("Please specify Baidu AK and SK in Preferences menu/dialog.", comment: "Please specify Baidu AK and SK in Preferences menu/dialog.")
            alert.runModal()
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        txtBaiduAK.stringValue = PreferencesController.baiduAK()
        txtBaiduSK.stringValue = PreferencesController.baiduSK()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
