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

enum CollectionViewLoadSource : Int {
    case repository
    case moment
    case event
    case search
    case unknown
}

struct CollectionViewLastRequest {
    var loadSource:CollectionViewLoadSource? = nil
    var lastLoadSource:CollectionViewLoadSource? = nil
    var indicator:Accumulator? = nil
    var folderURL:URL? = nil
    var year:Int? = nil
    var month:Int? = nil
    var day:Int? = nil
    var ignoreDate:Bool = false
    var event:String? = nil
    var place:String? = nil
    var imageSource:[String]? = nil
    var cameraModel:[String]? = nil
    var country = ""
    var province = ""
    var city = ""
    var pageSize = 0
    var pageNumber = 0
    var subdirectories = false
    var searchCondition:SearchCondition? = nil
}

class CollectionViewItemsLoader: NSObject {
  
    private var items = [ImageFile]()
    var numberOfSections = 1
    var singleSectionMode = false
    var considerPlaces = true
    var indicator:Accumulator?
    var showHidden:Bool = false
    var hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil
    private var cancelling:Bool = false
    private var loading:Bool = false
    
    private var onCancelCompleted: (() -> Void)? = nil
    
    private var sections = [CollectionViewSection]()
    
    var lastRequest:CollectionViewLastRequest = CollectionViewLastRequest()
    
    func cancel(onCancelled: (() -> Void)? = nil ) {
        self.onCancelCompleted = onCancelled
        self.cancelling = true
    }
    
    func isLoading() -> Bool {
        return self.loading
    }

    
    func load(from folderURL: URL, indicator:Accumulator? = nil, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) {
        loading = true
        
        lastRequest.loadSource = .repository
        lastRequest.folderURL = folderURL
        lastRequest.indicator = indicator
        lastRequest.pageSize = pageSize
        lastRequest.pageNumber = pageNumber
        lastRequest.subdirectories = subdirectories
        
        self.indicator = indicator
        //let urls = walkthruDirectoryForFileUrls(startingURL: folderURL)
        //print("loading folder from database: \(folderURL.path)")
        let photoFiles = walkthruDatabaseForPhotoFiles(startingURL: folderURL, includeHidden: showHidden, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
        if photoFiles == nil || photoFiles?.count == 0 {
            print("LOADED nothing from entry \(folderURL.path)")
            //print("loading folder from filesystem instead: \(folderURL.path)")
            //let urls = walkthruDirectoryForFileUrls(startingURL: folderURL)
            //setupItems(urls: urls)
            setupItems(photoFiles: [])
        }else{
            print("LOADED \(photoFiles?.count ?? 0) images from entry \(folderURL.path)")
            setupItems(photoFiles: photoFiles)
        }
    }
    
    // load without event, paginated
    func load(year:Int, month:Int, day:Int, ignoreDate:Bool = false,
              country:String = "", province:String = "", city:String = "", place:String?,
              filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil,
              indicator:Accumulator? = nil,
              pageSize:Int = 0, pageNumber:Int = 0) {
        loading = true
        
        lastRequest.loadSource = .moment
        lastRequest.year = year
        lastRequest.month = month
        lastRequest.day = day
        lastRequest.ignoreDate = ignoreDate
        lastRequest.country = country
        lastRequest.province = province
        lastRequest.city = city
        lastRequest.place = place
        lastRequest.indicator = indicator
        lastRequest.imageSource = filterImageSource
        lastRequest.cameraModel = filterCameraModel
        lastRequest.pageSize = pageSize
        lastRequest.pageNumber = pageNumber
        lastRequest.subdirectories = false
        
        self.indicator = indicator
        
        //var urls: [URL] = []
        print("\(Date()) Loading photo files from db")
        let photoFiles = ModelStore.default.getPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate,
                                                          country: country, province: province, city: city, place: place,
                                                          includeHidden: showHidden,
                                                          imageSource: filterImageSource, cameraModel: filterCameraModel,
                                                          hiddenCountHandler: self.hiddenCountHandler,
                                                          pageSize: pageSize, pageNumber: pageNumber)
        //print("GOT PHOTOS for year:\(year) month:\(month) day:\(day) place:\(place) count \(photoFiles.count)")
        //for photoFile in photoFiles {
        //    urls.append(URL(fileURLWithPath: photoFile.path!))
        //}
        print("\(Date()) Setting up items ")
        setupItems(photoFiles: photoFiles)
        print("\(Date()) Set up items DONE")
    }
    
