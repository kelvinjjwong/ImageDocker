//
//  HeaderView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//

import Cocoa

class HeaderView: NSView, NSCollectionViewElement {

  @IBOutlet weak var sectionTitle: NSTextField!
  @IBOutlet weak var imageCount: NSTextField!
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    NSColor(calibratedWhite: 0.1, alpha: 0.8).set()
    __NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
  }
}
