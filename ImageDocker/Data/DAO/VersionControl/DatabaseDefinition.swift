//
//  DatabaseDefinition.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/22.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public enum DBTableAction {
    case create
    case alter
    case drop
    case sql
    case createSequence
    case dropSequence
}

public final class DatabaseTableDefinition {

    private let name: String
    private let action: DBTableAction
    private var columns:[DatabaseColumnDefinition] = []
    private var sql:String = ""

    init(name: String, action:DBTableAction) {
        self.name = name
        self.action = action
    }
    
    init(sql:String) {
        self.name = ""
        self.sql = sql
        self.action = .sql
    }
    
    init(sequence:String, action:DBTableAction) {
        self.name = sequence
        self.action = action
    }
    
    @discardableResult
    public func column(_ name: String, _ type: ColumnType? = nil) -> DatabaseColumnDefinition {
        let columnDefinition = DatabaseColumnDefinition(name: name, action: .create, type: type)
        columns.append(columnDefinition)
        return columnDefinition
    }
    
    @discardableResult
    public func add(_ column: String, _ type: ColumnType) -> DatabaseColumnDefinition {
        let columnDefinition = DatabaseColumnDefinition(name: column, action: .create, type: type)
        columns.append(columnDefinition)
        return columnDefinition
    }
    
    @discardableResult
    public func change(_ column: String) -> DatabaseColumnDefinition {
        let columnDefinition = DatabaseColumnDefinition(name: column, action: .alter)
        columns.append(columnDefinition)
        return columnDefinition
    }
    
    @discardableResult
    public func drop(_ column: String) -> DatabaseColumnDefinition {
        let columnDefinition = DatabaseColumnDefinition(name: column, action: .drop)
        columns.append(columnDefinition)
        return columnDefinition
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func isCreateSequence() -> Bool {
        return self.action == .createSequence
    }
    
    public func isDropSequence() -> Bool {
        return self.action == .dropSequence
    }
    
    public func isCreate() -> Bool {
        return self.action == .create
    }
    
    public func isAlter() -> Bool {
        return self.action == .alter
    }
    
    public func isDrop() -> Bool {
        return self.action == .drop
    }
    
    public func getSqlStatement() -> String {
        return self.sql
    }
    
    public func getColumns() -> [DatabaseColumnDefinition] {
        return self.columns
    }
    
    public func isPureSQL() -> Bool {
        return self.action == .sql
    }
    
}

public final class DatabaseColumnDefinition {
    
    private var _action:DBTableAction
    private var name:String
    private var type:ColumnType? = nil
    private var addUniqueConstraint:Bool = false
    private var dropUniqueConstraint:Bool = false
    private var _constraintName:String = ""
    private var _indexName:String = ""
    
    private var _primaryKey: Bool? = nil
    private var _index: Bool? = nil
    private var _notNull: Bool? = nil
    private var _defaultValue: String? = nil
    private var _defaultValueType: ColumnType? = nil
    
    init(name:String, action:DBTableAction, type: ColumnType? = nil,
         addUniqueConstraint:Bool = false,
         dropUniqueConstraint:Bool = false,
         constraintName:String = "",
         indexName:String = ""
    ) {
        self.name = name
        self._action = action
        self.type = type
        self.addUniqueConstraint = addUniqueConstraint
        self.dropUniqueConstraint = dropUniqueConstraint
        self._constraintName = constraintName
        self._indexName = indexName
    }
    
    @discardableResult
    public func primaryKey() -> Self {
        self._primaryKey = true
        return self
    }
    
    @discardableResult
    public func indexed(_ indexName:String = "") -> Self {
        self._index = true
        self._indexName = indexName
        return self
    }
    
    @discardableResult
    public func dropIndex(_ indexName:String = "") -> Self {
        self._index = false
        self._indexName = indexName
        return self
    }
    
    @discardableResult
    public func unique(_ constraintName:String = "") -> Self {
        self.addUniqueConstraint = true
        self._constraintName = constraintName
        return self
    }
    
    @discardableResult
    public func dropUnique(_ constraintName:String = "") -> Self {
        self.dropUniqueConstraint = true
        self._constraintName = constraintName
        return self
    }
    
    @discardableResult
    public func notNull() -> Self {
        self._notNull = true
        return self
    }
    
    @discardableResult
    public func null() -> Self {
        self._notNull = false
        return self
    }
    
    @discardableResult
    public func defaults(to value: String, _ type:ColumnType? = nil) -> Self {
        self._defaultValue = value
        self._defaultValueType = type
        return self
    }
    
    @discardableResult
    public func defaults(to value: Int) -> Self {
        self._defaultValue = String(value)
        self._defaultValueType = .integer
        return self
    }
    
    @discardableResult
    public func defaults(to value: Double) -> Self {
        self._defaultValue = String(value)
        self._defaultValueType = .double
        return self
    }
    
    @discardableResult
    public func defaults(to value: Bool) -> Self {
        self._defaultValue = value ? "t" : "f"
        self._defaultValueType = .boolean
        return self
    }
    
    @discardableResult
    public func autoIncrement(sequence: String) -> Self {
        self._defaultValueType = .integer
        self._defaultValue = "nextval('\(sequence)')"
        return self
    }
    
    public func action() -> DBTableAction {
        return self._action
    }
    
    public func getName() -> String {
        return self.name
    }
    
    public func getType() -> ColumnType? {
        return self.type
    }
    
    public func isPrimaryKey() -> Bool? {
        return self._primaryKey
    }
    
    public func isIndexed() -> Bool? {
        return self._index
    }
    
    public func isNotNull() -> Bool? {
        return self._notNull
    }
    
    public func getDefaultExpression() -> String? {
        return self._defaultValue
    }
    
    public func getDefaultValueType() -> ColumnType? {
        return self.type ?? self._defaultValueType
    }
    
    public func isAddUniqueConstraint() -> Bool {
        return self.addUniqueConstraint
    }
    
    public func isDropUniqueConstraint() -> Bool {
        return self.dropUniqueConstraint
    }
    
    public func constraintName() -> String {
        return self._constraintName
    }
    
    public func indexName() -> String {
        return self._indexName
    }
}
