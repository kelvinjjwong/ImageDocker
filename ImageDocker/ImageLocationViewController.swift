//
//  ImageLocationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/26.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa
import WebKit

class ImageLocationViewController : NSViewController {
    
    @IBOutlet weak var locationWebView: WKWebView!
    @IBOutlet weak var locationSlider: NSSlider!
    
    var zoomSize:Int = 16
    var previousTick:Int = 3
    
    var selectedImage:ImageFile?
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onMapSliderClicked(_ sender: NSSlider) {
        let tick:Int = sender.integerValue
        self.resizeMap(tick: tick)
    }
    
    func loadMap(image:ImageFile){
        self.selectedImage = image
        self.loadBaiduMap()
    }
    
    func loadBaiduMap() {
        self.locationWebView.load(URLRequest(url: URL(string: "about:blank")!))
        if let selectedImage = self.selectedImage {
            if selectedImage.location.coordinateBD != nil && selectedImage.location.coordinateBD!.isNotZero {
                BaiduLocation.queryForMap(coordinateBD: selectedImage.location.coordinateBD!, view: self.locationWebView, zoom: self.zoomSize)
            }
        }
//        else{
//            self.logger.log("img has no coord")
//        }
    }
    
    internal func resizeMap(tick:Int) {
        if tick == previousTick {
            return
        }
        switch tick {
        case 1:
            zoomSize = 6
        case 2:
            zoomSize = 8
        case 3:
            zoomSize = 10
        case 4:
            zoomSize = 11
        case 5:
            zoomSize = 12
        case 6:
            zoomSize = 13
        case 7:
            zoomSize = 14
        case 8:
            zoomSize = 15
        case 9:
            zoomSize = 16
        case 10:
            zoomSize = 17
        default:
            zoomSize = 17
        }
        print("zoom size: \(zoomSize)")
        self.loadBaiduMap()
        previousTick = tick
    }
    
}