    // load with event, paginated
    func load(year:Int, month:Int, day:Int,
              event:String,
              country:String = "", province:String = "", city:String = "", place:String,
              filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil,
              indicator:Accumulator? = nil,
              pageSize:Int = 0, pageNumber:Int = 0) {
        loading = true
        
        lastRequest.loadSource = .event
        lastRequest.year = year
        lastRequest.month = month
        lastRequest.day = day
        lastRequest.country = country
        lastRequest.province = province
        lastRequest.city = city
        lastRequest.place = place
        lastRequest.event = event
        lastRequest.indicator = indicator
        lastRequest.imageSource = filterImageSource
        lastRequest.cameraModel = filterCameraModel
        lastRequest.pageSize = pageSize
        lastRequest.pageNumber = pageNumber
        lastRequest.subdirectories = false
        
        self.indicator = indicator
        
        //var urls: [URL] = []
        let photoFiles = ModelStore.default.getPhotoFiles(year: year, month: month, day: day,
                                                          event: event,
                                                          country: country, province: province, city: city, place:place,
                                                          includeHidden: showHidden,
                                                          imageSource: filterImageSource, cameraModel: filterCameraModel,
                                                          hiddenCountHandler: self.hiddenCountHandler,
                                                          pageSize: pageSize, pageNumber: pageNumber)
        //print("GOT PHOTOS for year:\(year) month:\(month) day:\(day) event:\(event) place:\(place) count \(photoFiles.count)")
        //for photoFile in photoFiles {
        //    urls.append(URL(fileURLWithPath: photoFile.path!))
        //}
        setupItems(photoFiles: photoFiles)
        
    }
    
    func clearSearch(pageSize:Int = 0, pageNumber:Int = 0) {
        lastRequest.loadSource = lastRequest.lastLoadSource
        lastRequest.searchCondition = nil
        lastRequest.pageSize = pageSize
        lastRequest.pageNumber = pageNumber
    }
    
    // search, paginated
    func search(conditions:SearchCondition,
              indicator:Accumulator? = nil,
              pageSize:Int = 0, pageNumber:Int = 0) {
        loading = true
        
        lastRequest.lastLoadSource = lastRequest.loadSource
        lastRequest.loadSource = .search
        lastRequest.searchCondition = conditions
        lastRequest.pageSize = pageSize
        lastRequest.pageNumber = pageNumber
        lastRequest.subdirectories = false
        lastRequest.indicator = indicator
        
        self.indicator = indicator
        
        //var urls: [URL] = []
        let photoFiles = ModelStore.default.searchPhotoFiles(years: conditions.years,
                                                             months: conditions.months,
                                                             days: conditions.days,
                                                             peopleIds: conditions.peopleIds,
                                                             keywords: conditions.keywords,
                                                             includeHidden: conditions.includeHidden,
                                                             hiddenCountHandler: self.hiddenCountHandler,
                                                             pageSize: pageSize, pageNumber: pageNumber)
        //print("GOT PHOTOS for year:\(year) month:\(month) day:\(day) event:\(event) place:\(place) count \(photoFiles.count)")
        //for photoFile in photoFiles {
        //    urls.append(URL(fileURLWithPath: photoFile.path!))
        //}
        setupItems(photoFiles: photoFiles)
        
    }
    
