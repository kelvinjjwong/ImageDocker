//
//  ImageLocationEditViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/5/26.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa
import WebKit
import LoggerFactory

class ImageLocationEditViewController : NSViewController {
    
    let logger = LoggerFactory.get(category: "ImageLocationEditViewController")
    
    // MARK: Icon
    let tick:NSImage = NSImage.init(named: NSImage.menuOnStateTemplateName)!
    
    @IBOutlet weak var apiSwitch: NSSegmentedControl!
    @IBOutlet weak var locationSearcher: NSSearchField!
    @IBOutlet weak var btnCopyLocation: NSButton!
    @IBOutlet weak var lblLocation: NSTextField!
    @IBOutlet weak var locationWebView: WKWebView!
    @IBOutlet weak var locationSlider: NSSlider!
    @IBOutlet weak var btnReplaceLocation: NSButton!
    @IBOutlet weak var lstPlaces: NSComboBox!
    @IBOutlet weak var btnManagePlaces: NSButton!
    
    var zoomSize:Int = 16
    var previousTick:Int = 3
    
    var possibleLocation:Location?
    var coordinateAPI:LocationAPI = .baidu
    var locationTextDelegate:LocationTextDelegate?
    
    var placePopover:NSPopover?
    var placeViewController:PlaceListViewController!
    var placeListController:PlaceListComboController!
    
    var getSampleImage: ( () -> ImageFile? )?
    var reloadCollectionView: (() -> Void)?
    var reloadSelectionView: (() -> Void)?
    var getSelectionItems: (() -> [ImageFile])?
    var getSelectionItem: ( (String) -> ImageFile? )?
    var reloadImageMetaTable: ( (ImageFile) -> Void )?
    var getSelectionViewIndicator: ( () -> NSProgressIndicator )?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPlaceList()
        
        self.apiSwitch.selectSegment(withTag: 1)
        self.coordinateAPI = .baidu
        
