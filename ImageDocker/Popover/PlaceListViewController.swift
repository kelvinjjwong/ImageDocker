//
//  PlaceListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import WebKit

enum LocationAPI : Int {
    case google
    case baidu
}


protocol PlaceListRefreshDelegate {
    func refreshPlaceList()
    func selectPlace(name:String, location:Location)
}

class PlaceListViewController: NSViewController {
    
    let tick:NSImage = NSImage.init(named: NSImage.Name.menuOnStateTemplate)!
    
    var refreshDelegate:PlaceListRefreshDelegate?
    
    var coordinate:Coord?
    var coordinateBD:Coord?
    var location:Location?
    var coordinateAPI:LocationAPI = .baidu
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "PlaceListViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //override func loadView() {
    //  self.view = NSView()
    //}
    
    var selectedPlaceName:String?
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && places.count > 0 && lastSelectedRow! < places.count {
                let place = places[lastSelectedRow!]
                
                selectedPlaceName = place.name ?? ""
                
                placeName.stringValue = place.name ?? ""
                country.stringValue = place.country ?? ""
                province.stringValue = place.province ?? ""
                city.stringValue = place.city ?? ""
                district.stringValue = place.district ?? ""
                businessCircle.stringValue = place.businessCircle ?? ""
                street.stringValue = place.street ?? ""
                address.stringValue = place.address ?? ""
                addressDescription.stringValue = place.addressDescription ?? ""
                
                coordinate = Coord(latitude: Double(place.latitude ?? "0")!, longitude: Double(place.longitude ?? "0")!)
                coordinateBD = Coord(latitude: Double(place.latitudeBD ?? "0")!, longitude: Double(place.longitudeBD ?? "0")!)
                
                lblCoordinate.stringValue = "(\(coordinateBD?.latitude ?? 0), \(coordinateBD?.longitude ?? 0))"
                
                collectLocationFromForm()
                
                BaiduLocation.queryForMap(coordinateBD: coordinateBD!, view: mapWebView, zoom: 16)
                
                if self.refreshDelegate != nil {
                    self.refreshDelegate?.selectPlace(name: place.name ?? "", location: location!)
                }
            }
        }
    }
    
    @IBOutlet weak var placeTable: NSTableView!
    @IBOutlet weak var placeSearcher: NSSearchField!
    @IBOutlet weak var placeName: NSTextField!
    @IBOutlet weak var locationSearcher: NSSearchField!
    
    @IBOutlet weak var country: NSTextField!
    @IBOutlet weak var province: NSTextField!
    @IBOutlet weak var city: NSTextField!
    @IBOutlet weak var district: NSTextField!
    @IBOutlet weak var businessCircle: NSTextField!
    @IBOutlet weak var street: NSTextField!
    @IBOutlet weak var address: NSTextField!
    @IBOutlet weak var lblCoordinate: NSTextField!
    @IBOutlet weak var mapWebView: WKWebView!
    @IBOutlet weak var addressDescription: NSTextField!
    
    @IBOutlet weak var choiceService: NSSegmentedControl!
    
    
    var places:[PhotoPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.choiceService.selectSegment(withTag: 1)
        self.coordinateAPI = .baidu
        
        self.choiceService.setImage(nil, forSegment: 0)
        self.choiceService.setImage(tick, forSegment: 1)
        
        self.places = ModelStore.getPlaces()
        placeTable.delegate = self
        placeTable.dataSource = self
        placeTable.reloadData()
    }
    
    @IBAction func onPlaceSearcherAction(_ sender: Any) {
        let keyword:String = placeSearcher.stringValue
        if keyword == "" {
            self.places = ModelStore.getPlaces()
        }else{
            self.places = ModelStore.getPlaces(byName: keyword)
        }
        placeTable.reloadData()
    }
    
    @IBAction func onLocationSearcherAction(_ sender: Any) {
        let address:String = locationSearcher.stringValue
        if address == "" {return}
        if self.coordinateAPI == .baidu {
            BaiduLocation.queryForCoordinate(address: address, coordinateConsumer: self)
        }else if self.coordinateAPI == .google {
            GoogleLocation.queryForCoordinate(address: address, coordinateConsumer: self)
        }
    }
    
    fileprivate func collectLocationFromForm() {
        if location == nil {
            location = Location()
        }
        location?.country = country.stringValue
        location?.province = province.stringValue
        location?.city = city.stringValue
        location?.district = district.stringValue
        location?.street = street.stringValue
        location?.businessCircle = businessCircle.stringValue
        location?.address = address.stringValue
        location?.coordinate = coordinate
        location?.coordinateBD = coordinateBD
        location?.addressDescription = addressDescription.stringValue
    }
    
    
    @IBAction func onButtonCreateClicked(_ sender: Any) {
        let name:String = placeName.stringValue
        if name == "" {return}
        collectLocationFromForm()
        
        let _ = ModelStore.getOrCreatePlace(name: name, location: location!)
        ModelStore.save()
        
        self.places = ModelStore.getPlaces()
        placeTable.reloadData()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshPlaceList()
        }
    }
    
    @IBAction func onButtonRenameClicked(_ sender: Any) {
        let name:String = placeName.stringValue
        guard name != "" && selectedPlaceName != nil && selectedPlaceName != "" else {return}
        
        ModelStore.renamePlace(oldName: selectedPlaceName!, newName: name)
        ModelStore.save()
        
        self.places = ModelStore.getPlaces()
        placeTable.reloadData()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshPlaceList()
        }
        
    }
    
    
    @IBAction func onButtonUpdateClicked(_ sender: Any) {
        let name:String = placeName.stringValue
        if name == "" {return}
        collectLocationFromForm()
        
        ModelStore.updatePlace(name: name, location: location!)
        ModelStore.save()
        
        self.places = ModelStore.getPlaces()
        placeTable.reloadData()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshPlaceList()
        }
    }
    
    
    @IBAction func onButtonDeleteClicked(_ sender: Any) {
        let name:String = placeName.stringValue
        if name == "" {return}
        
        if self.dialogOKCancel(question: "Disconnect photos with this place ?", text: name) {
            
            ModelStore.deletePlace(name: name)
            ModelStore.save()
            
            self.places = ModelStore.getPlaces()
            placeTable.reloadData()
            
            if self.refreshDelegate != nil {
                refreshDelegate?.refreshPlaceList()
            }
        }
    }
    
    @IBAction func onChoiceServiceClicked(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.coordinateAPI = .google
            self.choiceService.setImage(tick, forSegment: 0)
            self.choiceService.setImage(nil, forSegment: 1)
        }else{
            self.coordinateAPI = .baidu
            self.choiceService.setImage(nil, forSegment: 0)
            self.choiceService.setImage(tick, forSegment: 1)
        }
    }
    
    
    private func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
}

