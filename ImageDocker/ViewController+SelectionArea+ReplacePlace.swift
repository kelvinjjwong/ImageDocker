//
//  ViewController+SelectionArea+ReplacePlace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
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

extension ViewController : PlaceListRefreshDelegate{
    
    func setupPlaceList() {
        if self.placeListController == nil {
            self.placeListController = PlaceListComboController()
            self.placeListController.combobox = self.comboPlaceList
            self.placeListController.refreshDelegate = self
            self.comboPlaceList.dataSource = self.placeListController
            self.comboPlaceList.delegate = self.placeListController
        }
        self.refreshPlaceList()
    }
    
    func refreshPlaceList() {
        self.placeListController.loadPlaces()
        self.comboPlaceList.reloadData()
    }
    
    func selectPlace(name: String, location:Location) {
        self.placeListController.working = true
        self.comboPlaceList.stringValue = name
        self.possibleLocation = location
        self.possibleLocation?.place = name
        self.possibleLocationText.stringValue = name
        BaiduLocation.queryForMap(coordinateBD: location.coordinateBD!, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
        self.placeListController.working = false
        
    }
}

class PlaceListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var places:[ImagePlace] = []
    var refreshDelegate:PlaceListRefreshDelegate?
    var combobox:NSComboBox?
    var working:Bool = false
    
    func loadPlaces() {
        self.places = ModelStore.default.getPlaces()
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
        //print("SubString = \(string)")
        
        for place in places {
            let state = place.name
            // substring must have less characters then stings to search
            if string.count < state.count{
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = state.lowercased()[state.lowercased().startIndex..<state.lowercased().index(state.lowercased().startIndex, offsetBy: string.count)]
                if statePartialStr.range(of: string.lowercased()) != nil {
                    //print("SubString Match = \(state)")
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
        let place:ImagePlace? = ModelStore.default.getPlace(name: name)
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
