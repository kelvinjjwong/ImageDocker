//
//  ContainerDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/12.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ContainerDetailViewController: NSViewController {
    
    // MARK: PROPERTIES
    @IBOutlet weak var lblPath: NSTextField!
    @IBOutlet weak var chkHideByRepository: NSButton!
    @IBOutlet weak var chkHideByMyself: NSButton!
    @IBOutlet weak var btnShowHide: NSButton!
    @IBOutlet weak var lblTotalItems: NSTextField!
    @IBOutlet weak var lblShowsItems: NSTextField!
    @IBOutlet weak var lstPageSize: NSPopUpButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnFirstPage: NSButton!
    @IBOutlet weak var btnPreviousPage: NSButton!
    @IBOutlet weak var btnNextPage: NSButton!
    
    fileprivate var container:ImageContainer!
    fileprivate var total = 0
    fileprivate var pages = 0
    fileprivate var currentPage = 0
    fileprivate var pageSize = 0
    fileprivate var onLoad: ((_ pageSize:Int, _ pageNumber:Int) -> Void)!
    
    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: "ContainerDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initView(_ container:ImageContainer, onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void) ) {
        self.container = container
        self.onLoad = onLoad
        self.lblMessage.stringValue = ""
        self.lblPath.stringValue = container.path
        self.updateShowHideState()
        self.countImages()
        self.calculatePages()
        
    }
    
    fileprivate func updateShowHideState(){
        self.chkHideByRepository.state = container.hiddenByRepository ? .on : .off
        self.chkHideByMyself.state = container.hiddenByContainer ? .on : .off
        self.chkHideByRepository.isEnabled = false
        self.chkHideByMyself.isEnabled = false
        if container.hiddenByContainer {
            self.btnShowHide.title = "Show Me"
        }else{
            self.btnShowHide.title = "Hide Me"
        }
    }
    
    // MARK: ACTIONS
    @IBAction func onGotoClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.container.path)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onShowHideClicked(_ sender: NSButton) {
        if container.hiddenByContainer {
            ModelStore.default.showContainer(path: container.path)
            container.hiddenByContainer = false
        }else{
            ModelStore.default.hideContainer(path: container.path)
            container.hiddenByContainer = true
        }
        self.updateShowHideState()
    }
    
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
        self.total = ModelStore.default.countImages(repositoryRoot: container.path.withStash())
        let hiddenCount = ModelStore.default.countHiddenImages(repositoryRoot: container.path.withStash())
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
