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
    static let exportPathKey = "ExportPath"
    
    // MARK: Properties
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    @IBOutlet weak var txtExportPath: NSTextField!
    
    
    // MARK: Actions
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    @IBAction func onButtonBrowseClicked(_ sender: Any) {
        //let window = NSApplication.shared.windows.first!
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtExportPath.stringValue = path
                }
            }
        }
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
    
    class func exportDirectory() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: exportPathKey) else {return ""}
        return txt
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        defaults.set(txtBaiduAK.stringValue,
                     forKey: PreferencesController.baiduAKKey)
        defaults.set(txtBaiduSK.stringValue,
                     forKey: PreferencesController.baiduSKKey)
        defaults.set(txtExportPath.stringValue,
                     forKey: PreferencesController.exportPathKey)

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
        txtExportPath.stringValue = PreferencesController.exportDirectory()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
