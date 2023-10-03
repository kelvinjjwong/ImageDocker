//
//  ImageFileCollectionLoader.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//


import Cocoa
import LoggerFactory

class CollectionViewSection {
    
    let logger = LoggerFactory.get(category: "CollectionViewSection")
    
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
    var containerId:Int? = nil
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
    var repositoryId:Int? = nil
    var repositoryVolume:String? = nil
    var rawVolume:String? = nil
}

class CollectionViewItemsLoader : NSObject {
    
    let logger = LoggerFactory.get(category: "CollectionViewItemsLoader")
  
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
    
    func load(containerId: Int, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, indicator:Accumulator? = nil, pageSize:Int = 0, pageNumber:Int = 0) {
        self.logger.log("[load(containerId)] containerId:\(containerId)")
        loading = true
        
        lastRequest.loadSource = .repository
        lastRequest.containerId = containerId
//        lastRequest.folderURL = folderURL
        lastRequest.indicator = indicator
        lastRequest.pageSize = pageSize
        lastRequest.pageNumber = pageNumber
        lastRequest.repositoryId = repositoryId
        lastRequest.repositoryVolume = repositoryVolume
        lastRequest.rawVolume = rawVolume
        
        self.indicator = indicator
        //let urls = walkthruDirectoryForFileUrls(startingURL: folderURL)
        //self.logger.log("loading folder from database: \(folderURL.path)")
        let photoFiles = walkthruDatabaseForPhotoFiles(containerId: containerId, includeHidden: showHidden, pageSize: pageSize, pageNumber: pageNumber)
        if photoFiles == nil || photoFiles?.count == 0 {
            self.logger.log(.trace, "LOADED nothing from container id:\(containerId)")
            //self.logger.log("loading folder from filesystem instead: \(folderURL.path)")
            //let urls = walkthruDirectoryForFileUrls(startingURL: folderURL)
            //setupItems(urls: urls)
            setupItems(photoFiles: [])
        }else{
            self.logger.log(.trace, "LOADED \(photoFiles?.count ?? 0) images from container id:\(containerId)")
            setupItems(photoFiles: photoFiles, repositoryId: repositoryId, repositoryVolume: repositoryVolume, rawVolume: rawVolume)
        }
    }
    
    // load without event, paginated
    func load(year:Int, month:Int, day:Int, ignoreDate:Bool = false,
              country:String = "", province:String = "", city:String = "", place:String?,
              filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil,
              indicator:Accumulator? = nil,
              pageSize:Int = 0, pageNumber:Int = 0) {
        self.logger.log("[load(year,month,day,country,province,city)] year:\(year) month:\(month) day:\(day) country:\(country) province:\(province) city:\(city) pageSize:\(pageSize) pageNumber:\(pageNumber)")
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
        self.logger.log(.trace, "Loading photo files from db")
        let photoFiles = ImageSearchDao.default.getPhotoFiles(filter: ViewController.collectionFilter, year: year, month: month, day: day, ignoreDate: ignoreDate,
                                                          country: country, province: province, city: city, place: place,
                                                          includeHidden: showHidden,
                                                          imageSource: filterImageSource, cameraModel: filterCameraModel,
                                                          hiddenCountHandler: self.hiddenCountHandler,
                                                          pageSize: pageSize, pageNumber: pageNumber)
        //self.logger.log("GOT PHOTOS for year:\(year) month:\(month) day:\(day) place:\(place) count \(photoFiles.count)")
        //for photoFile in photoFiles {
        //    urls.append(URL(fileURLWithPath: photoFile.path!))
        //}
        self.logger.log(.trace, "Setting up items ")
        setupItems(photoFiles: photoFiles)
        self.logger.log(.trace, "Set up items DONE")
    }
    
