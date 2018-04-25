//
//  ViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/22.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import CryptoSwift
import CoreLocation
import SwiftyJSON
import WebKit
import AVFoundation
import AVKit

class ViewController: NSViewController {
    
    var metaInfo:[MetaInfo] = [MetaInfo]()
    var img:ImageData!
    var zoomSize:Int = 16
    var previousTick:Int = 3
    
    var lastSelectedMetaInfoRow: Int?
    
    // MARK: Properties
    
    @IBOutlet weak var webLocation: WKWebView!
    @IBOutlet weak var metaInfoTableView: NSTableView!
    @IBOutlet weak var playerContainer: NSView!
    
    var stackedImageViewController : StackedImageViewController!
    var stackedVideoViewController : StackedVideoViewController!
    
    // MARK: Actions
    
    @IBAction func onButtonOpenClick(_ sender: NSButton) {
        let baiduAK:String = PreferencesController.baiduAK()
        let baiduSK:String = PreferencesController.baiduSK()
        
        if baiduAK == "" || baiduSK == "" {
            
            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
            alert.messageText = NSLocalizedString("Please setup API keys", comment: "Please setup API keys")
            alert.informativeText = NSLocalizedString("Please specify Baidu AK and SK in Preferences menu/dialog.", comment: "Please specify Baidu AK and SK in Preferences menu/dialog.")
            alert.runModal()
            return
        }
        
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["jpg", "jpeg", "mov", "mp4", "mpg"] //CGImageSourceCopyTypeIdentifiers() as? [String]
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        if panel.runModal().rawValue == NSApplication.ModalResponse.OK.rawValue {
            processUrls(urls: panel.urls)
        }
    }
    
