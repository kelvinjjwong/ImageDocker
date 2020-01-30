//
//  CollectionPaginationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/12.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class CollectionPaginationViewController: NSViewController {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var lblTotalItems: NSTextField!
    @IBOutlet weak var lblShowsItems: NSTextField!
    @IBOutlet weak var lstPageSize: NSPopUpButton!
    @IBOutlet weak var btnFirstPage: NSButton!
    @IBOutlet weak var btnPreviousPage: NSButton!
    @IBOutlet weak var btnNextPage: NSButton!
    
    fileprivate var lastRequest:CollectionViewLastRequest!
    fileprivate var total = 0
    fileprivate var pages = 0
    fileprivate var currentPage = 0
    fileprivate var pageSize = 0
    fileprivate var onLoad: ((_ pageSize:Int, _ pageNumber:Int) -> Void)!
    fileprivate var onCountTotal: (() -> Int)!
    fileprivate var onCountHidden: (() -> Int)!
    
    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "CollectionPaginationViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initView(_ lastRequest:CollectionViewLastRequest,
                  onCountTotal: @escaping (() -> Int),
                  onCountHidden: @escaping (() -> Int),
                  onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void) ) {
        self.lastRequest = lastRequest
        self.pageSize = lastRequest.pageSize
        self.currentPage = lastRequest.pageNumber
        self.onLoad = onLoad
        self.onCountTotal = onCountTotal
        self.onCountHidden = onCountHidden
        self.countImages()
        self.calculatePages()
        
    }
    
    
    // MARK: ACTIONS
    @IBAction func onFirstPageClicked(_ sender: NSButton) {
        self.currentPage = 1
        self.calculatePages()
    }
    
    @IBAction func onPreviousPageClicked(_ sender: NSButton) {
        self.currentPage -= 1
        self.calculatePages()
    }
    
    @IBAction func onNextPageClicked(_ sender: NSButton) {
        self.currentPage += 1
        self.calculatePages()
    }
    
    @IBAction func onLoadClicked(_ sender: NSButton) {
        self.countImages()
        self.calculatePages()
        print("CALL ONLOAD")
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    fileprivate func countImages() {
        self.total = self.onCountTotal()
        let hiddenCount = self.onCountHidden()
        self.lblTotalItems.stringValue = "\(self.total) (\(hiddenCount) hidden)"
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
        print("divided pages \(self.pages)")
    }
    
}
