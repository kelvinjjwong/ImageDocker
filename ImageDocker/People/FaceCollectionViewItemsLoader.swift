//
//  FaceCollectionViewItemsLoader.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/28.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class FaceCollectionViewSection {
    var title:String
    var items: [PeopleFace]
    
    init(_ title:String){
        self.title = title
        self.items = []
    }
}

class FaceCollectionViewItemsLoader: NSObject {
    
    private var items:[PeopleFace] = []
    var numberOfSections = 0
    var singleSectionMode = true
    private var loading = false
    
    private var sections:[FaceCollectionViewSection] = []
    
    func loadIcons() {
        let people = ModelStore.default.getPeople()
        self.items = []
        if people.count > 0 {
            print("GOT \(people.count) PEOPLE")
            for person in people {
                let icon = PeopleFace(person: person)
                self.items.append(icon)
            }
            self.setupItems(self.items)
        }else{
            print("NO PEOPLE")
            self.setupItems(nil)
        }
        self.reorganizeItems()
    }
    
    func setupItems(_ items: [PeopleFace]?){
        if self.items.count > 0 {
            self.items.removeAll()
        }
        
        for section in sections {
            section.items.removeAll()
        }
        
        numberOfSections = 0
        sections.removeAll()
        
        guard items != nil && (items?.count)! > 0 else {
            self.loading = false
            return
        }
        
        self.loading = false
    }
    
    func reorganizeItems() {
        
        if sections.count > 0 {
            sections.removeAll()
        }
        
        numberOfSections = 1
        
        collectDomainItemToSingleSection()
    }

    private func collectDomainItemToSingleSection() {
        let section = self.getSection(title: "All")!
        section.items.removeAll()
        
        for item in items {
            section.items.append(item)
        }
        sortItems(in: section)
        self.numberOfSections = 1
    }
    
    func getSection(title: String, createIfNotExist:Bool = true) -> FaceCollectionViewSection? {
        for section in self.sections {
            if section.title == title {
                return section
            }
        }
        if createIfNotExist {
            let section = FaceCollectionViewSection(title)
            self.sections.append(section)
            return section
        }else{
            return nil
        }
    }
    
    private func sortItems(in section:FaceCollectionViewSection) {
        var keys:Set<String> = []
        for item in section.items {
            if let date = item.data.imageDate {
                keys.insert(date.databaseValue.description)
            }else{
                keys.insert(item.personName)
            }
        }
        
        let sortedKeys = keys.sorted()
        
        var sortedItems:[PeopleFace] = []
        
        for key in sortedKeys {
            for item in section.items {
                if let date = item.data.imageDate {
                    if date.databaseValue.description == key {
                        sortedItems.append(item)
                    }
                }else{
                    if item.personName == key {
                        sortedItems.append(item)
                    }
                }
            }
        }
        
        section.items = sortedItems
    }
    
    // get number of items in section
    func numberOfItems(in section: Int) -> Int {
        guard sections.count > 0 else {return 0}
        return sections[section].items.count
    }
    
    // get single item
    func item(for indexPath: NSIndexPath) -> PeopleFace {
        return sections[indexPath.section].items[indexPath.item]
    }
    
    func titleOfSection(_ section: Int) -> String {
        guard sections.count > section else {return ""}
        return sections[section].title
    }
    
    func getItems() -> [PeopleFace] {
        return self.items
    }
    
}
