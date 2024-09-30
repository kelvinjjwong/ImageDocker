//
//  SearchableTableViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/30.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa

protocol SearchableTableRefreshDelegate {
    func refreshRecords()
    func selectRecord(record:[String:String])
}

public class SearchableTableViewController: NSViewController {
    
    var records:[[String:String]] = []
    
    var txtSearch:NSTextField!
    var tableView:NSTableView!
    var refreshDelegate:SearchableTableRefreshDelegate?
    
    var onSelectRow:(([String:String]) -> Void)!
    var onReloadRecords:((String) -> [[String:String]])!
    
    public init(table:NSTableView, search:NSTextField,
                onReloadRecords:@escaping ((String) -> [[String:String]]),
                onSelectRow:@escaping (([String:String]) -> Void)){
        super.init(nibName: nil, bundle: nil)
        self.tableView = table
        self.txtSearch = search
        self.onReloadRecords = onReloadRecords
        self.onSelectRow = onSelectRow
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.refreshRecords()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && records.count > 0 && lastSelectedRow! < records.count {
                let record = records[lastSelectedRow!]
                self.onSelectRow?(record)
                self.refreshDelegate?.selectRecord(record: records[lastSelectedRow!])
            }
        }
    }
    
    public func refreshRecords() {
        let keyword = self.txtSearch.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.records = self.onReloadRecords(keyword)
        self.tableView.reloadData()
    }
}

extension SearchableTableViewController: NSTableViewDelegate {
    
    // return view for requested column.
    public func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.records.count - 1) {
            return nil
        }
        let record = self.records[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            for key in record.keys.sorted() {
                if id == NSUserInterfaceItemIdentifier(key) {
                    value = record[key] ?? ""
                }
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
//                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedRow = nil
//                colView.textField?.textColor = nil
            }
            return colView
        }
        return nil
    }
    
    public func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        rowView.backgroundColor = row % 2 == 1
            ? Colors.MidGray
            : Colors.DarkGray
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

// MARK: TableView data source functions

extension SearchableTableViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.records.count
    }
    
    // table sorting by column contents
    public func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
