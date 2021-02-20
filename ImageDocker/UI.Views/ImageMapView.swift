//
//  ImageMapView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/2/16.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa
import WebKit

class ImageMapView: NSViewController {
    
    
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var mapZoomSlider: NSSlider!
    @IBOutlet weak var btnChoiceMapService: NSSegmentedControl!
    @IBOutlet weak var addressSearcher: NSSearchField!
    @IBOutlet weak var btnCopyLocation: NSButton!
    @IBOutlet weak var possibleLocationText: NSTextField!
    @IBOutlet weak var webPossibleLocation: WKWebView!
    @IBOutlet weak var possibleMapZoomSlider: NSSlider!
    @IBOutlet weak var btnReplaceLocation: NSButton!
    @IBOutlet weak var comboPlaceList: NSComboBox!
    @IBOutlet weak var btnManagePlaces: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    var onMapSliderChange:((NSSlider) -> Void)?
    var onMapServiceChange:((NSSegmentedControl) -> Void)?
    var onAddressSearch:((NSSearchField) -> Void)?
    var onCopyLocationFromMap:(() -> Void)?
    var onPossibleMapSliderChange:((NSSlider) -> Void)?
    var onReplaceLocation:(() -> Void)?
    var onManagePlaces:((NSButton) -> Void)?
    
    @IBAction func onMapSliderClicked(_ sender: NSSlider) {
        if onMapSliderChange != nil {
            self.onMapSliderChange!(sender)
        }
    }
    
    @IBAction func onButtonChoiceMapServiceClicked(_ sender: NSSegmentedControl) {
        if onMapServiceChange != nil {
            self.onMapServiceChange!(sender)
        }
    }
    
    @IBAction func onAddressSearcherAction(_ sender: NSSearchField) {
        if onAddressSearch != nil {
            self.onAddressSearch!(sender)
        }
    }
    
    
    @IBAction func onCopyLocationFromMapClicked(_ sender: NSButton) {
        if onCopyLocationFromMap != nil {
            self.onCopyLocationFromMap!()
        }
    }
    
    @IBAction func onPossibleMapSliderClicked(_ sender: NSSlider) {
        if onPossibleMapSliderChange != nil {
            self.onPossibleMapSliderChange!(sender)
        }
    }
    
    @IBAction func onReplaceLocationClicked(_ sender: NSButton) {
        if onReplaceLocation != nil {
            self.onReplaceLocation!()
        }
    }
    
    @IBAction func onMarkLocationClicked(_ sender: NSButton) {
        if onManagePlaces != nil {
            self.onManagePlaces!(sender)
        }
    }
    
}