    fileprivate func reloadImages() {
        var images:[Image] = []
        for imageFile in self.items {
            if let oldImage = imageFile.imageData {
                if let image = ModelStore.default.getImage(path: oldImage.path) {
                    images.append(image)
                }
            }
        }
        setupItems(photoFiles: images)
    }
    
    func reload() {
        print("RELOAD LAST SOURCE = \(lastRequest.loadSource ?? .unknown)")
        if lastRequest.loadSource == nil {
            self.reloadImages()
        }else{
            if lastRequest.indicator != nil {
                lastRequest.indicator?.reset()
            }
            
            if lastRequest.loadSource == .repository {
                self.load(from: lastRequest.folderURL!,
                          indicator: lastRequest.indicator,
                          pageSize: lastRequest.pageSize, pageNumber: lastRequest.pageNumber,
                          subdirectories: lastRequest.subdirectories)
            }else if lastRequest.loadSource == .moment {
                self.load(year: lastRequest.year!, month: lastRequest.month!, day: lastRequest.day!, ignoreDate: lastRequest.ignoreDate,
                          country:lastRequest.country, province:lastRequest.province, city:lastRequest.city,
                          place: lastRequest.place,
                          filterImageSource: lastRequest.imageSource, filterCameraModel: lastRequest.cameraModel,
                          indicator: lastRequest.indicator,
                          pageSize: lastRequest.pageSize, pageNumber: lastRequest.pageNumber)
            }else if lastRequest.loadSource == .event {
                self.load(year: lastRequest.year!, month: lastRequest.month!, day: lastRequest.day!,
                          event: lastRequest.event!,
                          place: lastRequest.place!,
                          filterImageSource: lastRequest.imageSource, filterCameraModel: lastRequest.cameraModel,
                          indicator: lastRequest.indicator,
                          pageSize: lastRequest.pageSize, pageNumber: lastRequest.pageNumber)
            }else if lastRequest.loadSource == .search, let condition = lastRequest.searchCondition {
                self.search(conditions: condition,
                            indicator: lastRequest.indicator,
                            pageSize: lastRequest.pageSize,
                            pageNumber: lastRequest.pageNumber)
            }
        }
    }
    
    func getItem(at index:Int, section:Int = 0) -> ImageFile? {
        if section >= sections.count {
            return nil
        }
        if index >= sections[section].items.count {
            return nil
        }
        return sections[section].items[index]
    }
    
    func getItem(path:String) -> ImageFile?{
        for item in items {
            if item.url.path == path {
                return item
            }
        }
        return nil
    }
    
    func getItemIndex(path:String, section:Int = 0) -> Int? {
        if section >= sections.count {
            return nil
        }
        let sec = sections[section]
        var i = 0
        for item in sec.items {
            if item.url.path == path {
                return i
            }
            i += 1
        }
        return nil
    }
    
    func clean() {
        setupItems(urls: nil)
    }

    func setupItems(urls: [URL]?, cleanViewBeforeLoading:Bool = true) {
        
        if items.count > 0 {
            items.removeAll()
        }
        
        if cleanViewBeforeLoading {
            for section in sections {
                section.items.removeAll()
            }
            sections.removeAll()
            
            numberOfSections = 0
            sections = [CollectionViewSection]()
        }
            
        guard urls != nil && (urls?.count)! > 0 else {return}
        
        if indicator != nil {
            indicator?.reset()
            indicator?.setTarget((urls?.count)!)
        }

        if let urls = urls {
            self.transformToDomainItems(urls: urls)
        }
        //self.reorganizeItems(considerPlaces: true)

        self.loading = false
        
        if self.cancelling {
            self.cancelling = false
            if self.onCancelCompleted != nil {
                self.onCancelCompleted!()
            }
            return
        }
    }
    
