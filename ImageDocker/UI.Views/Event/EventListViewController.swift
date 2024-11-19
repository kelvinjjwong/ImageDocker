//
//  EventListView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

protocol EventListRefreshDelegate {
    func refreshEventList()
    func selectEvent(event:ImageEvent)
}

class EventListViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "EventListViewController")
    
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
                let event = events[lastSelectedRow!]
                self.logger.log(.trace, "selected event: owner: \(event.ownerId) \(event.ownerNickname)")
                self.eventName.stringValue = event.name
                self.cmbOwner.stringValue = event.owner
                self.lblOwnerNickname.stringValue = event.ownerNickname
                self.lblOwnerId.stringValue = event.ownerId
                self.cmbOwner2.stringValue = event.owner2
                self.lblOwner2Nickname.stringValue = event.owner2Nickname
                self.lblOwner2Id.stringValue = event.owner2Id
                self.cmbOwner3.stringValue = event.owner3
                self.lblOwner3Nickname.stringValue = event.owner3Nickname
                self.lblOwner3Id.stringValue = event.owner3Id
                self.cmbCategory.stringValue = event.category
                self.lblImageCount.stringValue = "\(event.imageCount)"
                self.selectedEventName = event.name
                self.reloadCombos()
                
                if self.refreshDelegate != nil {
                    self.refreshDelegate?.selectEvent(event: events[lastSelectedRow!])
                }
            }
        }
    }
    
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var lblOwner: NSTextField!
    @IBOutlet weak var lblCategory: NSTextField!
    @IBOutlet weak var lblEvent: NSTextField!
    @IBOutlet weak var lblImages: NSTextField!
    
    @IBOutlet weak var btnUpdate: NSButton!
    @IBOutlet weak var btnCreate: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnReload: NSButton!
    
    @IBOutlet weak var tblColCategory: NSTableColumn!
    @IBOutlet weak var tblColOwner: NSTableColumn!
    @IBOutlet weak var tblColTo: NSTableColumn!
    @IBOutlet weak var tblColEvent: NSTableColumn!
    @IBOutlet weak var tblColImages: NSTableColumn!
    @IBOutlet weak var tblColLastUpdate: NSTableColumn!
    
    
    @IBOutlet weak var eventTable: NSTableView!
    @IBOutlet weak var eventSearcher: NSSearchField!
    @IBOutlet weak var eventName: NSTextField!
    @IBOutlet weak var cmbOwner: NSComboBox!
    @IBOutlet weak var cmbCategory: NSComboBox!
    @IBOutlet weak var lblImageCount: NSTextField!
    @IBOutlet weak var btnCount: NSButton!
    @IBOutlet weak var lblOwnerNickname: NSTextField!
    @IBOutlet weak var lblOwnerId: NSTextField!
    @IBOutlet weak var btnImport: NSButton!
    @IBOutlet weak var cmbOwner2: NSComboBox!
    @IBOutlet weak var lblOwner2Nickname: NSTextField!
    @IBOutlet weak var lblOwner2Id: NSTextField!
    @IBOutlet weak var cmbOwner3: NSComboBox!
    @IBOutlet weak var lblOwner3Nickname: NSTextField!
    @IBOutlet weak var lblOwner3Id: NSTextField!
    
    
    var events:[ImageEvent] = []
    var selectedEventName:String = ""
    var ownerCombo:TextListComboController!
    var owner2Combo:TextListComboController!
    var owner3Combo:TextListComboController!
    var categoryCombo:TextListComboController!
    
    func reloadCombos() {
        let people = FaceDao.default.getPeople()
        var peopleNames:[String] = []
        peopleNames.append("")
        for person in people {
            peopleNames.append(person.name)
        }
        ownerCombo.load(peopleNames)
        ownerCombo.cleanSelection()
        owner2Combo.load(peopleNames)
        owner2Combo.cleanSelection()
        owner3Combo.load(peopleNames)
        owner3Combo.cleanSelection()
        
        let categories = EventDao.default.getEventCategories()
        self.categoryCombo.load(categories)
        categoryCombo.cleanSelection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblOwner.stringValue = Words.event_owner.word()
        self.lblCategory.stringValue = Words.event_category.word()
        self.lblEvent.stringValue = Words.event_name.word()
        self.lblImages.stringValue = Words.event_images.word()
        self.btnCount.title = Words.event_btn_count.word()
        self.btnUpdate.title = Words.event_btn_update.word()
        self.btnCreate.title = Words.event_btn_create.word()
        self.btnImport.title = Words.event_btn_import.word()
        self.btnDelete.title = Words.event_btn_delete.word()
        self.btnReload.title = Words.event_btn_reload.word()
        self.tblColCategory.title = Words.event_col_category.word()
        self.tblColOwner.title = Words.event_col_owner.word()
        self.tblColTo.title = Words.event_col_to.word()
        self.tblColEvent.title = Words.event_col_event.word()
        self.tblColImages.title = Words.event_col_images.word()
        self.tblColLastUpdate.title = Words.event_col_lastupdate.word()
        
        self.ownerCombo = TextListComboController(self.cmbOwner, onChange: { item in
            self.lblOwnerId.stringValue = ""
            self.lblOwnerNickname.stringValue = ""
            if let person = FaceDao.default.getPerson(name: item) {
                self.lblOwnerId.stringValue = person.id
                self.lblOwnerNickname.stringValue = person.shortName ?? ""
            }
        })
        
        self.owner2Combo = TextListComboController(self.cmbOwner2, onChange: { item in
            self.lblOwner2Id.stringValue = ""
            self.lblOwner2Nickname.stringValue = ""
            if let person = FaceDao.default.getPerson(name: item) {
                self.lblOwner2Id.stringValue = person.id
                self.lblOwner2Nickname.stringValue = person.shortName ?? ""
            }
        })
        
        self.owner3Combo = TextListComboController(self.cmbOwner3, onChange: { item in
            self.lblOwner3Id.stringValue = ""
            self.lblOwner3Nickname.stringValue = ""
            if let person = FaceDao.default.getPerson(name: item) {
                self.lblOwner3Id.stringValue = person.id
                self.lblOwner3Nickname.stringValue = person.shortName ?? ""
            }
        })
        
        self.categoryCombo = TextListComboController(self.cmbCategory, onChange: {item in
            
        })
        self.reloadCombos()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.events = EventDao.default.getEvents()
        eventTable.delegate = self
        eventTable.dataSource = self
        eventTable.reloadData()
    }
    
    @IBAction func onEventSearcherAction(_ sender: Any) {
        self.reloadTable()
    }
    
    @IBAction func onButtonCreateClicked(_ sender: Any) {
        let name:String = eventName.stringValue
        if name == "" {return}
        let event = EventDao.default.getOrCreateEvent(name: name)
        event.category = self.cmbCategory.stringValue
        event.owner = self.cmbOwner.stringValue
        event.ownerId = self.lblOwnerId.stringValue
        event.ownerNickname = self.lblOwnerNickname.stringValue
        event.owner2 = self.cmbOwner2.stringValue
        event.owner2Id = self.lblOwner2Id.stringValue
        event.owner2Nickname = self.lblOwner2Nickname.stringValue
        event.owner3 = self.cmbOwner3.stringValue
        event.owner3Id = self.lblOwner3Id.stringValue
        event.owner3Nickname = self.lblOwner3Nickname.stringValue
        EventDao.default.updateEventDetail(event: event)
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
            
            let _ = EventDao.default.deleteEvent(name: name)
            
            self.reloadTable()
            
            if self.refreshDelegate != nil {
                refreshDelegate?.refreshEventList()
            }
        }
    }
    
    @IBAction func onButtonRenameClicked(_ sender: Any) {
        let name:String = eventName.stringValue
        guard name != "" && selectedEventName != ""  else {return} //&& name != selectedEventName
        
        let event = EventDao.default.getOrCreateEvent(name: selectedEventName)
        event.category = self.cmbCategory.stringValue
        event.owner = self.cmbOwner.stringValue
        event.ownerId = self.lblOwnerId.stringValue
        event.ownerNickname = self.lblOwnerNickname.stringValue
        event.owner2 = self.cmbOwner2.stringValue
        event.owner2Id = self.lblOwner2Id.stringValue
        event.owner2Nickname = self.lblOwner2Nickname.stringValue
        event.owner3 = self.cmbOwner3.stringValue
        event.owner3Id = self.lblOwner3Id.stringValue
        event.owner3Nickname = self.lblOwner3Nickname.stringValue
        event.lastUpdateTime = Date()
        EventDao.default.updateEventDetail(event: event)
        
        if(name != selectedEventName){
            let dbState = EventDao.default.renameEvent(oldName: selectedEventName, newName: name)
            if dbState == .OK {
                event.name = name
            }
        }
        //ModelStore.save()
        
        self.reloadTable()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshEventList()
            self.refreshDelegate?.selectEvent(event: event)
        }
    }
    
    @IBAction func onButtonReloadClicked(_ sender: Any) {
        self.reloadTable()
    }
    
    func reloadTable() {
        let keyword:String = eventSearcher.stringValue
        if keyword == "" {
            self.events = EventDao.default.getEvents()
        }else{
            self.events = EventDao.default.getEvents(byName: keyword)
        }
        eventTable.reloadData()
        
    }
    
    @IBAction func onButtonCountClicked(_ sender: NSButton) {
        let count = EventDao.default.countImagesOfEvent(event: self.selectedEventName)
        self.lblImageCount.stringValue = "\(count)"
        self.reloadTable()
    }
    
    @IBAction func onButtonImportClicked(_ sender: NSButton) {
        EventDao.default.importEventsFromImages()
        self.reloadTable()
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
                case NSUserInterfaceItemIdentifier("owner"):
                    var str = ( info.owner == "" ? "" : ("\(info.ownerNickname)") )
                    if info.owner2 != "" {
                        str = "\(str) \(info.owner2Nickname)"
                    }
                    if info.owner3 != "" {
                        str = "\(str) \(info.owner3Nickname)"
                    }
                    value = str
                case NSUserInterfaceItemIdentifier("attenders"):
                    value = info.attenders

                case NSUserInterfaceItemIdentifier("category"):
                    value = info.category

                case NSUserInterfaceItemIdentifier("activity1"):
                    value = info.activity1

                case NSUserInterfaceItemIdentifier("activity2"):
                    value = info.activity2

                case NSUserInterfaceItemIdentifier("ownerAge"):
                    value = info.ownerAge

                case NSUserInterfaceItemIdentifier("note"):
                    value = info.note

                case NSUserInterfaceItemIdentifier("imageCount"):
                    value = "\(info.imageCount)"

                case NSUserInterfaceItemIdentifier("lastUpdateTime"):
                    value = (info.lastUpdateTime == nil) ? "" : "\(info.lastUpdateTime!)"
                
                default:
                    break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
//                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedRow = nil
//                colView.textField?.textColor = nil
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



