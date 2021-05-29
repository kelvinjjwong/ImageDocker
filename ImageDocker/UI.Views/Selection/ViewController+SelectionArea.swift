//
//  ViewController+Main+SelectionArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//


import Cocoa

extension ViewController {
    
    func configureSelectionView() {
        self.selectionViewController = storyboard?.instantiateController(withIdentifier: "SelectionViewController") as! SelectionViewController
        self.addChild(self.selectionViewController)
        self.bottomView.addSubview(self.selectionViewController.view)
        self.selectionViewController.initView()
    }
}

