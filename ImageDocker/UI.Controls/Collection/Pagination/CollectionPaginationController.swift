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
    fileprivate var totalRecords = 0
    fileprivate var showRecords = 0
    fileprivate var hiddenRecords = 0
    fileprivate var currentPage = 0
    fileprivate var totalPages = 0
    fileprivate var pageSize = 0
    fileprivate var onLoad: ((_ pageSize:Int, _ pageNumber:Int) -> Void)?
    fileprivate var onCountTotal: (() -> Int)?
    fileprivate var onCountHidden: (() -> Int)?
    
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
    
    func initPageSize(pageSize:Int) {
        if pageSize > 0 {
            self.pageSize = pageSize
        }else{
            self.pageSize = 200
        }
    }
    
    func initPageNumber(pageNumber:Int) {
        if pageNumber > 0 {
            self.currentPage = pageNumber
        }else{
            self.currentPage = 1
        }
    }
    
    func initCounter(
        onCountTotal: @escaping (() -> Int),
        onCountHidden: @escaping (() -> Int)
    ) {
        self.onCountTotal = onCountTotal
        self.onCountHidden = onCountHidden
    }
    
    func initLoader(onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void)) {
        self.onLoad = onLoad
    }
    
//    func initView(_ lastRequest:CollectionViewLastRequest,
//                  onCountTotal: @escaping (() -> Int),
//                  onCountHidden: @escaping (() -> Int),
//                  onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void)
//    ) {
//
//        self.lastRequest = lastRequest
//        self.onCountTotal = onCountTotal
//        self.onCountHidden = onCountHidden
//        self.onLoad = onLoad
//
//        self.lblCaptionPageSize.stringValue = Words.collection_pagination_items_per_page.word()
//
//        self.countImages()
//        self.calculatePages()
//    }
    
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
            self.totalRecords = onCountTotal()
        }
        self.hiddenRecords = 0
        if let onCountHidden = self.onCountHidden {
            self.hiddenRecords = onCountHidden()
        }
        self.showRecords = self.totalRecords - self.hiddenRecords
        self.lblShowRecords.stringValue = "\(self.showRecords)"
        self.lblHiddenRecords.stringValue = "\(self.hiddenRecords)"
    }
    
    fileprivate func calculatePages(_ includeHidden:Bool = false) {
        let _totalRecordsToCalculate = includeHidden ? self.totalRecords : self.showRecords
        
        self.pageSize = 200
        if let selectedSize = self.lstPageSize.titleOfSelectedItem {
            self.pageSize = Int(selectedSize) ?? 200
        }
        self.totalPages = _totalRecordsToCalculate / self.pageSize
        if self.totalPages * self.pageSize < _totalRecordsToCalculate {
            self.totalPages += 1
        }
        if self.currentPage <= 0 {
            self.currentPage = 1
        }else if self.currentPage > self.totalPages {
            self.currentPage = self.totalPages
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
    }
    
    func onFirstPage() {
        self.countImages()
        self.currentPage = 1
        self.reload()
    }
    
    func onPreviousPage() {
        self.countImages()
        self.currentPage -= 1
        self.reload()
    }
    
    func onNextPage() {
        self.countImages()
        self.currentPage += 1
        self.reload()
        
    }
    
    func onLastPage() {
        self.countImages()
        self.currentPage = self.totalPages
        self.reload()
    }
    
    func onReload() {
        self.countImages()
        if self.totalPages < self.currentPage {
            self.currentPage = self.totalPages
        }
        self.reload()
    }
    
    func load() {
        self.countImages()
        self.reload()
    }
    
    func reload() {
        self.calculatePages()
        self.togglePaginationButtons()
        self.show()
        if let onLoad = self.onLoad {
            onLoad(self.pageSize, self.currentPage)
        }
    }
    
}
