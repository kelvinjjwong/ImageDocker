//
//  PeopleManageViewController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/9/24.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

class PeopleManageViewController: NSViewController {
    
    fileprivate var selectedPeopleId = ""
    
    @IBOutlet weak var boxBio: NSBox!
    @IBOutlet weak var boxMemberOf: NSBox!
    @IBOutlet weak var lblId: NSTextField!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblNickName: NSTextField!
    @IBOutlet weak var txtId: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtNickName: NSTextField!
    
    @IBOutlet weak var chkCoreMember: NSButton!
    
    @IBOutlet weak var tblPeopleList: NSTableView!
    @IBOutlet weak var tblGroups: NSTableView!
    
    var peopleListController : SingleColumnTableViewController!
    var groupTableController : DictionaryTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.peopleListController = SingleColumnTableViewController(self.tblPeopleList)
        self.peopleListController.onClick = { value in
//            self.onFaceCategoryClicked(value)
            print("selected \(value)")
            if let person = FaceDao.default.getPerson(name: value) {
                self.selectedPeopleId = person.id
                self.txtId.stringValue = person.id
                self.txtName.stringValue = person.name
                self.txtNickName.stringValue = person.shortName ?? person.name
                
                if person.coreMember {
                    self.chkCoreMember.state = .on
                }else{
                    self.chkCoreMember.state = .off
                }
                self.chkCoreMember.isEnabled = true
            }else{
                self.selectedPeopleId = ""
                self.txtId.stringValue = ""
                self.txtName.stringValue = ""
                self.txtNickName.stringValue = ""
                
                self.chkCoreMember.state = .off
                self.chkCoreMember.isEnabled = false
            }
        }
        
        self.groupTableController = DictionaryTableViewController(self.tblGroups)
    }
    
    @IBAction func onCheckCoreMember(_ sender: NSButton) {
        let state = ( sender.state == .on )
        if self.selectedPeopleId != "" {
            if let person = FaceDao.default.getPerson(id: self.selectedPeopleId) {
                FaceDao.default.updatePersonIsCoreMember(id: self.selectedPeopleId, isCoreMember: state)
                self.reloadPeople()
            }
        }
    }
    
    func initView() {
        self.reloadPeople()
        self.groupTableController.load(self.loadGroups(), afterLoaded: {
        })
    }
    
    func reloadPeople() {
        var names:[String] = []
        let people = FaceDao.default.getPeople()
        for p in people {
            names.append(p.name)
        }
        self.peopleListController.load(names)
    }
    
    
    
    func loadGroups() -> [[String:String]] {
        var values:[[String:String]] = []
        let groups = FaceDao.default.getFamilies()
        for g in groups {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["id"] = g.id
            item["name"] = g.name
            values.append(item)
        }
        return values
    }
    
    
    
    
    init(){
        super.init(nibName: "PeopleManageViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
