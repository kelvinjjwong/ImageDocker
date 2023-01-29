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
    
    @IBOutlet weak var boxPagination: NSBox!
    @IBOutlet weak var lblCaptionTotalRecords: NSTextField!
    @IBOutlet weak var lblCaptionShowRecords: NSTextField!
    @IBOutlet weak var lblCaptionPageSize: NSTextField!
    
    @IBOutlet weak var boxPath: NSBox!
    @IBOutlet weak var lblCaptionFolder: NSTextField!
    
    @IBOutlet weak var boxStat: NSBox!
    @IBOutlet weak var btnRevealInFinder: NSButton!
    @IBOutlet weak var btnLoadPage: NSButton!
    
    
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
        
        self.boxPagination.title = Words.library_tree_collection_view_pagination.word()
        self.lblCaptionFolder.stringValue = Words.library_tree_folder.word()
        self.lblCaptionPageSize.stringValue = Words.library_tree_pagination_items_per_page.word()
        self.lblCaptionShowRecords.stringValue = Words.library_tree_pagination_shows.word()
        self.lblCaptionTotalRecords.stringValue = Words.library_tree_pagination_total.word()
        self.btnFirstPage.title = Words.library_tree_pagination_first_page.word()
        self.btnPreviousPage.title = Words.library_tree_pagination_previous.word()
        self.btnNextPage.title = Words.library_tree_pagination_next.word()
        self.btnLoadPage.title = Words.library_tree_pagination_load.word()
        
        self.boxPath.title = Words.library_tree_path_and_relationship.word()
        self.boxStat.title = Words.library_tree_stat_and_state.word()
        self.chkHideByRepository.title = Words.library_tree_hidden_by_repository.word()
        self.chkHideByMyself.title = Words.library_tree_hidden_by_itself.word()
        self.btnFindParentFolder.title = Words.library_tree_find_another_parent_folder.word()
        self.btnRevealInFinder.title = Words.library_tree_reveal_in_finder.word()
        self.btnGoUp.title = Words.library_tree_go_up.word()
        self.btnRestoreParentFolder.title = Words.library_tree_restore.word()
        self.btnPickParentFolder.title = Words.library_tree_save_as_parent_folder.word()
        self.btnRefreshData.title = Words.library_tree_refresh_relationship_data.word()
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
            self.btnShowHide.title = Words.library_tree_show_me.word()
        }else{
            self.btnShowHide.title = Words.library_tree_hide_me.word()
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
        self.total = ImageCountDao.default.countImages(repositoryRoot: container.path.withLastStash())
        let hiddenCount = ImageCountDao.default.countHiddenImages(repositoryRoot: container.path.withLastStash())
        self.lblTotalItems.stringValue = "\(self.total) (\(hiddenCount) \(Words.library_tree_hidden.word())"
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
    
    /// deprecate
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
            self.lblNewParentContainerName.stringValue = Words.library_tree_cannot_find_matched_container.word()
            self.btnPickParentFolder.isHidden = true
        }
    }
    
    /// deprecate
    @IBAction func onGoUpClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblNewPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        if newUrl.path != "/" {
            self.lblNewPath.stringValue = newUrl.path
            self.findNewContainer(path: newUrl.path)
        }else{
            self.lblNewParentContainerName.stringValue = Words.library_tree_should_not_use_root_folder.word()
        }
    }
    
    /// deprecate
    @IBAction func onRestoreParentClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        self.lblNewPath.stringValue = newUrl.path
        self.findNewContainer(path: newUrl.path)
    }
    
    /// deprecate
    @IBAction func onPickParentFolderClicked(_ sender: NSButton) {
        
        let buttonTitle = self.btnPickParentFolder.title
        self.btnPickParentFolder.title = Words.library_tree_saving_parent_folder.word()
        self.btnPickParentFolder.isEnabled = false
        self.btnRefreshData.isEnabled = false
        
        let newPath = self.lblNewPath.stringValue
        let path = self.lblPath.stringValue
        
        DispatchQueue.global().async {
            if let parentContainer = RepositoryDao.default.getContainer(path: newPath){
                
                if let container = RepositoryDao.default.getContainer(path: path) {
                    
                    container.parentFolder = parentContainer.path
                    container.parentPath = URL(fileURLWithPath: container.path.replacingFirstOccurrence(of: parentContainer.path, with: "")).deletingLastPathComponent().path.removeLastStash()
                        
                    let state = RepositoryDao.default.saveImageContainer(container: container)
                    if state == .OK {
                        let _ = RepositoryDao.default.updateParentContainerSubContainers(thisPath: container.path)
                        
                        DispatchQueue.main.async {
                            self.lblNewParentContainerName.stringValue = Words.library_tree_saved_parent_folder.word()
                            
                            self.btnPickParentFolder.title = buttonTitle
                            self.btnPickParentFolder.isEnabled = true
                            self.btnRefreshData.isEnabled = true
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblNewParentContainerName.stringValue = Words.library_tree_cannot_save_parent_folder.word()
                            
                            self.btnPickParentFolder.title = buttonTitle
                            self.btnPickParentFolder.isEnabled = true
                            self.btnRefreshData.isEnabled = true
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.lblNewParentContainerName.stringValue = Words.library_tree_cannot_find_selected_folder_in_db.word()
                        
                        self.btnPickParentFolder.title = buttonTitle
                        self.btnPickParentFolder.isEnabled = true
                        self.btnRefreshData.isEnabled = true
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.lblNewParentContainerName.stringValue = Words.library_tree_cannot_find_selected_parent_folder_in_db.word()
                    
                    self.btnPickParentFolder.title = buttonTitle
                    self.btnPickParentFolder.isEnabled = true
                    self.btnRefreshData.isEnabled = true
                }
            }
        }
    }
    
    /// deprecate
    @IBAction func onRefreshDataClicked(_ sender: NSButton) {
        let buttonTitle = self.btnRefreshData.title
        self.btnRefreshData.title = Words.library_tree_updating.word()
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
