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
    
    var lblCaptionTotalRecords: NSTextField!
    var lblTotalRecords: NSTextField!
    
    var lblCaptionShowRecords: NSTextField!
    var lblShowRecords: NSTextField!
    
    var lblCaptionOnPage1: NSTextField!
    var lstJumpOnPage: NSPopUpButton!
    var lblCaptionOnPage2: NSTextField!
    
    var lstPageSize: NSPopUpButton!
    var lblCaptionPageSize: NSTextField!
    
    var btnFirstPage: NSButton!
    var btnPreviousPage: NSButton!
    var lblPageNumber: NSTextField!
    var btnNextPage: NSButton!
    var btnLastPage: NSButton!
    
    var btnLoadPage: NSButton!
    
    fileprivate var lastRequest:CollectionViewLastRequest!
    fileprivate var total = 0
    fileprivate var pages = 0
    fileprivate var currentPage = 0
    fileprivate var totalPages = 0
    fileprivate var pageSize = 0
    fileprivate var onLoad: ((_ pageSize:Int, _ pageNumber:Int) -> Void)?
    fileprivate var onCountTotal: (() -> Int)?
    fileprivate var onCountHidden: (() -> Int)?
    fileprivate var onPaginationStateChanges: ((Int, Int) -> Void)? // currentPage, totalPages
    fileprivate var onPaginationSizeChanges: ((Int, Int, Int) -> Void)? // currentPage, pageSize, totalRecords
    
    init(
    
         lblCaptionTotalRecords: NSTextField,
         lblTotalRecords: NSTextField,

         lblCaptionShowRecords: NSTextField,
         lblShowRecords: NSTextField,
         
         lblCaptionOnPage1: NSTextField,
         lstJumpOnPage: NSPopUpButton,
         lblCaptionOnPage2: NSTextField,
         
         lstPageSize: NSPopUpButton,
         lblCaptionPageSize: NSTextField,

         btnFirstPage: NSButton,
         btnPreviousPage: NSButton,
         lblPageNumber: NSTextField,
         btnNextPage: NSButton,
         btnLastPage: NSButton,
    
         btnLoadPage: NSButton
    ) {
        
        self.lblCaptionTotalRecords = lblCaptionTotalRecords
        self.lblTotalRecords = lblTotalRecords
        
        self.lblCaptionShowRecords = lblCaptionShowRecords
        self.lblShowRecords = lblShowRecords
        
        self.lblCaptionOnPage1 = lblCaptionOnPage1
        self.lstJumpOnPage = lstJumpOnPage
        self.lblCaptionOnPage2 = lblCaptionOnPage2
        
        self.lstPageSize = lstPageSize
        self.lblCaptionPageSize = lblCaptionPageSize
        
        self.btnFirstPage = btnFirstPage
        self.btnPreviousPage = btnPreviousPage
        self.btnNextPage = btnNextPage
        self.lblPageNumber = lblPageNumber
        self.btnLastPage = btnLastPage
        
        self.btnLoadPage = btnLoadPage
        
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
        
        self.lblCaptionTotalRecords.stringValue = Words.collection_pagination_total.word()
        self.lblCaptionShowRecords.stringValue = Words.collection_pagination_shows.word()
        
        self.lblCaptionOnPage1.stringValue = Words.collection_pagination_on_page1.word()
        self.lblCaptionOnPage2.stringValue = Words.collection_pagination_on_page2.word()
        
        self.lblCaptionPageSize.stringValue = Words.collection_pagination_items_per_page.word()
        
        self.btnFirstPage.title = Words.collection_pagination_first_page.word()
        self.btnPreviousPage.title = Words.collection_pagination_previous_page.word()
        self.btnNextPage.title = Words.collection_pagination_next_page.word()
        self.btnNextPage.title = Words.collection_pagination_last_page.word()
        
        self.btnLoadPage.title = Words.collection_pagination_reload.word()
        
        self.countImages()
        self.calculatePages()
    }
    
    fileprivate func countImages() {
        if let onCountTotal = self.onCountTotal {
            self.total = onCountTotal()
        }
        var hiddenCount = 0
        if let onCountHidden = self.onCountHidden {
            hiddenCount = onCountHidden()
        }
        self.lblTotalRecords.stringValue = "\(self.total) (\(hiddenCount) \(Words.library_tree_hidden.word()))"
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
        if self.currentPage == 1 {
            self.btnPreviousPage.isEnabled = false
            self.btnFirstPage.isEnabled = false
        }else{
            self.btnPreviousPage.isEnabled = true
            self.btnFirstPage.isEnabled = true
        }
        if self.currentPage == self.pages {
            self.btnNextPage.isEnabled = false
        }else{
            self.btnNextPage.isEnabled = true
        }
        let start = pageSize * (currentPage - 1) + 1
        var end = pageSize * currentPage
        if end > total {
            end = total
        }
        self.lblShowRecords.stringValue = "\(start) - \(end)"
        if let onPaginationStateChanges = self.onPaginationStateChanges {
            onPaginationStateChanges(
                self.currentPage,
                self.pages
            )
        }
        self.logger.log("divided pages \(self.pages)")
    }
    
    func onFirstPage() {
        self.currentPage = 1
        self.calculatePages()
        if let onLoad = self.onLoad {
            onLoad(self.pageSize, self.currentPage)
        }
    }
    
    func onPreviousPage() {
        self.countImages()
        self.currentPage -= 1
        self.calculatePages()
        if let onLoad = self.onLoad {
            onLoad(self.pageSize, self.currentPage)
        }
    }
    
    func onNextPage() {
        self.countImages()
        self.currentPage += 1
        self.calculatePages()
        if let onLoad = self.onLoad {
            onLoad(self.pageSize, self.currentPage)
        }
        
    }
    
    func onLastPage() {
        self.countImages()
        self.currentPage = self.pages
        self.calculatePages()
        if let onLoad = self.onLoad {
            onLoad(self.pageSize, self.currentPage)
        }
    }
    
}
