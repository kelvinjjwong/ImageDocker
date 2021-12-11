//
//  ContainerDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/12.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ContainerDetailViewController: NSViewController {
    
    let logger = ConsoleLogger(category: "CONTAINER", subCategory: "DETAIL")
    
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
    
    @IBOutlet weak var btnFindParentFolder: NSButton!
    @IBOutlet weak var btnGoUp: NSButton!
    @IBOutlet weak var btnRestoreParentFolder: NSButton!
    @IBOutlet weak var btnPickParentFolder: NSButton!
    @IBOutlet weak var btnRefreshData: NSButton!
    
    @IBOutlet weak var lblNewPath: NSTextField!
    @IBOutlet weak var lblNewParentContainerName: NSTextField!
    
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
    
    func toggleNewPath(_ state:Bool){
        self.lblNewPath.stringValue = ""
        self.lblNewParentContainerName.stringValue = ""
        self.lblNewPath.isHidden = !state
        self.lblNewParentContainerName.isHidden = !state
        self.btnPickParentFolder.isHidden = true
        self.btnGoUp.isHidden = !state
        self.btnRestoreParentFolder.isHidden = !state
        self.btnRefreshData.isHidden = !state
    }
    
    func initView(_ container:ImageContainer, onLoad: @escaping ((_ pageSize:Int, _ pageNumber:Int) -> Void) ) {
        self.container = container
        self.onLoad = onLoad
        self.lblMessage.stringValue = ""
        self.lblPath.stringValue = container.path
        self.updateShowHideState()
        self.countImages()
        self.calculatePages()
        self.toggleNewPath(false)
        
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
            let _ = RepositoryDao.default.showContainer(path: container.path)
            container.hiddenByContainer = false
        }else{
            let _ = RepositoryDao.default.hideContainer(path: container.path)
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
        self.onLoad(self.pageSize, self.currentPage)
    }
    
    fileprivate func countImages() {
        self.total = ImageCountDao.default.countImages(repositoryRoot: container.path.withStash())
        let hiddenCount = ImageCountDao.default.countHiddenImages(repositoryRoot: container.path.withStash())
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
        self.logger.log("divided pages \(self.pages)")
    }
    
    @IBAction func onFindParentFolder(_ sender: NSButton) {
        if(self.lblNewPath.isHidden){
            self.toggleNewPath(true)
        }
        
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        self.lblNewPath.stringValue = newUrl.path
        self.findNewContainer(path: newUrl.path)
    }
    
    private func findNewContainer(path:String){
        if let newContainer = RepositoryDao.default.getContainer(path: path) {
            self.lblNewParentContainerName.stringValue = newContainer.name
            self.btnPickParentFolder.isHidden = false
        }else{
            self.lblNewParentContainerName.stringValue = "Cannot find matched container"
            self.btnPickParentFolder.isHidden = true
        }
    }
    
    @IBAction func onGoUpClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblNewPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        if newUrl.path != "/" {
            self.lblNewPath.stringValue = newUrl.path
            self.findNewContainer(path: newUrl.path)
        }else{
            self.lblNewParentContainerName.stringValue = "Should not use root folder"
        }
    }
    
    @IBAction func onRestoreParentClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        self.lblNewPath.stringValue = newUrl.path
        self.findNewContainer(path: newUrl.path)
    }
    
    @IBAction func onPickParentFolderClicked(_ sender: NSButton) {
        
        let buttonTitle = self.btnPickParentFolder.title
        self.btnPickParentFolder.title = "Saving parent folder..."
        self.btnPickParentFolder.isEnabled = false
        self.btnRefreshData.isEnabled = false
        
        let newPath = self.lblNewPath.stringValue
        let path = self.lblPath.stringValue
        
        DispatchQueue.global().async {
            if let parentContainer = RepositoryDao.default.getContainer(path: newPath){
                
                if let container = RepositoryDao.default.getContainer(path: path) {
                    
                    container.parentFolder = parentContainer.path
                    container.parentPath = URL(fileURLWithPath: container.path.replacingFirstOccurrence(of: parentContainer.path, with: "")).deletingLastPathComponent().path.withoutStash()
                        
                    let state = RepositoryDao.default.saveImageContainer(container: container)
                    if state == .OK {
                        let _ = RepositoryDao.default.updateParentContainerSubContainers(thisPath: container.path)
                        
                        DispatchQueue.main.async {
                            self.lblNewParentContainerName.stringValue = "Saved parent folder"
                            
                            self.btnPickParentFolder.title = buttonTitle
                            self.btnPickParentFolder.isEnabled = true
                            self.btnRefreshData.isEnabled = true
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblNewParentContainerName.stringValue = "ERROR: Cannot save parent folder"
                            
                            self.btnPickParentFolder.title = buttonTitle
                            self.btnPickParentFolder.isEnabled = true
                            self.btnRefreshData.isEnabled = true
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.lblNewParentContainerName.stringValue = "Cannot find selected folder in database"
                        
                        self.btnPickParentFolder.title = buttonTitle
                        self.btnPickParentFolder.isEnabled = true
                        self.btnRefreshData.isEnabled = true
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.lblNewParentContainerName.stringValue = "Cannot find selected parent folder in database"
                    
                    self.btnPickParentFolder.title = buttonTitle
                    self.btnPickParentFolder.isEnabled = true
                    self.btnRefreshData.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func onRefreshDataClicked(_ sender: NSButton) {
        let buttonTitle = self.btnRefreshData.title
        self.btnRefreshData.title = "Updating..."
        self.btnPickParentFolder.isEnabled = false
        self.btnRefreshData.isEnabled = false
        
        let path = self.lblPath.stringValue
        
        DispatchQueue.global().async {
            if let _ = RepositoryDao.default.getContainer(path: path) {
                let _ = RepositoryDao.default.updateParentContainerSubContainers(thisPath: path)
                let _ = RepositoryDao.default.updateImageContainerSubContainers(path: path)
            }
            
            DispatchQueue.main.async {
                self.btnRefreshData.title = buttonTitle
                self.btnPickParentFolder.isEnabled = true
                self.btnRefreshData.isEnabled = true
                
            }
        }
    }
    
    
}
