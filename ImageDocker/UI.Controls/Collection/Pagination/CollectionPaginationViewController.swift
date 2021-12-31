//
//  CollectionPaginationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/12.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class CollectionPaginationViewController: NSViewController {
    
    let logger = ConsoleLogger(category: "CollectionPaginationViewController")
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var lblTotalItems: NSTextField!
    @IBOutlet weak var lblShowsItems: NSTextField!
    @IBOutlet weak var lstPageSize: NSPopUpButton!
    @IBOutlet weak var btnFirstPage: NSButton!
    @IBOutlet weak var btnPreviousPage: NSButton!
    @IBOutlet weak var btnNextPage: NSButton!
    
    @IBOutlet weak var boxPagination: NSBox!
    @IBOutlet weak var lblCaptionTotalRecords: NSTextField!
    @IBOutlet weak var lblCaptionShowRecords: NSTextField!
    @IBOutlet weak var lblCaptionPageSize: NSTextField!
    @IBOutlet weak var btnLoadPage: NSButton!
    
    fileprivate var lastRequest:CollectionViewLastRequest!
    fileprivate var total = 0
    fileprivate var pages = 0
    fileprivate var currentPage = 0
    fileprivate var totalPages = 0
    fileprivate var pageSize = 0
    fileprivate var onLoad: ((_ pageSize:Int, _ pageNumber:Int) -> Void)!
    fileprivate var onCountTotal: (() -> Int)!
    fileprivate var onCountHidden: (() -> Int)!
    fileprivate var onPaginationStateChanges: ((Int, Int) -> Void)! // currentPage, totalPages
    
    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: "CollectionPaginationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.boxPagination.title = Words.library_tree_collection_view_pagination.word()
        self.lblCaptionTotalRecords.stringValue = Words.library_tree_pagination_total.word()
        self.lblCaptionPageSize.stringValue = Words.library_tree_pagination_items_per_page.word()
        self.lblCaptionShowRecords.stringValue = Words.library_tree_pagination_shows.word()
        self.btnFirstPage.title = Words.library_tree_pagination_first_page.word()
        self.btnPreviousPage.title = Words.library_tree_pagination_previous.word()
        self.btnNextPage.title = Words.library_tree_pagination_next.word()
        self.btnLoadPage.title = Words.library_tree_pagination_load.word()
    }
    
    func initView(_ lastRequest:CollectionViewLastRequest,
                  onCountTotal: @escaping (() -> Int),
                  onCountHidden: @escaping (() -> Int),
                  onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void),
                  onPaginationStateChanges: @escaping ((Int, Int) -> Void)
    ) {
        self.lastRequest = lastRequest
        self.pageSize = lastRequest.pageSize
        self.currentPage = lastRequest.pageNumber
        self.onLoad = onLoad
        self.onCountTotal = onCountTotal
        self.onCountHidden = onCountHidden
        self.onPaginationStateChanges = onPaginationStateChanges
        self.countImages()
        self.calculatePages()
        
    }
    
    
    // MARK: ACTIONS
    @IBAction func onFirstPageClicked(_ sender: NSButton) {
        self.currentPage = 1
        self.calculatePages()
    }
    
    public func gotoFirstPage() {
        self.currentPage = 1
        self.calculatePages()
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    @IBAction func onPreviousPageClicked(_ sender: NSButton) {
        self.currentPage -= 1
        self.calculatePages()
    }
    
    public func gotoPreviousPage() {
        self.currentPage -= 1
        self.calculatePages()
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    @IBAction func onNextPageClicked(_ sender: NSButton) {
        self.currentPage += 1
        self.calculatePages()
    }
    
    public func gotoNextPage() {
        self.currentPage += 1
        self.calculatePages()
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    public func gotoLastPage() {
        self.currentPage = self.pages
        self.calculatePages()
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    @IBAction func onLoadClicked(_ sender: NSButton) {
        self.countImages()
        self.calculatePages()
        self.logger.log("CALL ONLOAD")
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    fileprivate func countImages() {
        self.total = self.onCountTotal()
        let hiddenCount = self.onCountHidden()
        self.lblTotalItems.stringValue = "\(self.total) (\(hiddenCount) \(Words.library_tree_hidden)"
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
        self.lblShowsItems.stringValue = "\(start) - \(end)"
        self.onPaginationStateChanges(
            self.currentPage,
            self.pages
        )
        self.logger.log("divided pages \(self.pages)")
    }
    
}