        self.apiSwitch.setImage(nil, forSegment: 0)
        self.apiSwitch.setImage(tick, forSegment: 1)
    }
    
    @IBAction func onMapSliderClicked(_ sender: NSSlider) {
    }
    
    @IBAction func onApiSwitchClicked(_ sender: NSSegmentedControl) {
        self.chooseMapProvider(sender.selectedSegment)
    }
    
    @IBAction func onLocationSearcherAction(_ sender: NSSearchField) {
        let address:String = locationSearcher.stringValue
        self.searchAddress(address)
    }
    
    @IBAction func onCopyLocationClicked(_ sender: NSButton) {
        self.copyLocationFromMap()
    }
    
    @IBAction func onReplaceLocationClicked(_ sender: NSButton) {
        self.replaceLocation()
    }
    
    @IBAction func onManagePlacesClicked(_ sender: NSButton) {
        self.openLocationSelector(sender)
    }
    
    internal func chooseMapProvider(_ i:Int){
        if i == 0 {
            self.coordinateAPI = .google
            locationTextDelegate?.coordinateAPI = .google
            self.apiSwitch.setImage(tick, forSegment: 0)
            self.apiSwitch.setImage(nil, forSegment: 1)
        }else{
            self.coordinateAPI = .baidu
            locationTextDelegate?.coordinateAPI = .baidu
            self.apiSwitch.setImage(nil, forSegment: 0)
            self.apiSwitch.setImage(tick, forSegment: 1)
        }
    }
    
    
    internal func searchAddress(_ address:String){
        if address == "" {return}
        if self.coordinateAPI == .baidu {
            BaiduLocation.queryForCoordinate(address: address, coordinateConsumer: self)
        }else if self.coordinateAPI == .google {
            GoogleLocation.queryForCoordinate(address: address, coordinateConsumer: self)
        }
    }
    
    internal func resizeMap(tick:Int) {
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
        
        self.loadBaiduMap()
        previousTick = tick
    }
    
    
    
    func loadBaiduMap() {
        self.locationWebView.load(URLRequest(url: URL(string: "about:blank")!))
        if let location = self.possibleLocation {
            if location.coordinateBD != nil && location.coordinateBD!.isNotZero {
                BaiduLocation.queryForMap(coordinateBD: location.coordinateBD!, view: self.locationWebView, zoom: self.zoomSize)
            }
        }
//        else{
//            self.logger.log("img has no coord")
//        }
    }
    
    func copyLocationFromMap() {
        if let sampleImage = self.getSampleImage?() {
            guard sampleImage.location.coordinateBD != nil && sampleImage.location.coordinateBD!.isNotZero else {return}
            if self.possibleLocation == nil {
                self.possibleLocation = Location()
            }
            if sampleImage.location.coordinate != nil && sampleImage.location.coordinateBD != nil {
                self.possibleLocation?.setCoordinateWithoutConvert(coord: sampleImage.location.coordinate!, coordBD: sampleImage.location.coordinateBD!)
            }
            
            self.possibleLocation?.country = self.readImageLocationMeta(title: "Country")
            self.possibleLocation?.province = self.readImageLocationMeta(title: "Province")
            self.possibleLocation?.city = self.readImageLocationMeta(title: "City")
            self.possibleLocation?.district = self.readImageLocationMeta(title: "District")
            self.possibleLocation?.businessCircle = self.readImageLocationMeta(title: "BusinessCircle")
            self.possibleLocation?.street = self.readImageLocationMeta(title: "Street")
            self.possibleLocation?.address = self.readImageLocationMeta(title: "Address")
            self.possibleLocation?.addressDescription = self.readImageLocationMeta(title: "Description")
            
            //self.logger.log("possible location address: \(possibleLocation?.address ?? "")")
            //self.logger.log("possible location place: \(possibleLocation?.place ?? "")")
            
            
            self.locationSearcher.stringValue = ""
            self.lstPlaces.stringValue = ""
            self.lstPlaces.deselectItem(at: self.lstPlaces.indexOfSelectedItem)
            
            BaiduLocation.queryForAddress(coordinateBD: sampleImage.location.coordinateBD!, locationConsumer: self, textConsumer: self.locationTextDelegate!)
            BaiduLocation.queryForMap(coordinateBD: sampleImage.location.coordinateBD!, view: self.locationWebView, zoom: self.zoomSize)
        }else{
            self.logger.log("sample image file is not selected")
        }
    }
    
    internal func readImageLocationMeta(title:String) -> String{
        if let sampleImage =  self.getSampleImage?() {
            return sampleImage.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: title)
                ?? sampleImage.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: title)
                ?? sampleImage.metaInfoHolder.getMeta(category: "Location", subCategory: "Google", title: title)
                ?? ""
        }else{
            return ""
        }
    }
    
    func openLocationSelector(_ sender: NSButton){
        self.createPlacePopover()
        if self.possibleLocation != nil {
            self.placeViewController.setPossibleLocation(place: self.possibleLocation!)
        }
        
        let cellRect = sender.bounds
        self.placePopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    func replaceLocation() {
        if let batchEditorIndicator = self.getSelectionViewIndicator?() {
            
            let selectedItems = self.getSelectionItems?() ?? []
            guard self.possibleLocation != nil && selectedItems.count > 0 else {return}
            let accumulator:Accumulator = Accumulator(target: selectedItems.count, indicator: batchEditorIndicator, suspended: false, lblMessage: nil)
            let location:Location = self.possibleLocation!
            for item in selectedItems {
                let url:URL = item.url as URL
                let imageType = url.imageType()
                if imageType == .photo || imageType == .video {
                    
                    // suppress this because it should be patch when exporting
                    //ExifTool.helper.patchGPSCoordinateForImage(latitude: location.latitude!, longitude: location.longitude!, url: url)
                    item.assignLocation(location: location)
                    
                    
                    let imageInSelection:ImageFile? = self.getSelectionItem?(url.path)
                    if imageInSelection != nil {
                        imageInSelection!.assignLocation(location: location)
                    }
                    
                    //self.logger.log("place after assign location: \(item.place)")
                    let _ = item.save()
                }
                let _ = accumulator.add()
            }
            self.reloadSelectionView?()
            self.reloadCollectionView?()
        }else{
            self.logger.log("selectionViewController is not linked to ImageLocationEditViewController")
        }
    }
    
    
    
    internal func createPlacePopover(){
        var myPopover = self.placePopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 902, height: 440))
            self.placeViewController = PlaceListViewController()
            self.placeViewController.view.frame = frame
            self.placeViewController.refreshDelegate = self
            
            myPopover!.contentViewController = self.placeViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.placePopover = myPopover
    }
}




