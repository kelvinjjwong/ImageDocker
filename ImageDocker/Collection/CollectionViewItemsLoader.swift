//
//  ImageFileCollectionLoader.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//


import Cocoa

class CollectionViewSection {
    var title:String
    var items: [ImageFile]
    
    init(_ title:String){
        self.title = title
        self.items = [ImageFile]()
    }
}

class CollectionViewItemsLoader: NSObject {
  
    private var items = [ImageFile]()
    var numberOfSections = 1
    var singleSectionMode = false
    var considerPlaces = true
    var indicator:Accumulator?
    
    private var sections = [CollectionViewSection]()

    
    func load(from folderURL: NSURL, indicator:Accumulator? = nil) {
        self.indicator = indicator
        let urls = walkthruDirectoryForFileUrls(startingURL: folderURL)
        setupItems(urls: urls)
    }

    func setupItems(urls: [NSURL]?, cleanViewBeforeLoading:Bool = true) {
        
        if items.count > 0 {
            items.removeAll()
        }
        
        if cleanViewBeforeLoading {
            numberOfSections = 0
            sections = [CollectionViewSection]()
        }
            
        guard urls != nil && (urls?.count)! > 0 else {return}
        
        if indicator != nil {
            indicator?.setTarget((urls?.count)!)
        }

        if let urls = urls {
            self.transformToDomainItems(urls: urls)
        }
        //self.reorganizeItems(considerPlaces: true)

    }
    
    func reorganizeItems(considerPlaces:Bool = false) {
        //print("reorg")
        self.considerPlaces = considerPlaces
        
        if sections.count > 0 {
            sections.removeAll()
        }
        
        numberOfSections = 1
        
        if singleSectionMode {
            collectDomainItemToSingleSection()
        } else {
            collectDomainItemToMultipleSection()
        }
    }
  
    private func collectDomainItemToSingleSection() {
        let section:CollectionViewSection = self.getSection(title: "All")
        for item in items {
            section.items.append(item)
        }
        sortItems(in: section)
        
        self.numberOfSections = 1
    }
    
    private func getSection(title: String) -> CollectionViewSection {
        for section in self.sections {
            if section.title == title {
                return section
            }
        }
        let section:CollectionViewSection = CollectionViewSection(title)
        self.sections.append(section)
        return section
    }
    
    private func collectDomainItemToMultipleSection(_ dateFormat:String = "yyyy-MM-dd") {
        for item in items {
            var title:String = item.photoTakenDateString(dateFormat, forceUpdate: true)
            
            if title == "" {
                title = "Others"
            }
            
            if self.considerPlaces && item.place != "" {
                title = title + " @ " + item.place
            }
            let section:CollectionViewSection = self.getSection(title: title)
            section.items.append(item)
        }
        
        if sections.count > 0 && dateFormat == "yyyy-MM-dd" && isOnlyOneDateSection() {
            sections.removeAll()
            collectDomainItemToMultipleSection("yyyy-MM-dd HH:00")
        }else {
        
            // sort items
            for section in sections {
                sortItems(in: section)
            }
            
            // sort sections
            sortSections()
            
            self.numberOfSections = sections.count
        }
    }
    
    private func sortSections() {
        
        var titles = [String]()
        for section in sections {
            titles.append(section.title)
        }
        
        let sortedTitles = titles.sorted()
        
        var sortedSections = [CollectionViewSection]()
        
        for title in sortedTitles {
            for section in sections {
                if section.title == title {
                    sortedSections.append(section)
                }
            }
        }
        
        self.sections = sortedSections
    }
    
    private func sortItems(in section:CollectionViewSection) {
        var dates = [String]()
        for item in section.items {
            var date = item.photoTakenTime()
            if date == "" {
                date = item.fileName
            }
            dates.append(date)
        }
        
        let sortedDates = dates.sorted()
        
        var sortedItems = [ImageFile]()
        
        for date in sortedDates {
            for item in section.items {
                if item.photoTakenTime() == date || item.fileName == date {
                    sortedItems.append(item)
                }
            }
        }
        
        section.items = sortedItems
    }
    
    private func isOnlyOneDateSection() -> Bool {
        if sections.count == 1 {
            return true
        }
        var previousTitle = ""
        for section in sections {
            if section.title != "Others" {
                if !section.title.contains(" ") {
                    if previousTitle == "" {
                        previousTitle = section.title
                    }else{
                        if previousTitle != section.title {
                            return false;
                        }
                    }
                }else{
                    let date = section.title.components(separatedBy: " ").first
                    if previousTitle == "" {
                        previousTitle = date!
                    }else{
                        if previousTitle != date {
                            return false;
                        }
                    }
                }
            }
        }
        return true
    }
  
    private func transformToDomainItems(urls: [NSURL]) {
        if items.count > 0 {   // When not initial folder folder
            items.removeAll()
        }
        for url in urls {
            let imageFile = ImageFile(url: url, indicator: self.indicator)
            items.append(imageFile)
        }
        ModelStore.save()
    }
  
    private func walkthruDirectoryForFileUrls(startingURL: NSURL) -> [NSURL]? {

        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles,
                                                                .skipsSubdirectoryDescendants,
                                                                .skipsPackageDescendants]
        let fileManager = FileManager.default
        let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey]

        guard let directoryEnumerator = fileManager.enumerator(at: startingURL as URL,
                                                               includingPropertiesForKeys: resourceValueKeys,
                                                               options: options,
                                                               errorHandler: { url, error in
                                                                    print("`directoryEnumerator` error: \(error).")
                                                                    return true
                                                               }
                                                              ) else { return nil }

        var urls: [NSURL] = []
        for case let url as NSURL in directoryEnumerator {
            do {
                let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                guard isRegularFileResourceValue.boolValue else { continue }
                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                guard (UTTypeConformsTo(fileType as CFString, kUTTypeImage) || UTTypeConformsTo(fileType as CFString, kUTTypeMovie)) else { continue }
                urls.append(url)
            }
            catch {
                print("Unexpected error occured: \(error).")
            }
        }
        return urls
    }
  
    // get number of items in section
    func numberOfItems(in section: Int) -> Int {
        guard sections.count > 0 else {return 0}
        return sections[section].items.count
    }

    // get single item
    func item(for indexPath: NSIndexPath) -> ImageFile {
        return sections[indexPath.section].items[indexPath.item]
    }
    
    func titleOfSection(_ section: Int) -> String {
        guard sections.count > section else {return ""}
        return sections[section].title
    }
    
    func getItems() -> [ImageFile] {
        return self.items
    }
  
}