    // load with event, paginated
    func load(year:Int, month:Int, day:Int,
              event:String,
              country:String = "", province:String = "", city:String = "", place:String,
              filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil,
              indicator:Accumulator? = nil,
              pageSize:Int = 0, pageNumber:Int = 0) {
        self.logger.log("[load(year,month,day,EVENT,country,province,city)] year:\(year) month:\(month) day:\(day) event:\(event) country:\(country) province:\(province) city:\(city) pageSize:\(pageSize) pageNumber:\(pageNumber)")
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
        let photoFiles = ImageSearchDao.default.getPhotoFiles(filter: ViewController.collectionFilter, year: year, month: month, day: day,
                                                          event: event,
                                                          country: country, province: province, city: city, place:place,
                                                          includeHidden: showHidden,
                                                          imageSource: filterImageSource, cameraModel: filterCameraModel,
                                                          hiddenCountHandler: self.hiddenCountHandler,
                                                          pageSize: pageSize, pageNumber: pageNumber)
        //self.logger.log("GOT PHOTOS for year:\(year) month:\(month) day:\(day) event:\(event) place:\(place) count \(photoFiles.count)")
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
        self.logger.log("[search(conditions)]")
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
        let photoFiles = ImageSearchDao.default.searchImages(
             condition: conditions,
             includeHidden: conditions.includeHidden,
             hiddenCountHandler: self.hiddenCountHandler,
             pageSize: pageSize,
             pageNumber: pageNumber)
        
        setupItems(photoFiles: photoFiles)
        
    }
    
    fileprivate func reloadImages() {
        var images:[Image] = []
        for imageFile in self.items {
            if let oldImage = imageFile.imageData, let imageId = oldImage.id {
                if let image = ImageRecordDao.default.getImage(id: imageId) {
                    images.append(image)
                }
            }
        }
        setupItems(photoFiles: images)
    }
    
    func firstPage() {
        lastRequest.pageNumber = 1
        self.reload()
    }
    
    func nextPage() {
        lastRequest.pageNumber += 1
        self.reload()
    }
    
    func previousPage() {
        lastRequest.pageNumber -= 1
        self.reload()
    }
    
    func lastPage() {
        self.logger.log(.error, "TODO lastPage")
    }
    
