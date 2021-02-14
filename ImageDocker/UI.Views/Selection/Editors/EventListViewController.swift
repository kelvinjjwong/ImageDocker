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
                let event = events[lastSelectedRow!]
                print("selected event: owner: \(event.ownerId) \(event.ownerNickname)")
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
                self.cmbFamily.stringValue = event.family
                self.cmbCategory.stringValue = event.category
                self.cmbActivity1.stringValue = event.activity1
                self.cmbActivity2.stringValue = event.activity2
                self.txtAttendees.stringValue = event.attenders
                self.txtNote.stringValue = event.note
                self.lblImageCount.stringValue = "\(event.imageCount)"
                self.selectedEventName = event.name
                self.reloadCombos()
                
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
    @IBOutlet weak var cmbOwner: NSComboBox!
    @IBOutlet weak var cmbFamily: NSComboBox!
    @IBOutlet weak var cmbPeople: NSComboBox!
    @IBOutlet weak var txtAttendees: NSTextField!
    @IBOutlet weak var cmbCategory: NSComboBox!
    @IBOutlet weak var cmbActivity1: NSComboBox!
    @IBOutlet weak var cmbActivity2: NSComboBox!
    @IBOutlet weak var txtNote: NSTextField!
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
    var peopleCombo:TextListComboController!
    var ownerCombo:TextListComboController!
    var owner2Combo:TextListComboController!
    var owner3Combo:TextListComboController!
    var familyCombo:TextListComboController!
    var categoryCombo:TextListComboController!
    var activity1Combo:TextListComboController!
    var activity2Combo:TextListComboController!
    
    func reloadCombos() {
        let people = FaceDao.default.getPeople()
        var peopleNames:[String] = []
        peopleNames.append("")
        for person in people {
            peopleNames.append(person.name)
        }
        peopleCombo.load(peopleNames)
        peopleCombo.cleanSelection()
        ownerCombo.load(peopleNames)
        ownerCombo.cleanSelection()
        owner2Combo.load(peopleNames)
        owner2Combo.cleanSelection()
        owner3Combo.load(peopleNames)
        owner3Combo.cleanSelection()
        
        let families = FaceDao.default.getFamilies()
        var familyNames:[String] = []
        for family in families {
            familyNames.append(family.name)
        }
        if !familyNames.contains("") {
            familyNames.append("")
        }
        familyCombo.load(familyNames)
        familyCombo.cleanSelection()
        let categories = EventDao.default.getEventCategories()
        self.categoryCombo.load(categories)
        categoryCombo.cleanSelection()
        let activities = EventDao.default.getEventActivities()
        self.activity1Combo.load(activities)
        activity1Combo.cleanSelection()
        self.activity2Combo.load(activities)
        activity2Combo.cleanSelection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peopleCombo = TextListComboController(self.cmbPeople, onChange: { item in
            
        })
        
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
        
        self.familyCombo = TextListComboController(self.cmbFamily, onChange: { item in
            
        })
        
        self.categoryCombo = TextListComboController(self.cmbCategory, onChange: {item in
            let acts = EventDao.default.getEventActivities(category: item)
            if acts.count > 0 {
                self.activity1Combo.load(acts)
                self.activity2Combo.load(acts)
            }
        })
        
        self.activity1Combo = TextListComboController(self.cmbActivity1, onChange: {item in
            
        })
        self.activity2Combo = TextListComboController(self.cmbActivity2, onChange: {item in
            
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
        event.activity1 = self.cmbActivity1.stringValue
        event.activity2 = self.cmbActivity2.stringValue
        event.owner = self.cmbOwner.stringValue
        event.attenders = self.txtAttendees.stringValue
        event.family = self.cmbFamily.stringValue
        event.note = self.txtNote.stringValue
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
            
            EventDao.default.deleteEvent(name: name)
            
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
        event.activity1 = self.cmbActivity1.stringValue
        event.activity2 = self.cmbActivity2.stringValue
        event.owner = self.cmbOwner.stringValue
        event.ownerId = self.lblOwnerId.stringValue
        event.ownerNickname = self.lblOwnerNickname.stringValue
        event.owner2 = self.cmbOwner2.stringValue
        event.owner2Id = self.lblOwner2Id.stringValue
        event.owner2Nickname = self.lblOwner2Nickname.stringValue
        event.owner3 = self.cmbOwner3.stringValue
        event.owner3Id = self.lblOwner3Id.stringValue
        event.owner3Nickname = self.lblOwner3Nickname.stringValue
        event.attenders = self.txtAttendees.stringValue
        event.family = self.cmbFamily.stringValue
        event.note = self.txtNote.stringValue
        event.lastUpdateTime = Date()
        EventDao.default.updateEventDetail(event: event)
        
        if(name != selectedEventName){
            EventDao.default.renameEvent(oldName: selectedEventName, newName: name)
        }
        //ModelStore.save()
        
        self.reloadTable()
        
        if self.refreshDelegate != nil {
            refreshDelegate?.refreshEventList()
            self.refreshDelegate?.selectEvent(name: name)
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
                    var str = ( info.owner == "" ? "" : ("\(info.ownerNickname) (\(info.owner))") )
                    if info.owner2 != "" {
                        str = "\(str) \(info.owner2Nickname) (\(info.owner2))"
                    }
                    if info.owner3 != "" {
                        str = "\(str) \(info.owner3Nickname) (\(info.owner3))"
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



