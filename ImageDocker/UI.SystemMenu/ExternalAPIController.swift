//
//  ExternalAPIController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/2/12.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

final class ExternalAPIController: NSViewController {
    
    let logger = LoggerFactory.get(category: "ExternalAPIController")
    
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
            self.logger.log(.trace, "triggered link \(url)")
        }
    }
    
    @IBAction func onGoogleLinkClicked(_ sender: Any) {
        if let url = URL(string: "https://developers.google.com/maps/documentation/maps-static/intro"),
            NSWorkspace.shared.open(url) {
            self.logger.log(.trace, "triggered link \(url)")
        }
    }
    
    // MARK: GEOLOCATION API
    
    func saveGeolocationAPISection(_ defaults:UserDefaults) {
        Setting.externalApi.saveBaiduAK(txtBaiduAK.stringValue)
        Setting.externalApi.saveBaiduSK(txtBaiduSK.stringValue)
        Setting.externalApi.saveGoogleAK(txtGoogleAPIKey.stringValue)
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveGeolocationAPISection(defaults)
    }
    
    // MARK: - HEALTH CHECK
    
    class func healthCheck() {
        if Setting.externalApi.googleAPIKey() == "" {
            if Setting.externalApi.baiduAK() == "" || Setting.externalApi.baiduSK() == "" {
                MessageEventCenter.default.showMessage(
                    type: Words.notification_type_geolocation.word(),
                    name: "Geolocation",
                    message: Words.notification_geo_api_missing.word()
                )
                return
            }
        }
    }
    
    // MARK: - INIT SECTIONS
    
    func initGeolocationAPISection() {
        self.boxBaiduMap.title = Words.preference_tab_geo_location_api_box_baidu.word()
        self.boxGoogleMap.title = Words.preference_tab_geo_location_api_box_google.word()
        self.lblBaiduMapPrompt.stringValue = Words.preference_tab_geo_location_api_prompt.word()
        self.lblGoogleMapPrompt.stringValue = Words.preference_tab_geo_location_api_prompt.word()
        
        txtBaiduAK.stringValue = Setting.externalApi.baiduAK()
        txtBaiduSK.stringValue = Setting.externalApi.baiduSK()
        txtGoogleAPIKey.stringValue = Setting.externalApi.googleAPIKey()
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
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
