//
//  ExternalAPIController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/2/12.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Cocoa

final class ExternalAPIController: NSViewController {
    
    let logger = ConsoleLogger(category: "ExternalAPIController")
    
    // MARK: GEOLOCATION API
    fileprivate static let baiduAKKey = "BaiduAKKey"
    fileprivate static let baiduSKKey = "BaiduSKKey"
    fileprivate static let googleAKKey = "GoogleAPIKey"
    
    @IBOutlet weak var tabs: NSTabView!
    
    @IBOutlet weak var btnApply: NSButton!
    
    
    // MARK: GEOLOCATION API
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    @IBOutlet weak var txtGoogleAPIKey: NSTextField!
    
    @IBOutlet weak var boxBaiduMap: NSBox!
    @IBOutlet weak var boxGoogleMap: NSBox!
    @IBOutlet weak var lblBaiduMapPrompt: NSTextField!
    @IBOutlet weak var lblGoogleMapPrompt: NSTextField!
    
    // MARK: - SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    // MARK: - ACTION FOR GEOLOCATION API SECTION
    
    @IBAction func onBaiduLinkClicked(_ sender: Any) {
        if let url = URL(string: "http://lbsyun.baidu.com"),
            NSWorkspace.shared.open(url) {
            self.logger.log("triggered link \(url)")
        }
    }
    
    @IBAction func onGoogleLinkClicked(_ sender: Any) {
        if let url = URL(string: "https://developers.google.com/maps/documentation/maps-static/intro"),
            NSWorkspace.shared.open(url) {
            self.logger.log("triggered link \(url)")
        }
    }
    
    // MARK: GEOLOCATION API
    
    
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
    
    class func googleAPIKey() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: googleAKKey) else {return ""}
        return txt
    }
    
    func saveGeolocationAPISection(_ defaults:UserDefaults) {
        
        defaults.set(txtGoogleAPIKey.stringValue,
                     forKey: ExternalAPIController.googleAKKey)
        defaults.set(txtBaiduAK.stringValue,
                     forKey: ExternalAPIController.baiduAKKey)
        defaults.set(txtBaiduSK.stringValue,
                     forKey: ExternalAPIController.baiduSKKey)
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveGeolocationAPISection(defaults)
    }
    
    // MARK: - HEALTH CHECK
    
    class func healthCheck() {
        
        if baiduAK() == "" || baiduSK() == "" {
            // TODO: notify user when geolocation API missing
            //Alert.invalidBaiduMapAK()
            return
        }
    }
    
    // MARK: - INIT SECTIONS
    
    func initGeolocationAPISection() {
        self.boxBaiduMap.title = Words.preference_tab_geo_location_api_box_baidu.word()
        self.boxGoogleMap.title = Words.preference_tab_geo_location_api_box_google.word()
        self.lblBaiduMapPrompt.stringValue = Words.preference_tab_geo_location_api_prompt.word()
        self.lblGoogleMapPrompt.stringValue = Words.preference_tab_geo_location_api_prompt.word()
        
        txtBaiduAK.stringValue = PreferencesController.baiduAK()
        txtBaiduSK.stringValue = PreferencesController.baiduSK()
        txtGoogleAPIKey.stringValue = PreferencesController.googleAPIKey()
    }
    
    // MARK: VIEW INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Words.mainmenu_external_api.word()
        // Do any additional setup after loading the view.
        self.setupTabs()
        self.initGeolocationAPISection()
        
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_external_api.word()
        self.btnApply.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_geo_location_api.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_face_recognition_api.word()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