    func setupItems(photoFiles: [Image]?, cleanViewBeforeLoading:Bool = true){
        if items.count > 0 {
            items.removeAll()
        }
        
        if cleanViewBeforeLoading {
            for section in sections {
                section.items.removeAll()
            }
            sections.removeAll()
            
            numberOfSections = 0
            sections = [CollectionViewSection]()
        }
        
        guard photoFiles != nil && (photoFiles?.count)! > 0 else {
            self.loading = false
            return
        }
        
        if indicator != nil {
            indicator?.reset()
            indicator?.setTarget((photoFiles?.count)!)
        }
        
        if let photoFiles = photoFiles {
            print("\(Date()) Transforming items to domain ")
            self.transformToDomainItems(photoFiles: photoFiles)
            print("\(Date()) Transforming items to domain: DONE ")
        }
        
        self.loading = false
        
        if self.cancelling {
            self.cancelling = false
            if self.onCancelCompleted != nil {
                self.onCancelCompleted!()
            }
            return
        }
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
        let section:CollectionViewSection = self.getSection(title: "All")!
        section.items.removeAll()
        
        for item in items {
            print(item.place)
            section.items.append(item)
        }
        sortItems(in: section)
        self.numberOfSections = 1
    }
    
    func getSection(title: String, createIfNotExist:Bool = true) -> CollectionViewSection? {
        for section in self.sections {
            if section.title == title {
                return section
            }
        }
        if createIfNotExist {
            let section:CollectionViewSection = CollectionViewSection(title)
            self.sections.append(section)
            return section
        }else{
            return nil
        }
    }
    
