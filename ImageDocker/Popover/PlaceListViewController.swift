//
//  PlaceListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import WebKit

protocol PlaceListRefreshDelegate {
    func refreshPlaceList()
    func selectPlace(name:String)
}

class PlaceListViewController: NSViewController {
    
    var refreshDelegate:PlaceListRefreshDelegate?
    
    var coordinate:Coord?
    var coordinateBD:Coord?
    var location:Location?
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "PlaceListViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //override func loadView() {
    //  self.view = NSView()
    //}
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && places.count > 0 && lastSelectedRow! < places.count {
                let place = places[lastSelectedRow!]
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
                
                if self.refreshDelegate != nil {
                    self.refreshDelegate?.selectPlace(name: place.name ?? "")
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
    
    var places:[PhotoPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.places = ModelStore.getPlaces()
        placeTable.delegate = self
        placeTable.dataSource = self
        placeTable.reloadData()
    }
    
    @IBAction func onPlaceSearcherAction(_ sender: Any) {
        let keyword:String = placeSearcher.stringValue
        if keyword == "" {return}
        self.places = ModelStore.getPlaces(byName: keyword)
    }
    
    @IBAction func onLocationSearcherAction(_ sender: Any) {
        let address:String = locationSearcher.stringValue
        if address == "" {return}
        BaiduLocation.queryForCoordinate(address: address, coordinateConsumer: self)
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
