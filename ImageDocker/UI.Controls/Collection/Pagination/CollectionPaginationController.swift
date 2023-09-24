//
//  CollectionPaginationController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/7/17.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import LoggerFactory

class CollectionPaginationController {
    
    let logger = LoggerFactory.get(category: "Collection", subCategory: "Page")
    
    
    // MARK: PROPERTIES
    var panel: NSView! // the panel
    
    var lblShowRecords: NSTextField! // how many records are shown
    var lblHiddenRecords: NSTextField! // how many recrods are hidden
    
    var lstPageSize: NSPopUpButton! // page size
    var lblCaptionPageSize: NSTextField! // "per page"
    
    var btnFirstPage: NSButton! // first page |<
    var btnPreviousPage: NSButton! // previous page <
    var lblPageNumber: NSTextField! // "current page / total pages"
    var btnNextPage: NSButton! // next page >
    var btnLastPage: NSButton! // last page >|
    
    var btnLoadPage: NSButton! // reload
    
    fileprivate var lastRequest:CollectionViewLastRequest!
    fileprivate var total = 0
    fileprivate var pages = 0
    fileprivate var currentPage = 0
    fileprivate var totalPages = 0
    fileprivate var pageSize = 0
    fileprivate var onLoad: ((_ pageSize:Int, _ pageNumber:Int) -> Void)?
    fileprivate var onCountTotal: (() -> Int)?
    fileprivate var onCountHidden: (() -> Int)?
    fileprivate var onPaginationStateChanges: ((_ currentPage:Int, _ totalPages:Int) -> Void)? // currentPage, totalPages
    fileprivate var onPaginationSizeChanges: ((_ currentPage:Int, _ pageSize:Int, _ totalRecords:Int) -> Void)? // currentPage, pageSize, totalRecords
    
    init(
         panel: NSView,
         lblShowRecords: NSTextField,
         lblHiddenRecords: NSTextField,
         
         lstPageSize: NSPopUpButton,
         lblCaptionPageSize: NSTextField,

         btnFirstPage: NSButton,
         btnPreviousPage: NSButton,
         lblPageNumber: NSTextField,
         btnNextPage: NSButton,
         btnLastPage: NSButton,
    
         btnLoadPage: NSButton
    ) {
        self.panel = panel
        self.lblShowRecords = lblShowRecords
        self.lblHiddenRecords = lblHiddenRecords
        
        self.lstPageSize = lstPageSize
        self.lblCaptionPageSize = lblCaptionPageSize
        
        self.btnFirstPage = btnFirstPage
        self.btnPreviousPage = btnPreviousPage
        self.btnNextPage = btnNextPage
        self.lblPageNumber = lblPageNumber
        self.btnLastPage = btnLastPage
        
        self.btnLoadPage = btnLoadPage
        
    }
    
    func initCounter(
        onCountTotal: @escaping (() -> Int),
        onCountHidden: @escaping (() -> Int)
    ) {
        self.onCountTotal = onCountTotal
        self.onCountHidden = onCountHidden
    }
    
    func initChangeHandler(
        onPaginationStateChanges: @escaping ((_ currentPage:Int, _ totalPages:Int) -> Void),
        onPaginationSizeChanges: @escaping ((_ currentPage:Int, _ pageSize:Int, _ totalRecords:Int) -> Void)
    ) {
        self.onPaginationSizeChanges = onPaginationSizeChanges
        self.onPaginationStateChanges = onPaginationStateChanges
    }
    
