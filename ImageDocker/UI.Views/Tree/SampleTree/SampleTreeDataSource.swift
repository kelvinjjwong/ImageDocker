//
//  SampleTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation


class SampleDataSource1: StaticTreeDataSource {
    
    override init() {
        super.init()
        var tree_data:[TreeCollection] = []
        for i in 1...3 {
            let tree = TreeCollection("root_\(i)")
            tree.addChild("leaf_1")
            tree.addChild("leaf_2")
            tree.addChild("leaf_3")
            tree.getChild("leaf_1")!.addChild("grand_1")
            tree.getChild("leaf_1")!.addChild("grand_2")
            tree.getChild("leaf_1")!.addChild("grand_3")
            tree.getChild("leaf_3")!.addChild("grand_a")
            tree.getChild("leaf_3")!.addChild("grand_b")
            tree.getChild("leaf_3")!.addChild("grand_c")
            tree.getChild("leaf_3")!.addChild("grand_d_very_long_long_long_long_text_to_see_next_line")
            tree_data.append(tree)
        }
        for data in tree_data {
            flattable_all.append(data)
//            self.logger.log(.trace, "flatted: \(data.path)")
            flattable_all.append(contentsOf: data.getUnlimitedDepthChildren())
        }
//        self.logger.log(.trace, "total \(flattable_all.count) node")
        self.filter(keyword: "")
        self.convertFlatToTree()
        
    }
}
