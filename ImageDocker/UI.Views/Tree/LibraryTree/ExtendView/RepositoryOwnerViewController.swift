//
//  RepositoryOwnerViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2025/11/9.
//  Copyright © 2025 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class RepositoryOwnerViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "TreeExpand", subCategory: "RepositoryOwnerViewController")
    
    @IBOutlet weak var btnScanDuplicate: NSButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var indProgress: NSProgressIndicator!
    
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var btnClose: NSButton!
    
    private var owner = ""
    fileprivate var onClose: (() -> Void)?
    
    private var accumulator:Accumulator? = nil
    private var working = false
    private var forceStop = false
    private var workingTaskId = ""
    
    private var idleSeconds = 180
    private var closingCountdown = 180
    
    
    var closingDetectTimer:Timer?
    

    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: "RepositoryOwnerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func initView(owner:String, onClose: (() -> Void)? = nil) {
        self.owner = owner
        self.onClose = onClose
        
        self.indProgress.doubleValue = 0
        self.indProgress.isHidden = true
        self.lblMessage.stringValue = ""
        
        self.working = false
        self.closingCountdown = self.idleSeconds
        self.workingTaskId = ""
        
        self.btnStop.isHidden = true
        
        self.closingDetectTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            DispatchQueue.global().async {
                print("closingDetectTimer is running")
                
                if self.closingCountdown == 0 {
                    self.closingDetectTimer?.invalidate()
                    DispatchQueue.main.async {
                        self.onClose?()
                    }
                    return
                }
                
                if self.working == false {
                    DispatchQueue.main.async {
                        self.closingCountdown -= 1
                        self.btnClose.title = "即将关闭 (\(self.closingCountdown))"
                    }
                }
            }
        })
    }
    
    @IBAction func onCloseClicked(_ sender: NSButton) {
        self.closingDetectTimer?.invalidate()
        if self.onClose != nil {
            self.onClose!()
        }
    }
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        self.forceStop = true
        if self.workingTaskId != "" {
            TaskletManager.default.stopTask(id: self.workingTaskId)
        }
    }
    
    
    
    // fill image.id,
    // fill image.fileExt,
    // fill image.originalMD5,
    // find / tag / show / hide duplicates
    @IBAction func onScanDuplicateClicked(_ sender: NSButton) {
        print("fill image.id, fill image.originalMD5, find duplicates")
        
        self.working = true
        self.btnClose.title = "关闭"
        self.closingCountdown = self.idleSeconds
        self.btnScanDuplicate.isEnabled = false
        self.btnClose.isEnabled = false
        self.btnStop.isHidden = false
        self.workingTaskId = ""
        
        let _ = TaskletManager.default.createAndStartTask(type: "Scan Duplicates", name: "\(self.owner)"
                                                          , exec: { task in
            
            self.workingTaskId = task.id
            
            TaskletManager.default.updateProgress(id: task.id, message: "Scanning duplicates ...", increase: false)
            
            DispatchQueue.global().async {
                
                // ....
                
                if TaskletManager.default.isTaskStopped(id: task.id) == true {
                    DispatchQueue.main.async {
                        self.working = false
                        self.btnClose.title = "即将关闭"
                        self.closingCountdown = self.idleSeconds
                        self.btnScanDuplicate.isEnabled = true
                        self.btnClose.isEnabled = true
                        self.btnStop.isHidden = true
                        self.workingTaskId = ""
                        self.lblMessage.stringValue = "User stopped task: scan duplicates."
                    }
                    return
                }
                
                // task 1
                TaskletManager.default.resetProgress(id: task.id)
                TaskletManager.default.updateProgress(id: task.id, message: "正在扫描缺失标识的影像 ...", increase: false)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "正在扫描缺失标识的影像 ..."
                }
                let recordsWithNullId = ImageRecordDao.default.getImagesWithNullId(owner: self.owner)
                
                if recordsWithNullId.count > 0 {
                    
                    let total = recordsWithNullId.count
                    
                    TaskletManager.default.setTotal(id: task.id, total: total)
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    var z = 0
                    // for loop ...
                    for recordWithNullId in recordsWithNullId {
                        
                        guard (!self.forceStop) && (TaskletManager.default.isTaskStopped(id: task.id) == false) else {
                            self.logger.log(.info, "[ScanDuplicate] for-loop terminated as user clicked stop button.")
                            DispatchQueue.main.async {
                                self.forceStop = true
                                self.accumulator?.forceComplete()
                            }
                            break
                        }
                        
                        z += 1
                        
                        let repositoryId = recordWithNullId.0
                        let subPath = recordWithNullId.1
                        
                        let (status, msg) = ImageRecordDao.default.generateImageIdByRepositoryIdAndSubPath(repositoryId: repositoryId, subPath: subPath)
                        if status != .OK {
                            self.logger.log(.error, msg)
                        }
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("已生成影像标识: \(subPath)")
                        }
                        TaskletManager.default.updateProgress(id: task.id, message: "已生成影像标识 (\(z)/\(task.total)) \(subPath)", increase: true)
                        
                    } // end of for loop ...
                    
                } // end of task 1
                
                // task 2
                TaskletManager.default.resetProgress(id: task.id)
                TaskletManager.default.updateProgress(id: task.id, message: "正在扫描缺失文件类型的影像 ...", increase: false)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "正在扫描缺失文件类型的影像 ..."
                }
                let recordsWithNullFileExt = ImageRecordDao.default.getImagesWithNullFileExt(owner: self.owner)
                
                if recordsWithNullFileExt.count > 0 {
                    
                    let total = recordsWithNullFileExt.count
                    
                    TaskletManager.default.setTotal(id: task.id, total: total)
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    var z = 0
                    // for loop ...
                    for recordWithNullFileExt in recordsWithNullFileExt {
                        
                        guard (!self.forceStop) && (TaskletManager.default.isTaskStopped(id: task.id) == false) else {
                            self.logger.log(.info, "[ScanDuplicate] for-loop terminated as user clicked stop button.")
                            DispatchQueue.main.async {
                                self.forceStop = true
                                self.accumulator?.forceComplete()
                            }
                            break
                        }
                        
                        z += 1
                        
                        let imageId = recordWithNullFileExt.0
                        let subPath = recordWithNullFileExt.1
                        
                        let fileExt:String = (subPath.split(separator: Character(".")).last?.lowercased()) ?? ""
                        
                        let _ = ImageRecordDao.default.updateImageFileExt(id: imageId, fileExt: fileExt)
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("已补充影像文件类型: \(subPath)")
                        }
                        TaskletManager.default.updateProgress(id: task.id, message: "已补充影像文件类型 (\(z)/\(task.total)) \(subPath)", increase: true)
                        
                    } // end of for loop ...
                    
                } // end of task 2
                
                // task 3
                TaskletManager.default.resetProgress(id: task.id)
                TaskletManager.default.updateProgress(id: task.id, message: "正在扫描缺失内容校验标记的影像 ...", increase: false)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "正在扫描缺失内容校验标记的影像 ..."
                }
                let recordsWithNullOriginalMD5 = ImageRecordDao.default.getImagesWithNullOriginalMD5(owner: self.owner)
                
                if recordsWithNullOriginalMD5.count > 0 {
                    
                    let total = recordsWithNullOriginalMD5.count
                    
                    TaskletManager.default.setTotal(id: task.id, total: total)
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    var z = 0
                    // for loop ...
                    for recordWithNullOriginalMD5 in recordsWithNullOriginalMD5 {
                        
                        guard (!self.forceStop) && (TaskletManager.default.isTaskStopped(id: task.id) == false) else {
                            self.logger.log(.info, "[ScanDuplicate] for-loop terminated as user clicked stop button.")
                            DispatchQueue.main.async {
                                self.forceStop = true
                                self.accumulator?.forceComplete()
                            }
                            break
                        }
                        
                        z += 1
                        
                        let imageId = recordWithNullOriginalMD5.0
                        let repositoryId = recordWithNullOriginalMD5.1
                        let repositoryVolume = recordWithNullOriginalMD5.2
                        let repositoryPath = recordWithNullOriginalMD5.3
                        let storageVolume = recordWithNullOriginalMD5.4
                        let storagePath = recordWithNullOriginalMD5.5
                        let subPath = recordWithNullOriginalMD5.6
                        
                        let repositoryFilePath = URL(fileURLWithPath: "\(repositoryVolume)\(repositoryPath)").appendingPathComponent(subPath)
                        let storageFilePath = URL(fileURLWithPath: "\(storageVolume)\(storagePath)").appendingPathComponent(subPath)
                        
                        var md5 = ""
                        if FileManager.default.fileExists(atPath: storageFilePath.path) {
                            md5 = ComputerFileManager.default.md5(pathOfFile: storageFilePath.path)
                        }else if FileManager.default.fileExists(atPath: repositoryFilePath.path) {
                            md5 = ComputerFileManager.default.md5(pathOfFile: repositoryFilePath.path)
                        }
                        
                        if md5 != "" {
                            let _ = ImageRecordDao.default.updateImageOrginalMD5(id: imageId, md5: md5)
                        }
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("已补充影像内容校验标记: \(subPath)")
                        }
                        TaskletManager.default.updateProgress(id: task.id, message: "已补充影像内容校验标记 (\(z)/\(task.total)) \(subPath)", increase: true)
                        
                    } // end of for loop ...
                    
                } // end of task 3
                
                
                // task 4
                TaskletManager.default.resetProgress(id: task.id)
                TaskletManager.default.updateProgress(id: task.id, message: "正在扫描内容校验重复的影像 ...", increase: false)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "正在扫描内容校验重复的影像 ..."
                }
                let duplicateOriginalMD5s = ImageRecordDao.default.getImageOriginalMD5HavingDuplicated(owner: self.owner)
                
                if duplicateOriginalMD5s.count > 0 {
                    
                    let total = duplicateOriginalMD5s.count
                    
                    TaskletManager.default.setTotal(id: task.id, total: total)
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    var z = 0
                    // for loop ...
                    for originalMD5 in duplicateOriginalMD5s {
                        
                        guard (!self.forceStop) && (TaskletManager.default.isTaskStopped(id: task.id) == false) else {
                            self.logger.log(.info, "[ScanDuplicate] for-loop terminated as user clicked stop button.")
                            DispatchQueue.main.async {
                                self.forceStop = true
                                self.accumulator?.forceComplete()
                            }
                            break
                        }
                        
                        z += 1
                        
                        // grouping
                        var images = ImageRecordDao.default.getImageIds(originalMD5: originalMD5, checkDuplicatesKey: true)
                        if images.count > 0 {
                            images = ImageRecordDao.default.getImageIds(originalMD5: originalMD5, checkDuplicatesKey: false)
                            
                            var firstImageId = ""
                            var imageIdNotHidden = ""
                            var existingDuplicatesKey = ""
                            var hiddenCount = 0
                            for image in images {
                                let imageId = image.0
                                let hidden = image.1
                                let duplicatesKey = image.2
                                
                                if firstImageId == "" {
                                    firstImageId = imageId
                                }
                                
                                if !hidden {
                                    imageIdNotHidden = imageId
                                }else{
                                    hiddenCount += 1
                                }
                                
                                if duplicatesKey != "" {
                                    existingDuplicatesKey = duplicatesKey
                                }
                            }
                            if imageIdNotHidden == "" {
                                imageIdNotHidden = firstImageId
                            }
                            
                            if existingDuplicatesKey == "" {
                                existingDuplicatesKey = "MD5_\(originalMD5)"
                            }
                            
                            // proceed
                            if hiddenCount == images.count {
                                // hide all
                                for image in images {
                                    let imageId = image.0
                                    let hidden = image.1
                                    let duplicatesKey = image.2
                                    
                                    // update hide and duplicatesKey
                                    let _ = ImageRecordDao.default.hideImageWithDuplicateKey(imageId: imageId, duplicatesKey: existingDuplicatesKey)
                                }
                            }else{
                                // update show firstImageId and duplicatesKey
                                let _ = ImageRecordDao.default.showImageWithDuplicateKey(imageId: firstImageId, duplicatesKey: existingDuplicatesKey)
                                
                                for image in images {
                                    let imageId = image.0
                                    let hidden = image.1
                                    let duplicatesKey = image.2
                                    
                                    if imageId != firstImageId {
                                        // update hide and duplicatesKey
                                        let _ = ImageRecordDao.default.hideImageWithDuplicateKey(imageId: imageId, duplicatesKey: existingDuplicatesKey)
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("已标记重复的影像内容")
                        }
                        TaskletManager.default.updateProgress(id: task.id, message: "已标记重复的影像内容 (\(z)/\(task.total))", increase: true)
                        
                    } // end of for loop ...
                    
                } // end of task 4
                
                DispatchQueue.main.async {
                    self.working = false
                    self.btnClose.title = "即将关闭"
                    self.closingCountdown = self.idleSeconds
                    self.btnScanDuplicate.isEnabled = true
                    self.btnClose.isEnabled = true
                    self.btnStop.isHidden = true
                    self.workingTaskId = ""
                    if(self.forceStop) {
                        self.lblMessage.stringValue = "用户已中止扫描和标记."
                    }else{
                        self.lblMessage.stringValue = "已标记完成."
                    }
                    self.forceStop = false
                }
                
            } // end of DispatchQueue.global.async
        }, stop: {task in
            
        })
                
                
    }
    
    
}