    private func collectDomainItemToMultipleSection(_ dateFormat:String = "yyyy-MM-dd") {
        for section in sections {
            section.items.removeAll()
        }
        sections.removeAll()
        
        for item in items {
            var title:String = item.photoTakenDateString(dateFormat, forceUpdate: true)
            
            if title == "" {
                title = "Others"
            }
            
            if item.event != "" {
                title = title + " " + item.event
            }
            
            if self.considerPlaces && item.place != "" {
                title = title + " @ " + item.place.replacingOccurrences(of: "特别行政区", with: "")
            }
            let section:CollectionViewSection = self.getSection(title: title)!
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
    
    func checkAll() {
        for section in sections {
            for item in section.items {
                if let viewItem = item.collectionViewItem {
                    viewItem.check()
                }
            }
        }
    }
    
    func uncheckAll() {
        for section in sections {
            for item in section.items {
                if let viewItem = item.collectionViewItem {
                    viewItem.uncheck()
                }
            }
        }
    }
    
    private func sortItems(in section:CollectionViewSection) {
        var dates:Set<String> = []
        for item in section.items {
            var date = item.photoTakenTime()
            if date == "" {
                date = item.url.path
            }
            dates.insert(date)
        }
        
        let sortedDates = dates.sorted()
        
        var sortedItems = [ImageFile]()
        
        for date in sortedDates {
            for item in section.items {
                if item.photoTakenTime() == date || item.url.path == date {
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
  
    private func transformToDomainItems(urls: [URL]) {
        
        if self.cancelling {
            return
        }
        
        if items.count > 0 {   // When not initial folder folder
            items.removeAll()
        }
        print("\(Date()) Loading duplicate photos from db")
        let duplicates:Duplicates = ModelStore.default.getDuplicatePhotos()
        print("Found duplicates: \(duplicates.paths.count)")
        print("\(Date()) Loading duplicate photos from db: DONE")
        
        for url in urls {
            
            if self.cancelling {
                return
            }
            
            let imageFile = ImageFile(url: url, indicator: self.indicator, sharedDB:ModelStoreGRDB.sharedDBPool())
            
            print("\(Date()) Checking duplicate for a photo")

            if duplicates.paths.contains(url.path) {
                imageFile.hasDuplicates = true
                imageFile.duplicatesKey = duplicates.pathToKey[url.path] ?? ""
                print(imageFile.duplicatesKey)
            }else {
                imageFile.hasDuplicates = false
                imageFile.duplicatesKey = ""
            }
            print("\(Date()) Checking duplicate for a photo: DONE")
            
            // prefetch thumbnail to improve performance of collection view
            let _ = imageFile.thumbnail
            
            items.append(imageFile)
        }
        //ModelStore.save()
        //print("TRANSFORMED TO ITEMS \(urls.count)")
    }
    
    private func transformToDomainItems(photoFiles: [Image]){
        
        if self.cancelling {
            return
        }
        
        if items.count > 0 {   // When not initial folder folder
            items.removeAll()
        }
        
        print("\(Date()) Loading duplicate photos from db")
        let duplicates:Duplicates = ModelStore.default.getDuplicatePhotos()
        print("Found duplicates: \(duplicates.paths.count)")
        print(lastRequest)
//        if duplicates.paths.count > 0 {
//            for dup in duplicates.paths {
//                print(dup)
//            }
//        }
        print("\(Date()) Loading duplicate photos from db: DONE")
        
        for photoFile in photoFiles {
            
            if self.cancelling {
                if self.indicator != nil {
                    self.indicator?.forceCancel()
                }
                return
            }
            
            let imageFile = ImageFile(photoFile: photoFile, indicator: self.indicator, sharedDB:ModelStoreGRDB.sharedDBPool())
            
            if duplicates.paths.contains(photoFile.path) {
                imageFile.hasDuplicates = true
                imageFile.duplicatesKey = duplicates.pathToKey[photoFile.path] ?? ""
                print(imageFile.duplicatesKey)
            }else {
                imageFile.hasDuplicates = false
                imageFile.duplicatesKey = ""
            }
            
            // prefetch thumbnail to improve performance of collection view
            let _ = imageFile.thumbnail
            
            items.append(imageFile)
        }
    }
    
    private func walkthruDatabaseForFileUrls(startingURL: URL, includeHidden:Bool = true) -> [URL]? {
        
        if self.cancelling {
            return nil
        }
        
        var urls: [URL] = []
        for photoFile in ModelStore.default.getPhotoFiles(parentPath: startingURL.path, includeHidden: includeHidden) {
            
            if self.cancelling {
                return nil
            }
            
            urls.append(URL(fileURLWithPath: photoFile.path))
        }
        return urls
    }
    
    private func walkthruDatabaseForPhotoFiles(startingURL: URL, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image]? {
        
        if self.cancelling {
            return nil
        }
        
        return ModelStore.default.getPhotoFiles(parentPath: startingURL.path, includeHidden: includeHidden, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
    }
  
    private func walkthruDirectoryForFileUrls(startingURL: URL) -> [URL]? {
        
        if self.cancelling {
            return nil
        }

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

        var urls: [URL] = []
        for case let url as NSURL in directoryEnumerator {
            
            if self.cancelling {
                return nil
            }
            
            do {
                let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                guard isRegularFileResourceValue.boolValue else { continue }
                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                guard (UTTypeConformsTo(fileType as CFString, kUTTypeImage) || UTTypeConformsTo(fileType as CFString, kUTTypeMovie)) else { continue }
                urls.append(url as URL)
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
    
    func getCheckedItems() -> [ImageFile] {
        print("testing checked")
        var result:[ImageFile] = []
        print("sections count: \(sections.count) ")
        for section in sections {
            print("items count: \(section.items.count)")
            for item in section.items {
                
                print("viewItem is null? \(item.collectionViewItem == nil)")
                print("imageFile is null? \(item.collectionViewItem == nil ||  item.collectionViewItem?.imageFile == nil)")
                if let viewItem = item.collectionViewItem, let imageFile = viewItem.imageFile {
                    print("checked? \(viewItem.isChecked())")
                    if viewItem.isChecked() {
                        result.append(imageFile)
                    }
                }
            }
        }
        return result
    }
    
    func addItem(_ imageFile:ImageFile){
        let i = items.index(where: { $0.url == imageFile.url })
        if i == nil {
            items.append(imageFile)
        }
    }
    
    func removeItem(_ imageFile:ImageFile){
        if let i = items.index(where: { $0.url == imageFile.url }) {
            items.remove(at: i)
        }
    }
  
}
