//
//  ViewController+SelectionArea+AssignEvent.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func createEventPopover(){
        var myPopover = self.eventPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1200, height: 620))
            self.eventViewController = EventListViewController()
            self.eventViewController.view.frame = frame
            self.eventViewController.refreshDelegate = self
            
            myPopover!.contentViewController = self.eventViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.eventPopover = myPopover
    }
    
    internal func assignEvent() {
        print("CLICKED ASSIGN EVENT BUTTON")
        print(self.selectionViewController.imagesLoader.getItems().count)
        print(self.comboEventList.stringValue)
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        guard self.comboEventList.stringValue != "" else {return}
        
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil, onCompleted:{ data in
            //self.refreshCollection()
            
            self.imagesLoader.reorganizeItems(considerPlaces: true)
            self.collectionView.reloadData()
            
            //TODO TO DO FUNCTION
            //self.refreshTree()
            print("TO DO FUNCTION")
        })
        accumulator.reset()
        
        var event:ImageEvent? = nil
        let selectedEvent = self.comboEventList.stringValue
        let part = selectedEvent.components(separatedBy: " | ")
        for ev in self.eventListController.events {
            if ev.category == part[0] && ev.name == part[1]{
                event = ev
                break
            }
        }
        if let event = event {
            //print("PREPARE TO ASSIGN EVENT \(event.name)")
            for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
                let url:URL = item.url as URL
                let imageType = url.imageType()
                if imageType == .photo || imageType == .video {
                    //print("assigning event: \(event.name)")
                    item.assignEvent(event: event)
                    //ExifTool.helper.assignKeyValueForImage(key: "Event", value: "some event", url: url)
                    let _ = item.save()
                }
                let _ = accumulator.add()
            }
        }
    }
    
}

extension ViewController : EventListRefreshDelegate{
    
    func setupEventList() {
        if self.eventListController == nil {
            self.eventListController = EventListComboController()
            self.comboEventList.dataSource = self.eventListController
            self.comboEventList.delegate = self.eventListController
        }
        self.refreshEventList()
    }
    
    func refreshEventList() {
        self.eventListController.loadEvents()
        self.comboEventList.reloadData()
    }
    
    func selectEvent(event: ImageEvent) {
        self.comboEventList.stringValue = "\(event.category == "" ? Words.uncategorized.word() : event.category) | \(event.name)"
    }
}

class EventListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var events:[ImageEvent] = []
    
    // comment out to avoid accidental shutdown on startup application
//    convenience override init() {
//        self.init()
//        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents(notification:)), name: NSNotification.Name(rawValue: ChangeEvent.language), object: nil)
//    }
    
    @objc func loadEvents(notification:Notification) {
        self.loadEvents()
    }
    
    func loadEvents() {
        self.events = EventDao.default.getEvents()
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        
        //print("SubString = \(string)")
        
        for event in events {
            let state = event.name
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
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(events.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return("\(events[index].category == "" ? Words.uncategorized.word() : events[index].category) | \(events[index].name)" as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        let part = string.components(separatedBy: " | ")
        let item = part.count == 2 ? part[1] : string
        for event in events {
            let str = event.name
            if str == item {
                return i
            }
            i += 1
        }
        return -1
    }
}