    func reload() {
        self.logger.log("[reload] LAST SOURCE = \(lastRequest.loadSource ?? .unknown)")
        if lastRequest.loadSource == nil {
            self.reloadImages()
        }else{
            if lastRequest.indicator != nil {
                lastRequest.indicator?.reset()
            }
            
            if lastRequest.loadSource == .repository {
                self.load(containerId: lastRequest.containerId!,
                          indicator: lastRequest.indicator,
                          pageSize: lastRequest.pageSize, pageNumber: lastRequest.pageNumber)
//                self.load(from: lastRequest.folderURL!,
//                          indicator: lastRequest.indicator,
//                          pageSize: lastRequest.pageSize, pageNumber: lastRequest.pageNumber,
//                          subdirectories: lastRequest.subdirectories)
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
    
    /// - Tag: CollectionViewItemsLoader.clean()
    func clean() {
        setupItems(photoFiles: nil)
    }
    
    /// - Tag: CollectionViewItemsLoader.setupItems(images)
    func setupItems(photoFiles images: [Image]?, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil,  cleanViewBeforeLoading:Bool = true){
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
        
        guard images != nil && (images?.count)! > 0 else {
            self.loading = false
            return
        }
        
        if indicator != nil {
            indicator?.reset()
            indicator?.setTarget((images?.count)!)
        }
        
        if let images = images {
            self.logger.log(.trace, "Transforming items to domain ")
            self.transformToDomainItems(images: images, repositoryId: repositoryId, repositoryVolume: repositoryVolume, rawVolume: rawVolume)
            self.logger.log(.trace, "Transforming items to domain: DONE ")
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
                title = title + " @ " + item.place.replacingOccurrences(of: "特别行政区", with: "") // TDOO: put these to preference dialog
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
    
    /// - caller:
    ///   - CollectionViewItemsLoader.setupItems(images)
    /// - Tag: CollectionViewItemsLoader.transformToDomainItems(images)
    private func transformToDomainItems(images: [Image], repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil){
        
        if self.cancelling {
            return
        }
        
        if items.count > 0 {   // When not initial folder folder
            items.removeAll()
        }
        
        self.logger.log(.debug, "Loading duplicate photos from db - START")
        // FIXME: narrow the range of searching duplicate photos
        let startTime = Date()
        let duplicates:Duplicates = ImageDuplicationDao.default.getDuplicatePhotos()
        let timeCost = Date().timeIntervalSince(startTime)
        self.logger.timecost("Found duplicates: \(duplicates.paths.count)", fromDate: startTime)
        //self.logger.log(lastRequest)
//        if duplicates.paths.count > 0 {
//            for dup in duplicates.paths {
//                self.logger.log(dup)
//            }
//        }
        //self.logger.log("Loading duplicate photos from db: DONE")
        
        for image in images {
            
            if self.cancelling {
                if self.indicator != nil {
                    self.indicator?.forceCancel()
                }
                return
            }
            
            let startTime_ImageFile_init = Date()
            
            var _repositoryId = repositoryId
            var _repositoryVolume = repositoryVolume
            var _rawVolume = rawVolume
            
            if repositoryId == nil || repositoryVolume == nil {
                
                if image.repositoryId != 0 {
                    _repositoryId = image.repositoryId
                    if let repository = RepositoryDao.default.getRepository(id: image.repositoryId) {
                        _repositoryVolume = repository.repositoryVolume
                        _rawVolume = repository.storageVolume
                    }
                }else {
                    self.logger.log(.error, "[transformToDomainItems] image.repository == 0, image.id:\(image.id ?? "")")
                }
            }
            
            let imageFile = ImageFile(image: image,
                                      repositoryId: repositoryId,
                                      repositoryVolume: _repositoryVolume,
                                      rawVolume: _rawVolume,
                                      indicator: self.indicator, loadExifFromFile: true)
            self.logger.timecost("[transformToDomainItems][ImageFile.init from database]", fromDate: startTime_ImageFile_init)
            
            if duplicates.paths.contains(image.path) {
                imageFile.hasDuplicates = true
                imageFile.duplicatesKey = duplicates.pathToKey[image.path] ?? ""
                //self.logger.log(imageFile.duplicatesKey)
            }else {
                imageFile.hasDuplicates = false
                imageFile.duplicatesKey = ""
            }
            
            // prefetch thumbnail to improve performance of collection view
            let _ = imageFile.thumbnail
            
            items.append(imageFile)
        }
    }
    
    /// DEPRECATED
    /// - caller:
    ///   - CollectionViewItemsLoader.load(fromUrl)
    /// - Tag: CollectionViewItemsLoader.walkthruDatabaseForPhotoFiles(startingURL)
    private func walkthruDatabaseForPhotoFiles(startingURL: URL, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image]? {
        
        if self.cancelling {
            return nil
        }
        
        return ImageSearchDao.default.getPhotoFiles(parentPath: startingURL.path, includeHidden: includeHidden, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
    }
    
    private func walkthruDatabaseForPhotoFiles(containerId:Int, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0) -> [Image]? {
        if self.cancelling {
            return nil
        }
        return ImageSearchDao.default.getPhotoFiles(containerId: containerId, includeHidden: includeHidden, pageSize: pageSize, pageNumber: pageNumber)
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
        //self.logger.log("testing checked")
        var result:[ImageFile] = []
        //self.logger.log("sections count: \(sections.count) ")
        for section in sections {
            //self.logger.log("items count: \(section.items.count)")
            for item in section.items {
                
                //self.logger.log("viewItem is null? \(item.collectionViewItem == nil)")
                //self.logger.log("imageFile is null? \(item.collectionViewItem == nil ||  item.collectionViewItem?.imageFile == nil)")
                if let viewItem = item.collectionViewItem, let imageFile = viewItem.imageFile {
                    //self.logger.log("checked? \(viewItem.isChecked())")
                    if viewItem.isChecked() {
                        result.append(imageFile)
                    }
                }
            }
        }
        return result
    }
    
    func addItem(_ imageFile:ImageFile){
        let i = items.firstIndex(where: { $0.url == imageFile.url })
        if i == nil {
            items.append(imageFile)
        }
    }
    
    func removeItem(_ imageFile:ImageFile){
        if let i = items.firstIndex(where: { $0.url == imageFile.url }) {
            items.remove(at: i)
        }
    }
  
}