extension PlaceListViewController: CoordinateConsumer {
    func consume(coordinate: Coord) {
        self.location = Location()
        BaiduLocation.queryForAddress(coordinateBD: coordinate, locationConsumer: self, modifyLocation: self.location)
        BaiduLocation.queryForMap(coordinateBD: coordinate, view: mapWebView, zoom: 16)
    }
    
    func alert(status: Int, message: String) {
        print("\(status) - \(message)")
    }
    
    
}

extension PlaceListViewController: LocationConsumer {
    func consume(location: Location) {
        //print("CONSUME LOCATION: COUNTRY \(location.country)")
        self.location = location
        
        country.stringValue = location.country
        province.stringValue = location.province
        city.stringValue = location.city
        district.stringValue = location.district
        businessCircle.stringValue = location.businessCircle
        street.stringValue = location.street
        address.stringValue = location.address
        addressDescription.stringValue = location.addressDescription
        
        coordinate = location.coordinate
        coordinateBD = location.coordinateBD
        
        lblCoordinate.stringValue = "(\(coordinateBD?.latitude ?? 0), \(coordinateBD?.longitude ?? 0))"
        
        if location.country == "" && self.coordinateAPI == .google && location.source != "Google" {
            // retry fetch location detail by google api
            
            let address:String = locationSearcher.stringValue
            if address == "" {return}
            
            GoogleLocation.queryForAddress(address: address, locationConsumer: self, modifyLocation: self.location)
        }
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        print("\(status) - \(message)")
    }
    
    
}

// MARK: TableView delegate functions

extension PlaceListViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.places.count - 1) {
            return nil
        }
        let info:PhotoPlace = self.places[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("country"):
                value = info.country ?? ""
            case NSUserInterfaceItemIdentifier("city"):
                value = info.city ?? ""
            case NSUserInterfaceItemIdentifier("name"):
                value = info.name!
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedRow = nil
                colView.textField?.textColor = nil
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        rowView.backgroundColor = row % 2 == 1
            ? NSColor.gray
            : NSColor.darkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

// MARK: TableView data source functions

extension PlaceListViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.places.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