extension ImageLocationEditViewController: CoordinateConsumer {
    
    func consume(coordinate:Coord){
        // no need to transform
        self.possibleLocation = Location()
        self.possibleLocation?.searchKeyword = self.locationSearcher.stringValue
        BaiduLocation.queryForAddress(coordinateBD: coordinate, locationConsumer: self.locationTextDelegate!, modifyLocation: self.possibleLocation)
        BaiduLocation.queryForMap(coordinateBD: coordinate, view: locationWebView, zoom: self.zoomSize)
    }
    
    func alert(status: Int, message: String) {
        self.logger.log("\(status) : \(message)")
    }
}

extension ImageLocationEditViewController: LocationConsumer {
    
    func consume(location: Location) {
        self.possibleLocation = location
        
        if let img =  self.getSampleImage?() {
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: location.country))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: location.province))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: location.city))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: location.district))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: location.street))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: location.businessCircle))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: location.address))
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: location.addressDescription))
            
            img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: location.place))
            
            img.recognizePlace()
            
            self.reloadImageMetaTable?(img)
        }
        
    }
    
    func alert(status: Int, message: String, popup:Bool = false) {
        self.logger.log("LOCATION ALERT: \(status) : \(message)")
    }
    
    
}

extension ImageLocationEditViewController : NSPopoverDelegate {
    
}


extension ImageLocationEditViewController : PlaceListRefreshDelegate{
    
    func setupPlaceList() {
        if self.placeListController == nil {
            self.placeListController = PlaceListComboController()
            self.placeListController.combobox = self.lstPlaces
            self.placeListController.refreshDelegate = self
            self.lstPlaces.dataSource = self.placeListController
            self.lstPlaces.delegate = self.placeListController
        }
        self.refreshPlaceList()
    }
    
    func refreshPlaceList() {
        self.placeListController.loadPlaces()
        self.lstPlaces.reloadData()
    }
    
    func selectPlace(name: String, location:Location) {
        self.placeListController.working = true
        self.lstPlaces.stringValue = name
        self.possibleLocation = location
        self.possibleLocation?.place = name
        self.lblLocation.stringValue = name
        BaiduLocation.queryForMap(coordinateBD: location.coordinateBD!, view: self.locationWebView, zoom: self.zoomSize)
        self.placeListController.working = false
        
    }
}

class PlaceListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var places:[ImagePlace] = []
    var refreshDelegate:PlaceListRefreshDelegate?
    var combobox:NSComboBox?
    var working:Bool = false
    
    func loadPlaces() {
        self.places = PlaceDao.default.getPlaces()
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
        //self.logger.log("SubString = \(string)")
        
        for place in places {
            let state = place.name
            // substring must have less characters then stings to search
            if string.count < state.count{
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = state.lowercased()[state.lowercased().startIndex..<state.lowercased().index(state.lowercased().startIndex, offsetBy: string.count)]
                if statePartialStr.range(of: string.lowercased()) != nil {
                    //self.logger.log("SubString Match = \(state)")
                    return state
                }
            }
        }
        return ""
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if combobox == nil || working {return}
        if combobox!.indexOfSelectedItem < 0 || combobox!.indexOfSelectedItem >= places.count {return}
        let name = places[combobox!.indexOfSelectedItem].name
        let place:ImagePlace? = PlaceDao.default.getPlace(name: name)
        if place != nil {
            let location = Location()
            location.country = place?.country ?? ""
            location.province = place?.province ?? ""
            location.city = place?.city ?? ""
            location.district = place?.district ?? ""
            location.street = place?.street ?? ""
            location.businessCircle = place?.businessCircle ?? ""
            location.address = place?.address ?? ""
            location.addressDescription = place?.addressDescription ?? ""
            location.place = place?.name ?? ""
            location.coordinate = Coord(latitude: Double(place?.latitude ?? "0")!, longitude: Double(place?.longitude ?? "0")!)
            location.coordinateBD = Coord(latitude: Double(place?.latitudeBD ?? "0")!, longitude: Double(place?.longitudeBD ?? "0")!)
            
            if refreshDelegate != nil {
                refreshDelegate?.selectPlace(name: name, location: location)
            }
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(places.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return(places[index].name as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for place in places {
            let str = place.name
            if str == string{
                return i
            }
            i += 1
        }
        return -1
    }
    
    
}