    func initLoader(onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void)) {
        self.onLoad = onLoad
    }
    
    func initView(_ lastRequest:CollectionViewLastRequest,
                  onCountTotal: @escaping (() -> Int),
                  onCountHidden: @escaping (() -> Int),
                  onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void),
                  onPaginationStateChanges: @escaping ((Int, Int) -> Void),
                  onPaginationSizeChanges: @escaping ((Int, Int, Int) -> Void)
    ) {
        
        self.lastRequest = lastRequest
        self.onCountTotal = onCountTotal
        self.onCountHidden = onCountHidden
        self.onLoad = onLoad
        self.onPaginationSizeChanges = onPaginationSizeChanges
        self.onPaginationStateChanges = onPaginationStateChanges
        
        self.lblCaptionPageSize.stringValue = Words.collection_pagination_items_per_page.word()
        
        self.countImages()
        self.calculatePages()
    }
    
    func hide() {
        self.panel.isHidden = true
    }
    
    func show() {
        self.panel.isHidden = false
    }
    
    func disable() {
        self.btnLastPage.isEnabled = false
        self.btnNextPage.isEnabled = false
        self.btnPreviousPage.isEnabled = false
        self.btnFirstPage.isEnabled = false
        self.btnLoadPage.isEnabled = false
    }
    
    func enable() {
        self.btnLastPage.isEnabled = true
        self.btnNextPage.isEnabled = true
        self.btnPreviousPage.isEnabled = true
        self.btnFirstPage.isEnabled = true
        self.btnLoadPage.isEnabled = true
    }
    
    
    // 1
    func changePaginationState(currentPage:Int, pageSize:Int, totalRecords:Int) {
        self.logger.log("changePaginationState(currentPage,pageSize,totalRecords)")
        var pages = totalRecords / pageSize
        if totalRecords > (pages * pageSize) {
            pages += 1
        }
        self.pageSize = pageSize
        self.countImages()
        self.logger.log("totalrecords: \(totalRecords), pageSize:\(pageSize), pages:\(pages)")
        self.changePaginationState(currentPage: currentPage, totalPages: pages)
    }
    
    // 2
    func changePaginationState(currentPage:Int, totalPages:Int){
        self.logger.log("changePaginationState(currentPage,totalPages)")
        self.logger.log("current-page: \(currentPage), total-pages: \(totalPages)")
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.togglePaginationButtons()
        self.show()
    }
    
    func togglePaginationButtons() {
        
        self.lblPageNumber.stringValue = "\(currentPage) / \(totalPages)"
        
        self.btnFirstPage.isHidden = (currentPage <= 1)
        self.btnPreviousPage.isHidden = (currentPage <= 1)
        self.btnNextPage.isHidden = (currentPage >= totalPages)
        self.btnLastPage.isHidden = (currentPage >= totalPages)
        
        self.btnFirstPage.isEnabled = !self.btnFirstPage.isHidden
        self.btnPreviousPage.isEnabled = !self.btnPreviousPage.isHidden
        self.btnNextPage.isEnabled = !self.btnNextPage.isHidden
        self.btnLastPage.isEnabled = !self.btnLastPage.isHidden
    }
    
    fileprivate func countImages() {
        if let onCountTotal = self.onCountTotal {
            self.total = onCountTotal()
        }
        var hiddenCount = 0
        if let onCountHidden = self.onCountHidden {
            hiddenCount = onCountHidden()
        }
        let showCount = self.total - hiddenCount
        self.lblShowRecords.stringValue = "\(showCount)"
        self.lblHiddenRecords.stringValue = "\(hiddenCount)"
    }
    
    fileprivate func calculatePages() {
        
        if let selectedSize = self.lstPageSize.titleOfSelectedItem {
            self.pageSize = Int(selectedSize) ?? 200
        }
        
        self.pages = self.total / self.pageSize
        if self.pages * self.pageSize < self.total {
            self.pages += 1
        }
        if self.currentPage <= 0 {
            self.currentPage = 1
        }else if self.currentPage > self.pages {
            self.currentPage = self.pages
        }
//        let start = pageSize * (currentPage - 1) + 1
//        var end = pageSize * currentPage
//        if end > total {
//            end = total
//        }
//        self.lblShowRecords.stringValue = "\(total)"
//        self.lblShowRecords.stringValue = "\(start) - \(end)"
        self.togglePaginationButtons()
        
        self.lblPageNumber.stringValue = "\(self.currentPage) / \(self.totalPages)"
        if let onPaginationStateChanges = self.onPaginationStateChanges {
            onPaginationStateChanges(
                self.currentPage,
                self.pages
            )
        }
//        self.logger.log("divided pages \(self.pages)")
    }
    
    func onFirstPage() {
        print("btn -> onFirstPage")
        self.countImages()
        self.currentPage = 1
        self.calculatePages()
        self.reload()
    }
    
    func onPreviousPage() {
        print("btn -> onPreviousPage")
        self.countImages()
        self.currentPage -= 1
        print("gotoPage = \(currentPage)")
        self.calculatePages()
        self.reload()
    }
    
    func onNextPage() {
        print("btn -> onNextPage")
        self.countImages()
        self.currentPage += 1
        print("gotoPage = \(currentPage)")
        self.calculatePages()
        self.reload()
        
    }
    
    func onLastPage() {
        print("btn -> onLastPage")
        self.countImages()
        self.currentPage = self.pages
        print("gotoPage = \(currentPage)")
        self.calculatePages()
        self.reload()
    }
    
    func reload() {
        print("btn -> reload")
        if let onLoad = self.onLoad {
            onLoad(self.pageSize, self.currentPage)
        }
    }
    
}