    func processUrls(urls:[URL]){
        let baiduAK:String = PreferencesController.baiduAK()
        let baiduSK:String = PreferencesController.baiduSK()
        
        if urls.count == 0 {return}
        let url:URL = urls[0]
        if url.lastPathComponent.split(separator: Character(".")).count < 2 {return}
        let fileExt:String = (url.lastPathComponent.split(separator: Character(".")).last?.lowercased())!
        if fileExt == "jpg" || fileExt == "jpeg" {
            
            // switch to image view
            for sView in self.playerContainer.subviews {
                sView.removeFromSuperview()
            }
            if stackedVideoViewController != nil && stackedVideoViewController.videoDisplayer != nil && stackedVideoViewController.videoDisplayer.player != nil {
                stackedVideoViewController.videoDisplayer.player?.pause()
            }
            stackedImageViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedImageViewController.view)
            
            // init meta data
            self.metaInfo = [MetaInfo]()
            img = ImageData(url: url)
            
            // show image
            stackedImageViewController.imageDisplayer.image = img.image
            
        } else {
            
            // switch to video view
            for sView in self.playerContainer.subviews {
                sView.removeFromSuperview()
            }
            stackedVideoViewController.view.frame = self.playerContainer.bounds
            self.playerContainer.addSubview(stackedVideoViewController.view)
            
            // init meta data
            self.metaInfo = [MetaInfo]()
            img = ImageData(url: url)
            
            // show video
            stackedVideoViewController.videoDisplayer.player = AVPlayer(url: url)
            stackedVideoViewController.videoDisplayer.player?.play()
            
        }
        self.metaInfo = img.metaInfo
        loadExif(url, image: img)
        self.generateBaiduAddressRequestUrl(ak: baiduAK, sk: baiduSK, lat: img.latitudeBaidu, lon: img.longitudeBaidu)
        self.loadLocation()
        self.metaInfoTableView.reloadData()
    }
    
    private func loadExif(_ url:URL, image:ImageData){
        let jsonStr:String = ExifTool.helper.getFormattedExif(url: url)
        print(jsonStr)
        let json:JSON = JSON(parseJSON: jsonStr)
        if json != JSON(NSNull()) {
            self.setMetaInfo(MetaInfo(category: "System", title: "Size", value: json[0]["Composite"]["ImageSize"].description), ifNotExists: true)
            
            self.setMetaInfo(MetaInfo(category: "Camera", title: "ISO", value: json[0]["EXIF"]["ISO"].description))
            self.setMetaInfo(MetaInfo(category: "Camera", title: "ExposureTime", value: json[0]["EXIF"]["ExposureTime"].description))
            self.setMetaInfo(MetaInfo(category: "Camera", title: "Aperture", value: json[0]["EXIF"]["ApertureValue"].description))
            
            self.setMetaInfo(MetaInfo(category: "Video", title: "Format", value: json[0]["QuickTime"]["MajorBrand"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "CreateDate", value: json[0]["QuickTime"]["CreateDate"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "ModifyDate", value: json[0]["QuickTime"]["ModifyDate"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "TrackCreateDate", value: json[0]["QuickTime"]["TrackCreateDate"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "TrackModifyDate", value: json[0]["QuickTime"]["TrackModifyDate"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Frame Rate", value: json[0]["QuickTime"]["VideoFrameRate"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Image Width", value: json[0]["QuickTime"]["ImageWidth"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Image Height", value: json[0]["QuickTime"]["ImageHeight"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Duration", value: json[0]["QuickTime"]["Duration"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Size", value: json[0]["QuickTime"]["MovieDataSize"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Avg Bitrate", value: json[0]["Composite"]["AvgBitrate"].description))
            self.setMetaInfo(MetaInfo(category: "Video", title: "Rotation", value: json[0]["Composite"]["Rotation"].description))
            self.setMetaInfo(MetaInfo(category: "Audio", title: "Channels", value: json[0]["QuickTime"]["AudioChannels"].description))
            self.setMetaInfo(MetaInfo(category: "Audio", title: "BitsPerSample", value: json[0]["QuickTime"]["AudioBitsPerSample"].description))
            self.setMetaInfo(MetaInfo(category: "Audio", title: "SampleRate", value: json[0]["QuickTime"]["AudioSampleRate"].description))
        }
        
        let jsonStr2:String = ExifTool.helper.getUnformattedExif(url: url)
        print(jsonStr2)
        let json2:JSON = JSON(parseJSON: jsonStr2)
        
        if json2 != JSON(NSNull()) {
            
            self.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "WGS84", title: "Latitude", value: json2[0]["Composite"]["GPSLatitude"].description))
            self.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "WGS84", title: "Longitude", value: json2[0]["Composite"]["GPSLongitude"].description))
            
            if let lat:Double = json2[0]["Composite"]["GPSLatitude"].double,
                let lon:Double = json2[0]["Composite"]["GPSLongitude"].double {
                image.setCoordinate(latitude: lat, longitude: lon)
            }
        }
        
        self.metaInfoTableView.reloadData()
    }
    
    private func loadBaiduMapLocation() {
        let width:Int = Int(min(CGFloat(512), webLocation.frame.size.width))
        let height:Int = Int(min(CGFloat(512), webLocation.frame.size.height))
        self.generateBaiduMapRequestUrl(width: width, height: height, zoom: zoomSize, lat: img.latitudeBaidu, lon: img.longitudeBaidu)
        guard let requestUrl = URL(string: self.requestBaiduMapUrl) else {return}
        let req = URLRequest(url: requestUrl)
        webLocation.load(req)
        
    }
    
    private func loadLocation() {
        
        self.loadBaiduMapLocation()
        
        let urlString:String = self.requestBaiduAddressUrl
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                // let jsonString:String = String(data: data!, encoding: String.Encoding.utf8)!
                
                let json = try? JSON(data: usableData)
                let status:String = json!["status"].description
                let message:String = json!["message"].description
                if status != "0" {
                    DispatchQueue.main.async {
                        self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Status", value: status))
                        self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Message", value: message))
                        self.metaInfoTableView.reloadData()
                    }
                }else{
                
                    let address:String = json!["result"]["formatted_address"].description
                    let businessCircle:String = json!["result"]["business"].description
                    let country:String = json!["result"]["addressComponent"]["country"].description
                    let province:String = json!["result"]["addressComponent"]["province"].description
                    let city:String = json!["result"]["addressComponent"]["city"].description
                    let district:String = json!["result"]["addressComponent"]["district"].description
                    let street:String = json!["result"]["addressComponent"]["street"].description
                    let description:String = json!["result"]["sematic_description"].description
                    
                    if address != "" {
                        DispatchQueue.main.async {
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: country))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: province))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: city))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: district))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: street))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: businessCircle))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: address))
                            self.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: description))
                            self.metaInfoTableView.reloadData()
                        }
                    }
                }
                
            }
        }
        task.resume()
    }
    
    @IBAction func onMapSliderClick(_ sender: NSSliderCell) {
        let tick:Int = sender.integerValue
        if tick == previousTick {
            return
        }
        switch tick {
        case 1:
            zoomSize = 14
        case 2:
            zoomSize = 15
        case 3:
            zoomSize = 16
        case 4:
            zoomSize = 17
        default:
            zoomSize = 17
        }
        
        self.loadBaiduMapLocation()
        previousTick = tick
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        stackedImageViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "imageView")) as! StackedImageViewController
        stackedVideoViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "videoView")) as! StackedVideoViewController
        
        stackedImageViewController.parentController = self
        stackedVideoViewController.parentController = self
    
        self.addChildViewController(stackedImageViewController)
        self.addChildViewController(stackedVideoViewController)
        
        stackedImageViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(stackedImageViewController.view)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func setMetaInfo(_ info:MetaInfo, ifNotExists: Bool = false){
        if info.value == nil || info.value == "" || info.value == "null" {return}
        var exists:Int = 0
        for exist:MetaInfo in self.metaInfo {
            if exist.category == info.category && exist.subCategory == info.subCategory && exist.title == info.title {
                if ifNotExists == false {
                    exist.value = info.value
                }
                exists = 1
            }
        }
        if exists == 0 {
            self.metaInfo.append(info)
        }
    }
    
    var requestBaiduAddressUrl: String = ""
    
    func generateBaiduAddressRequestUrl(ak: String, sk: String, lat latitudeBaidu:Double, lon longitudeBaidu:Double){
        let baseurl:String = "http://api.map.baidu.com"
        let svcurl:String = "/geocoder/v2/?output=json&pois=0&ak="
        let query:String = "&location="
        let queryStr:String = "\(svcurl)\(ak)\(query)\(latitudeBaidu),\(longitudeBaidu)"
        let encodedStr:String = queryStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let rawStr:String = encodedStr + sk
        let rawStrEncode:String = rawStr.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!.replacingOccurrences(of: "%2E", with: ".")
        let baiduApiSn:String = rawStrEncode.md5()
        let requestUrl:String = "\(baseurl)\(queryStr)&sn=\(baiduApiSn)"
        self.requestBaiduAddressUrl = requestUrl
    }
    
    var requestBaiduMapUrl: String = ""
    
    func generateBaiduMapRequestUrl(width: Int, height: Int, zoom: Int, lat latitudeBaidu:Double, lon longitudeBaidu:Double){
        self.requestBaiduMapUrl = "http://api.map.baidu.com/staticimage?center=\(longitudeBaidu),\(latitudeBaidu)&width=\(width)&height=\(height)&zoom=\(zoom)&scale=2&markers=\(longitudeBaidu),\(latitudeBaidu)&markerStyles=l,A"
    }
    
}

extension ViewController: DropPlaceDelegate {
    func dropURLs(_ urls: [URL]) {
        processUrls(urls: urls)
    }
}

