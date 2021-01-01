//
//  EventListView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

protocol EventListRefreshDelegate {
    func refreshEventList()
    func selectEvent(name:String)
}

class EventListViewController: NSViewController {
    
    var refreshDelegate:EventListRefreshDelegate?
    
    init(){
        super.init(nibName: "EventListViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //override func loadView() {
      //  self.view = NSView()
    //}
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && events.count > 0 && lastSelectedRow! < events.count {
                eventName.stringValue = events[lastSelectedRow!].name
                selectedEventName = events[lastSelectedRow!].name
                
                if self.refreshDelegate != nil {
                    self.refreshDelegate?.selectEvent(name: events[lastSelectedRow!].name)
                }
            }
        }
    }
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var eventTable: NSTableView!
    @IBOutlet weak var eventSearcher: NSSearchField!
    @IBOutlet weak var eventName: NSTextField!
    
    var events:[ImageEvent] = []
    var selectedEventName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.events = EventDao.default.getEvents()
        eventTable.delegate = self
        eventTable.dataSource = self
        eventTable.reloadData()
    }
    
    @IBAction func onEventSearcherAction(_ sender: Any) {
        let keyword:String = eventSearcher.stringValue
        if keyword == "" {
            self.events = EventDao.default.getEvents()
        }else{
            self.events = EventDao.default.getEvents(byName: keyword)
        }
        eventTable.reloadData()
    }
    
    @IBAction func onButtonCreateClicked(_ sender: Any) {
        let name:String = eventName.stringValue
        if name == "" {return}
        let _ = EventDao.default.getOrCreateEvent(name: name)
        //ModelStore.save()
        
        self.events = EventDao.default.getEvents()
        eventTable.reloadData()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshEventList()
        }
    }
    
    @IBAction func onButtonDeleteClicked(_ sender: Any) {
        let name:String = eventName.stringValue
        if name == "" {return}
        
        if Alert.dialogOKCancel(question: "Disconnect photos with this event ?", text: name) {
            
            EventDao.default.deleteEvent(name: name)
            //ModelStore.save()
            
            self.events = EventDao.default.getEvents()
            eventTable.reloadData()
            
            if self.refreshDelegate != nil {
                refreshDelegate?.refreshEventList()
            }
        }
    }
    
    @IBAction func onButtonRenameClicked(_ sender: Any) {
        let name:String = eventName.stringValue
        guard name != "" && selectedEventName != "" && name != selectedEventName else {return}
        
        EventDao.default.renameEvent(oldName: selectedEventName, newName: name)
        //ModelStore.save()
        
        self.events = EventDao.default.getEvents()
        eventTable.reloadData()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshEventList()
            self.refreshDelegate?.selectEvent(name: name)
        }
    }
    
    @IBAction func onButtonReloadClicked(_ sender: Any) {
        let keyword:String = eventSearcher.stringValue
        if keyword == "" {
            self.events = EventDao.default.getEvents()
        }else{
            self.events = EventDao.default.getEvents(byName: keyword)
        }
        eventTable.reloadData()
    }
    
}

// MARK: TableView delegate functions

extension EventListViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.events.count - 1) {
            return nil
        }
        let info:ImageEvent = self.events[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("fromDate"):
                if info.startDate == nil {
                    value = ""
                }else{
                    value = dateFormatter.string(from: info.startDate!)
                }
            case NSUserInterfaceItemIdentifier("toDate"):
                if info.endDate == nil {
                    value = ""
                }else{
                    value = dateFormatter.string(from: info.endDate!)
                }
            case NSUserInterfaceItemIdentifier("eventName"):
                value = info.name
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
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
            ? Colors.MidGray
            : Colors.DarkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

// MARK: TableView data source functions

extension EventListViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.events.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}

extension ViewController : NSPopoverDelegate {
    
}



