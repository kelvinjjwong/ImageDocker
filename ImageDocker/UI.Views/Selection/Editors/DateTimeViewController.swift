//
//  DateTimeViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/9/16.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class DateTimeViewController: NSViewController {
    
    
    var images:[ImageTimestamp] = []
    let tableDateFormatter = DateFormatter()
    let tableDateTimeFormatter = DateFormatter()
    
    
    
    var lastSelectedRow:Int? {
        didSet {
            if let date = self.images[lastSelectedRow ?? 0].valueDate {
                self.calendarView.date = date
                self.calendarView.selectedDate = date
                self.calendarView.originDate = self.images[lastSelectedRow ?? 0].photoTakenDate!
            }
        }
    }
    
    // MARK: Controls
    
    @IBOutlet weak var btnClose: NSButton!
    
    // Calendar
    
    @IBOutlet weak var calendarViewContainer: NSView!
    var calendarView:LunarCalendarView!
    var calendarDateFormatter:DateFormatter!
    
    // Table
    @IBOutlet weak var table: NSTableView!
    
    
    // Value Date
    @IBOutlet weak var txtReferenceDate: NSTextField!
    @IBOutlet weak var txtReferenceTime: NSTextField!
    
    // Selected Date
    @IBOutlet weak var chkSelectedDate: NSButton!
    @IBOutlet weak var txtSelectedYear: NSTextField!
    @IBOutlet weak var stpSelectedYear: NSStepper!
    @IBOutlet weak var txtSelectedMonth: NSTextField!
    @IBOutlet weak var stpSelectedMonth: NSStepper!
    @IBOutlet weak var txtSelectedDay: NSTextField!
    @IBOutlet weak var stpSelectedDay: NSStepper!
    @IBOutlet weak var chkSelectedTime: NSButton!
    @IBOutlet weak var txtSelectedHour: NSTextField!
    @IBOutlet weak var stpSelectedHour: NSStepper!
    @IBOutlet weak var txtSelectedMinute: NSTextField!
    @IBOutlet weak var stpSelectedMinute: NSStepper!
    @IBOutlet weak var txtSelectedSecond: NSTextField!
    @IBOutlet weak var stpSelectedSecond: NSStepper!
    
    // Adjust Date
    
    @IBOutlet weak var btnPlusMinusDate: NSButton!
    @IBOutlet weak var chkAdjustYear: NSButton!
    @IBOutlet weak var txtAdjustYear: NSTextField!
    @IBOutlet weak var stpAdjustYear: NSStepper!
    @IBOutlet weak var chkAdjustMonth: NSButton!
    @IBOutlet weak var txtAdjustMonth: NSTextField!
    @IBOutlet weak var stpAdjustMonth: NSStepper!
    @IBOutlet weak var chkAdjustDay: NSButton!
    @IBOutlet weak var txtAdjustDay: NSTextField!
    @IBOutlet weak var stpAdjustDay: NSStepper!
    @IBOutlet weak var btnPlusMinusTime: NSButton!
    @IBOutlet weak var chkAdjustHour: NSButton!
    @IBOutlet weak var txtAdjustHour: NSTextField!
    @IBOutlet weak var stpAdjustHour: NSStepper!
    @IBOutlet weak var chkAdjustMinute: NSButton!
    @IBOutlet weak var txtAdjustMinute: NSTextField!
    @IBOutlet weak var stpAdjustMinute: NSStepper!
    @IBOutlet weak var chkAdjustSecond: NSButton!
    @IBOutlet weak var txtAdjustSecond: NSTextField!
    @IBOutlet weak var stpAdjustSecond: NSStepper!
    
    // Apply to
    @IBOutlet weak var chkEXIFCreateDate: NSButton!
    @IBOutlet weak var chkEXIFModifyDate: NSButton!
    @IBOutlet weak var chkEXIFDateTimeOriginal: NSButton!
    @IBOutlet weak var chkFileCreateDate: NSButton!
    @IBOutlet weak var chkPhotoTakenDate: NSButton!
    
    
    @IBOutlet weak var chkEarliestDate: NSButton!
    
    // Progress
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblMessage: NSTextField!
    
    // OK button
    @IBOutlet weak var btnOK: NSButton!
    
    
    // MARK: - INIT
    
    init(){
        super.init(nibName: "DateTimeViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func toggleCalendarAdjustment(_ enable:Bool) {
        self.chkSelectedDate.isEnabled = enable
        self.txtSelectedYear.isEnabled = enable
        self.stpSelectedYear.isEnabled = enable
        self.txtSelectedMonth.isEnabled = enable
        self.stpSelectedMonth.isEnabled = enable
        self.txtSelectedDay.isEnabled = enable
        self.stpSelectedDay.isEnabled = enable
        self.chkSelectedTime.isEnabled = enable
        self.txtSelectedHour.isEnabled = enable
        self.stpSelectedHour.isEnabled = enable
        self.txtSelectedMinute.isEnabled = enable
        self.stpSelectedMinute.isEnabled = enable
        self.txtSelectedSecond.isEnabled = enable
        self.stpSelectedSecond.isEnabled = enable
        
        self.btnPlusMinusDate.isEnabled = enable
        self.chkAdjustYear.isEnabled = enable
        self.txtAdjustYear.isEnabled = enable
        self.stpAdjustYear.isEnabled = enable
        self.chkAdjustMonth.isEnabled = enable
        self.txtAdjustMonth.isEnabled = enable
        self.stpAdjustMonth.isEnabled = enable
        self.chkAdjustDay.isEnabled = enable
        self.txtAdjustDay.isEnabled = enable
        self.stpAdjustDay.isEnabled = enable
        self.btnPlusMinusTime.isEnabled = enable
        self.chkAdjustHour.isEnabled = enable
        self.txtAdjustHour.isEnabled = enable
        self.stpAdjustHour.isEnabled = enable
        self.chkAdjustMinute.isEnabled = enable
        self.txtAdjustMinute.isEnabled = enable
        self.stpAdjustMinute.isEnabled = enable
        self.chkAdjustSecond.isEnabled = enable
        self.txtAdjustSecond.isEnabled = enable
        self.stpAdjustSecond.isEnabled = enable

    }
    
    private func addMonth(_ date:Date, adjust:Int) -> Date {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        
        var merged = DateComponents()
        merged.year = year
        merged.month = month + adjust
        merged.day = day
        merged.hour = hour
        merged.minute = minute
        merged.second = second
        
        var newday = date
        if let result = Calendar.current.date(from: merged) {
            newday = result
        }else{
            newday = date
        }
        return newday
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableDateFormatter.dateFormat = "yyyy-MM-dd"
        tableDateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.calendarDateFormatter = DateFormatter()
        self.calendarDateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.calendarView = LunarCalendarView()
        self.calendarView.delegate = self
        let now = Date()
//        let today = self.addMonth(now, adjust: 1)
        
        self.calendarView.date = now
        self.calendarView.selectedDate = now;
        
        self.calendarViewContainer.addSubview(self.calendarView.view)
        //self.calendarView.view.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        
        self.table.dataSource = self
        self.table.delegate = self
        
        self.chkSelectedDate.action = #selector(DateTimeViewController.onDateComponentsChecks(sender:))
        self.chkAdjustYear.action = #selector(DateTimeViewController.onDateComponentsChecks(sender:))
        self.chkAdjustMonth.action = #selector(DateTimeViewController.onDateComponentsChecks(sender:))
        self.chkAdjustDay.action = #selector(DateTimeViewController.onDateComponentsChecks(sender:))
        self.chkSelectedTime.action = #selector(DateTimeViewController.onTimeComponentsChecks(sender:))
        self.chkAdjustHour.action = #selector(DateTimeViewController.onTimeComponentsChecks(sender:))
        self.chkAdjustMinute.action = #selector(DateTimeViewController.onTimeComponentsChecks(sender:))
        self.chkAdjustSecond.action = #selector(DateTimeViewController.onTimeComponentsChecks(sender:))
        
        self.reinitNumbers()
        
    }
    
    fileprivate var onBeforeChanges: (() -> Void)? = nil
    fileprivate var onCompleted: (() -> Void)?
    fileprivate var onClose: (() -> Void)?
    
    func loadFrom(images:[ImageFile], onBeforeChanges: (() -> Void)? = nil, onApplyChanges: (() -> Void)? = nil, onClose: (() -> Void)? = nil ){
        self.onBeforeChanges = onBeforeChanges
        self.onCompleted = onApplyChanges
        self.onClose = onClose
        self.images = []
        for entry in images {
            if let image = entry.imageData {
                self.images.append(ImageTimestamp(image))
            }
        }
        self.table.reloadData()
        
        self.lblMessage.stringValue = ""
        
        self.chkEarliestDate.state = .on
        self.toggleCalendarAdjustment(false)
        self.applyToTable(applyCalendar: false)
    }
    
    private func reinitNumbers() {
        self.txtAdjustYear.integerValue = 0
        self.txtAdjustMonth.integerValue = 0
        self.txtAdjustDay.integerValue = 0
        self.txtAdjustHour.integerValue = 0
        self.txtAdjustMinute.integerValue = 0
        self.txtAdjustSecond.integerValue = 0
    }
    
    // MARK: - DATE TIME CASCADE
    
    private func increaseNumberField(this:NSTextField, thisStepper:NSStepper, next:NSTextField, addNext:Selector, start:Int, end:Int){
        let old = this.integerValue
        if old == end {
            this.integerValue = start
            thisStepper.integerValue = start
            
            perform(addNext)
        }else{
            this.integerValue += 1
        }
    }
    
    private func decreaseNumberField(this:NSTextField, thisStepper:NSStepper, next:NSTextField, minusNext:Selector, start:Int, end:Int){
        let old = this.integerValue
        if old == start {
            this.integerValue = end
            thisStepper.integerValue = end
            
            perform(minusNext)
        }else{
            this.integerValue -= 1
        }
    }
    
    // MARK: SELECTED DATE
    
    @objc private func increaseSelectedYear() {
        self.txtSelectedYear.integerValue += 1
    }
    
    @objc private func decreaseSelectedYear() {
        self.txtSelectedYear.integerValue -= 1
        
        if self.txtSelectedYear.integerValue < 1970 {
            self.txtSelectedYear.integerValue = 1970
        }
    }
    
    @IBAction func onStepperSelectedYearClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtSelectedYear.integerValue
        if newValue > oldValue {
            self.increaseSelectedYear()
        }else{
            self.decreaseSelectedYear()
        }
        
        self.chkSelectedDate.state = .on
        self.generateDate()
    }
    
    @objc private func increaseSelectedMonth() {
        self.increaseNumberField(this: self.txtSelectedMonth, thisStepper: self.stpSelectedMonth, next: self.txtSelectedYear,  addNext:#selector(increaseSelectedYear), start: 1, end: 12)
    }
    
    @objc private func decreaseSelectedMonth() {
        self.decreaseNumberField(this: self.txtSelectedMonth, thisStepper: self.stpSelectedMonth, next: self.txtSelectedYear,  minusNext:#selector(decreaseSelectedYear), start: 1, end: 12)
    }
    
    @IBAction func onStepperSelectedMonthClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtSelectedMonth.integerValue
        if newValue > oldValue {
            self.increaseSelectedMonth()
        }else{
            self.decreaseSelectedMonth()
        }
        
        self.chkSelectedDate.state = .on
        self.generateDate()
    }
    
    @objc private func increaseSelectedDay() {
        let year = self.txtSelectedYear.integerValue
        let month = self.txtSelectedMonth.integerValue
        let lastDay = self.lastDayOfMonth(year: year, month: month)
        self.increaseNumberField(this: self.txtSelectedDay, thisStepper: self.stpSelectedDay, next: self.txtSelectedMonth,  addNext:#selector(increaseSelectedMonth), start: 1, end: lastDay)
    }
    
    @objc private func decreaseSelectedDay() {
        let year = self.txtSelectedYear.integerValue
        let month = self.txtSelectedMonth.integerValue
        let lastDay = self.lastDayOfMonth(year: year, month: month-1)
        self.decreaseNumberField(this: self.txtSelectedDay, thisStepper: self.stpSelectedDay, next: self.txtSelectedMonth,  minusNext:#selector(decreaseSelectedMonth), start: 1, end: lastDay)
    }
    
    @IBAction func onStepperSelectedDayClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtSelectedDay.integerValue
        if newValue > oldValue {
            self.increaseSelectedDay()
        }else{
            self.decreaseSelectedDay()
        }
        
        self.chkSelectedDate.state = .on
        self.generateDate()
    }
    
    // MARK: SELECTED TIME
    
    @objc private func increaseSelectedHour() {
        self.increaseNumberField(this: self.txtSelectedHour, thisStepper: self.stpSelectedHour, next: self.txtSelectedDay,  addNext:#selector(increaseSelectedDay), start: 0, end: 23)
    }
    
    @objc private func decreaseSelectedHour() {
        self.decreaseNumberField(this: self.txtSelectedHour, thisStepper: self.stpSelectedHour, next: self.txtSelectedDay,  minusNext:#selector(decreaseSelectedDay), start: 0, end: 23)
    }
    
    @IBAction func onStepperSelectedHourClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtSelectedHour.integerValue
        if newValue > oldValue {
            self.increaseSelectedHour()
        }else{
            self.decreaseSelectedHour()
        }
        
        self.chkSelectedTime.state = .on
        self.generateTime()
    }
    
    @objc private func increaseSelectedMinute() {
        self.increaseNumberField(this: self.txtSelectedMinute, thisStepper: self.stpSelectedMinute, next: self.txtSelectedHour,  addNext:#selector(increaseSelectedHour), start: 0, end: 59)
    }
    
    @objc private func decreaseSelectedMinute() {
        self.decreaseNumberField(this: self.txtSelectedMinute, thisStepper: self.stpSelectedMinute, next: self.txtSelectedHour,  minusNext:#selector(decreaseSelectedHour), start: 0, end: 59)
    }
    
    @IBAction func onStepperSelectedMinuteClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtSelectedMinute.integerValue
        if newValue > oldValue {
            self.increaseSelectedMinute()
        }else{
            self.decreaseSelectedMinute()
        }
        
        self.chkSelectedTime.state = .on
        self.generateTime()
    }
    
    @objc private func increaseSelectedSecond() {
        self.increaseNumberField(this: self.txtSelectedSecond, thisStepper: self.stpSelectedSecond, next: self.txtSelectedMinute,  addNext:#selector(increaseSelectedMinute), start: 0, end: 59)
    }
    
    @IBAction func onStepperSelectedSecondClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtSelectedSecond.integerValue
        if newValue > oldValue {
            self.increaseSelectedSecond()
        }else{
            self.txtSelectedSecond.integerValue = newValue
        }
        
        self.chkSelectedTime.state = .on
        self.generateTime()
    }
    
    // MARK: ADJUST DATE
    
    @IBAction func onPlusMinusAdjustDateClicked(_ sender: NSButton) {
        if self.btnPlusMinusDate.image == NSImage(named: NSImage.addTemplateName) {
            self.btnPlusMinusDate.image = NSImage(named: NSImage.removeTemplateName)
        }else if self.btnPlusMinusDate.image == NSImage(named: NSImage.removeTemplateName) {
            self.btnPlusMinusDate.image = NSImage(named: NSImage.addTemplateName)
        }
        
        self.generateDate()
    }
    
    @IBAction func onStepperAdjustYearClicked(_ sender: NSStepper) {
        let value = sender.integerValue
        self.txtAdjustYear.integerValue = value
        
        self.chkAdjustYear.state = .on
        self.generateDate()
    }
    
    @objc private func increaseAdjustYear() {
        self.txtAdjustYear.integerValue += 1
    }
    
    @objc private func decreaseAdjustYear() {
        self.txtAdjustYear.integerValue -= 1
        
        if self.txtAdjustYear.integerValue < 0 {
            self.txtAdjustYear.integerValue = 0
        }
    }
    
    @objc private func increaseAdjustMonth() {
        self.increaseNumberField(this: self.txtAdjustMonth, thisStepper: self.stpAdjustMonth, next: self.txtAdjustYear,  addNext:#selector(increaseAdjustYear), start: 1, end: 12)
    }
    
    @objc private func decreaseAdjustMonth() {
        self.decreaseNumberField(this: self.txtAdjustMonth, thisStepper: self.stpAdjustMonth, next: self.txtAdjustYear,  minusNext:#selector(decreaseAdjustYear), start: 1, end: 12)
    }
    
    @IBAction func onStepperAdjustMonthClicked(_ sender: NSStepper) {
        print("clicked month stepper")
        let newValue = sender.integerValue
        let oldValue = self.txtAdjustMonth.integerValue
        if newValue > oldValue {
            self.increaseAdjustMonth()
        }else{
            self.decreaseAdjustMonth()
        }
        
        self.chkAdjustMonth.state = .on
        self.generateDate()
    }
    
    private func lastDayOfMonth(year:Int, month:Int) -> Int {
        var _month = month
        var _year = year
        if month > 12 {
            _month = 1
            _year += 1
        }
        if month < 1 {
            _month = 12
            _year -= 1
        }
        if _month == 1 || _month == 3 || _month == 5 || _month == 7 || _month == 8 || _month == 10 || _month == 12 {
            return 31
        }else if _month == 2{
            if _year % 4 == 0 {
                return 29
            }else{
                return 28
            }
        }else{
            return 30
        }
    }
    
    @objc private func increaseAdjustDay() {
        self.increaseNumberField(this: self.txtAdjustDay, thisStepper: self.stpAdjustDay, next: self.txtAdjustMonth, addNext:#selector(increaseAdjustMonth), start: 1, end: 31)
    }
    
    @objc private func decreaseAdjustDay() {
        self.decreaseNumberField(this: self.txtAdjustDay, thisStepper: self.stpAdjustDay, next: self.txtAdjustMonth, minusNext:#selector(decreaseAdjustMonth), start: 1, end: 31)
        
    }
    
    @IBAction func onStepperAdjustDayClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtAdjustDay.integerValue
        if newValue > oldValue {
            self.increaseAdjustDay()
        }else{
            self.decreaseAdjustDay()
        }
        
        self.chkAdjustDay.state = .on
        self.generateDate()
    }
    
    // MARK: ADJUST TIME
    
    @IBAction func onPlusMinusAdjustTimeClicked(_ sender: NSButton) {
        if self.btnPlusMinusTime.image == NSImage(named: NSImage.addTemplateName) {
            self.btnPlusMinusTime.image = NSImage(named: NSImage.removeTemplateName)
        }else if self.btnPlusMinusTime.image == NSImage(named: NSImage.removeTemplateName) {
            self.btnPlusMinusTime.image = NSImage(named: NSImage.addTemplateName)
        }
        self.generateTime()
    }
    
    @objc private func increaseAdjustHour() {
        self.increaseNumberField(this: self.txtAdjustHour, thisStepper: self.stpAdjustHour, next: self.txtAdjustDay, addNext:#selector(increaseAdjustDay), start: 0, end: 23)
    }
    
    @objc private func decreaseAdjustHour() {
        self.decreaseNumberField(this: self.txtAdjustHour, thisStepper: self.stpAdjustHour, next: self.txtAdjustDay, minusNext:#selector(decreaseAdjustDay), start: 0, end: 23)
    }
    
    @IBAction func onStepperAdjustHourClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtAdjustHour.integerValue
        if newValue > oldValue {
            self.increaseAdjustHour()
        }else{
            self.decreaseAdjustHour()
        }
        
        self.chkAdjustHour.state = .on
        self.generateTime()
    }
    
    @objc private func increaseAdjustMinute() {
        self.increaseNumberField(this: self.txtAdjustMinute, thisStepper: self.stpAdjustMinute, next: self.txtAdjustHour, addNext:#selector(increaseAdjustHour), start: 0, end: 59)
    }
    
    @objc private func decreaseAdjustMinute() {
        self.decreaseNumberField(this: self.txtAdjustMinute, thisStepper: self.stpAdjustMinute, next: self.txtAdjustHour, minusNext:#selector(decreaseAdjustHour), start: 0, end: 59)
    }
    
    @IBAction func onStepperAdjustMinuteClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtAdjustMinute.integerValue
        if newValue > oldValue {
            self.increaseAdjustMinute()
        }else{
            self.decreaseAdjustMinute()
        }
        
        self.chkAdjustMinute.state = .on
        self.generateTime()
    }
    
    @objc private func increaseAdjustSecond() {
        self.increaseNumberField(this: self.txtAdjustSecond, thisStepper: self.stpAdjustSecond, next: self.txtAdjustMinute, addNext:#selector(increaseAdjustMinute), start: 0, end: 59)
    }
    
    @IBAction func onStepperAdjustSecondClicked(_ sender: NSStepper) {
        let newValue = sender.integerValue
        let oldValue = self.txtAdjustMinute.integerValue
        if newValue > oldValue {
            self.increaseAdjustSecond()
        }else{
            self.txtAdjustSecond.integerValue = newValue
        }
        
        self.chkAdjustSecond.state = .on
        self.generateTime()
    }
    
    @objc func onDateComponentsChecks(sender:NSButton) {
        self.generateDate()
    }
    
    @objc func onTimeComponentsChecks(sender:NSButton) {
        self.generateTime()
    }
    
    fileprivate func generateDate() {
        var result = ""
        var selectedDate = ""
        var adjust = self.btnPlusMinusDate.image == NSImage(named: NSImage.addTemplateName) ? "+" : "-"
        var adjustYear = ""
        var adjustMonth = ""
        var adjustDay = ""
        if self.chkSelectedDate.state == .on {
            selectedDate = "\(self.txtSelectedYear.intValue)-\(self.txtSelectedMonth.intValue)-\(self.txtSelectedDay.intValue)"
        }
        if self.chkAdjustYear.state == .on {
            adjustYear = "\(self.txtAdjustYear.intValue)yrs "
        }
        if self.chkAdjustMonth.state == .on {
            adjustMonth = "\(self.txtAdjustMonth.intValue)mon "
        }
        if self.chkAdjustDay.state == .on {
            adjustDay = "\(self.txtAdjustDay.intValue)day"
        }
        if self.chkAdjustYear.state == .off && self.chkAdjustMonth.state == .off && self.chkAdjustDay.state == .off {
            adjust = ""
        }
        result = "\(selectedDate) \(adjust)\(adjustYear)\(adjustMonth)\(adjustDay)"
        self.txtReferenceDate.stringValue = result
        
        self.applyToTable()
    }
    
    fileprivate func generateTime() {
        var result = ""
        var selectedTime = ""
        var adjust = self.btnPlusMinusTime.image == NSImage(named: NSImage.addTemplateName) ? "+" : "-"
        var adjustHour = ""
        var adjustMinute = ""
        var adjustSecond = ""
        if self.chkSelectedTime.state == .on {
            selectedTime = "\(self.txtSelectedHour.intValue):\(self.txtSelectedMinute.intValue):\(self.txtSelectedSecond.intValue)"
        }
        if self.chkAdjustHour.state == .on {
            adjustHour = "\(self.txtAdjustHour.intValue)hrs "
        }
        if self.chkAdjustMinute.state == .on {
            adjustMinute = "\(self.txtAdjustMinute.intValue)min "
        }
        if self.chkAdjustSecond.state == .on {
            adjustSecond = "\(self.txtAdjustSecond.intValue)sec"
        }
        if self.chkAdjustHour.state == .off && self.chkAdjustMinute.state == .off && self.chkAdjustSecond.state == .off {
            adjust = ""
        }
        result = "\(selectedTime) \(adjust)\(adjustHour)\(adjustMinute)\(adjustSecond)"
        self.txtReferenceTime.stringValue = result
        
        self.applyToTable()
    }
    
    fileprivate func applyToTable(applyCalendar:Bool = true) {
        for image in self.images {
            if self.chkEarliestDate.state == .on {
                image.valueDate = self.getEarliestDate(image)
            }else{
                image.valueDate = self.adjustDateTimeOfImage(image: image)
            }
        }
        self.table.reloadData()
        if applyCalendar {
            if let first = self.images[self.lastSelectedRow ?? 0].valueDate {
                self.calendarView.date = first
                self.calendarView.selectedDate = first
                self.calendarView.originDate = self.images[self.lastSelectedRow ?? 0].photoTakenDate!
            }
        }
        
    }
    
    fileprivate func adjustDateTimeOfImage(image:ImageTimestamp) -> Date? {
        if let date = image.photoTakenDate {
            var year = Calendar.current.component(.year, from: date)
            var month = Calendar.current.component(.month, from: date)
            var day = Calendar.current.component(.day, from: date)
            
            var hour = Calendar.current.component(.hour, from: date)
            var minute = Calendar.current.component(.minute, from: date)
            var second = Calendar.current.component(.second, from: date)
            
            if self.chkSelectedDate.state == .on {
                year = self.txtSelectedYear.integerValue
                month = self.txtSelectedMonth.integerValue
                day = self.txtSelectedDay.integerValue
            }
            
            if self.chkSelectedTime.state == .on {
                hour = self.txtSelectedHour.integerValue
                minute = self.txtSelectedMinute.integerValue
                second = self.txtSelectedSecond.integerValue
            }
            
            let plusDate = self.btnPlusMinusDate.image == NSImage(named: NSImage.addTemplateName) ? true : false
            let plusTime = self.btnPlusMinusTime.image == NSImage(named: NSImage.addTemplateName) ? true : false
            
            if self.chkAdjustYear.state == .on {
                if plusDate {
                    year += self.txtAdjustYear.integerValue
                }else{
                    year -= self.txtAdjustYear.integerValue
                }
            }
            
            if self.chkAdjustMonth.state == .on {
                if plusDate {
                    month += self.txtAdjustMonth.integerValue
                }else{
                    month -= self.txtAdjustMonth.integerValue
                }
            }
            
            if self.chkAdjustDay.state == .on {
                if plusDate {
                    day += self.txtAdjustDay.integerValue
                }else{
                    day -= self.txtAdjustDay.integerValue
                }
            }
            
            if self.chkAdjustHour.state == .on {
                if plusTime {
                    hour += self.txtAdjustHour.integerValue
                }else{
                    hour -= self.txtAdjustHour.integerValue
                }
            }
            
            if self.chkAdjustMinute.state == .on {
                if plusTime {
                    minute += self.txtAdjustMinute.integerValue
                }else{
                    minute -= self.txtAdjustMinute.integerValue
                }
            }
            
            if self.chkAdjustSecond.state == .on {
                if plusTime {
                    second += self.txtAdjustSecond.integerValue
                }else{
                    second -= self.txtAdjustSecond.integerValue
                }
            }
            
            var merged = DateComponents()
            merged.year = year
            merged.month = month
            merged.day = day
            merged.hour = hour
            merged.minute = minute
            merged.second = second
            
            if let result = Calendar.current.date(from: merged) {
                return result
            }
        }
        return nil
    }
    
    // MARK: - EARLIEST DATE
    
    private func getEarliestDate(_ image:ImageTimestamp) -> Date {
        let now = Date()
        var result = now
        if let dt = image.dateTimeOriginal, dt < result {
            result = dt
        }
        if let dt = image.exifCreateDate, dt < result {
            result = dt
        }
        if let dt = image.exifModifyDate, dt < result {
            result = dt
        }
        if let dt = image.fileCreateDate, dt < result {
            result = dt
        }
        if let dt = image.fileModifyDate, dt < result {
            result = dt
        }
        if let dt = image.softwareModifyDate, dt < result {
            result = dt
        }
        if let dt = image.trackCreateDate, dt < result {
            result = dt
        }
        if let dt = image.trackModifyDate, dt < result {
            result = dt
        }
        if let dt = image.videoCreateDate, dt < result {
            result = dt
        }
        if let dt = image.videoModifyDate, dt < result {
            result = dt
        }
        let dts = image.filenameDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        if let dt = dateFormatter.date(from: dts), dt < result {
            result = dt
        }
        return result
    }
    
    @IBAction func onChkEarliestDateClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.toggleCalendarAdjustment(false)
            self.applyToTable(applyCalendar: false)
        }else{
            self.toggleCalendarAdjustment(true)
        }
    }
    
    @IBAction func onReExtractDateFromFilenameClicked(_ sender: NSButton) {
        for image in self.images {
            let dateString = Naming.DateTime.recognize(url: URL(fileURLWithPath: image.path))
            image.filenameDate = dateString
        }
        self.applyToTable(applyCalendar: false)
    }
    
    
    // MARK: - OK
    
    
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onOKClicked(_ sender: NSButton) {
        guard  self.chkPhotoTakenDate.state == .on
            || self.chkEXIFCreateDate.state == .on
            || self.chkEXIFModifyDate.state == .on
            || self.chkEXIFDateTimeOriginal.state == .on
            || self.chkFileCreateDate.state == .on
            else {
            Alert.noOptionSelected(message: "NO [DATE FIELD] SELECTED")
            return
        }
        self.btnOK.isEnabled = false
        self.btnClose.isEnabled = false
        
        if self.onBeforeChanges != nil {
            DispatchQueue.main.async {
                self.onBeforeChanges!()
            }
        }
        
        var tags:Set<String> = []
        if self.chkPhotoTakenDate.state == .on {
            tags.insert("PhotoTakenDate")
        }
        if self.chkEXIFCreateDate.state == .on {
            tags.insert("CreateDate")
        }
        if self.chkEXIFModifyDate.state == .on {
            tags.insert("ModifyDate")
        }
        if self.chkEXIFDateTimeOriginal.state == .on {
            tags.insert("DateTimeOriginal")
        }
        if self.chkFileCreateDate.state == .on {
            tags.insert("FileCreateDate")
        }
        var count = 0
        self.accumulator = Accumulator(target: self.images.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage, onCompleted: {_ in
            
            self.lblMessage.stringValue = "Updated \(count) images."
        })
        
        DispatchQueue.global().async {
            for image in self.images {
                
                //ExifTool.helper.patchDateForPhoto(date: image.valueDate!, url: URL(fileURLWithPath: image.path), tags: tags)
                let state = ModelStore.default.updateImageDates(path: image.path, date: image.valueDate!, fields: tags)
                self.updateImageDates(image: image, date: image.valueDate!, fields: tags)
                if state == .OK {
                    count += 1
                }
                
                DispatchQueue.main.async {
                    let _ = self.accumulator?.add("")
                }
            }
            DispatchQueue.main.async {
                self.table.reloadData()
                self.btnOK.isEnabled = true
                self.btnClose.isEnabled = true
                if self.onCompleted != nil {
                    self.onCompleted!()
                }
            }
        }
        
    }
    
    fileprivate func updateImageDates(image:ImageTimestamp, date:Date, fields: Set<String>){
        
        for field in fields {
            if field == "DateTimeOriginal" {
                image.dateTimeOriginal = date
                continue
            }
            if field == "CreateDate" {
                image.exifCreateDate = date
                continue
            }
            if field == "ModifyDate" {
                image.exifModifyDate = date
                image.fileModifyDate = date
                continue
            }
            if field == "FileCreateDate" {
                image.fileCreateDate = date
                continue
            }
        }
        image.photoTakenDate = date
    }
    
    @IBAction func onCloseClicked(_ sender: NSButton) {
        if self.onClose != nil {
            self.onClose!()
        }
    }
    
    
}

// MARK: - Calendar delegate

extension DateTimeViewController : LunarCalendarViewDelegate {
    @objc func didSelectDate(_ selectedDate: Date) {
        let year = Calendar.current.component(.year, from: selectedDate)
        let month = Calendar.current.component(.month, from: selectedDate)
        let day = Calendar.current.component(.day, from: selectedDate)
        
        self.txtSelectedYear.integerValue = year
        self.stpSelectedYear.integerValue = year
        self.txtSelectedMonth.integerValue = month
        self.stpSelectedMonth.integerValue = month
        self.txtSelectedDay.integerValue = day
        self.stpSelectedDay.integerValue = day
        
        self.chkSelectedDate.state = .on
        self.generateDate()
    }
}


// MARK: - TableView delegate functions

extension DateTimeViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.images.count - 1) {
            return nil
        }
        let image:ImageTimestamp = self.images[row]
        var value = ""
        //var tip: String? = nil
        var isAction = true
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("filename"):
                value = image.filename
                isAction = false
            case NSUserInterfaceItemIdentifier("event"):
                value = image.event
                isAction = false
            case NSUserInterfaceItemIdentifier("path"):
                value = image.folderPath
                isAction = false
            case NSUserInterfaceItemIdentifier("valueDate"):
                if image.valueDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.valueDate!)
                }
                isAction = false
            case NSUserInterfaceItemIdentifier("photoTakenDate"):
                if image.photoTakenDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.photoTakenDate!)
                }
            case NSUserInterfaceItemIdentifier("dateTimeOriginal"):
                if image.dateTimeOriginal == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.dateTimeOriginal!)
                }
            case NSUserInterfaceItemIdentifier("exifCreateDate"):
                if image.exifCreateDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.exifCreateDate!)
                }
            case NSUserInterfaceItemIdentifier("exifModifyDate"):
                if image.exifModifyDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.exifModifyDate!)
                }
            case NSUserInterfaceItemIdentifier("fileCreateDate"):
                if image.fileCreateDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.fileCreateDate!)
                }
            case NSUserInterfaceItemIdentifier("fileModifyDate"):
                if image.fileModifyDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.fileModifyDate!)
                }
            case NSUserInterfaceItemIdentifier("softwareModifyDate"):
                if image.softwareModifyDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.softwareModifyDate!)
                }
            case NSUserInterfaceItemIdentifier("VideoCreateDate"):
                if image.videoCreateDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.videoCreateDate!)
                }
            case NSUserInterfaceItemIdentifier("VideoModifyDate"):
                if image.videoModifyDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.videoModifyDate!)
                }
            case NSUserInterfaceItemIdentifier("TrackCreateDate"):
                if image.trackCreateDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.trackCreateDate!)
                }
            case NSUserInterfaceItemIdentifier("TrackModifyDate"):
                if image.trackModifyDate == nil {
                    value = ""
                }else{
                    value = self.tableDateTimeFormatter.string(from: image.trackModifyDate!)
                }
            case NSUserInterfaceItemIdentifier("dateInFilename"):
                value = image.filenameDate
                
            default:
                break
            }
            
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            if isAction {
                colView.subviews.removeAll()
                
                let button:NSButton = NSButton(frame: NSRect(x: 2, y: 2, width: 150, height: 15))
                button.setButtonType(.momentaryPushIn)
                button.isBordered = true
                //button.bezelStyle = NSButton.BezelStyle.smallSquare
                //button.image = NSImage(named: .multipleDocuments)
                button.action = #selector(DateTimeViewController.copyDateAction(sender:))
                button.isHidden = false
                button.title = value
                colView.addSubview(button)
            }else{
            
                colView.textField?.stringValue = value;
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
//        rowView.backgroundColor = row % 2 == 1
//            ? NSColor.gray
//            : NSColor.darkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

// MARK: - TableView data source functions

extension DateTimeViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.images.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}

extension DateTimeViewController {
    
    @objc func copyDateAction(sender: NSButton) {
        print("Copy: \(sender.title)")
        if let date = self.tableDateTimeFormatter.date(from: sender.title) {
            
            self.calendarView.date = date
            self.calendarView.selectedDate = date
        
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let day = Calendar.current.component(.day, from: date)
            
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            let second = Calendar.current.component(.second, from: date)
            
            self.txtSelectedYear.integerValue = year
            self.stpSelectedYear.integerValue = year
            self.txtSelectedMonth.integerValue = month
            self.stpSelectedMonth.integerValue = month
            self.txtSelectedDay.integerValue = day
            self.stpSelectedDay.integerValue = day
            
            self.txtSelectedHour.integerValue = hour
            self.stpSelectedHour.integerValue = hour
            self.txtSelectedMinute.integerValue = minute
            self.stpSelectedMinute.integerValue = minute
            self.txtSelectedSecond.integerValue = second
            self.stpSelectedSecond.integerValue = second
            
            self.chkSelectedDate.state = .on
            self.chkSelectedTime.state = .on
            
            self.generateDate()
            self.generateTime()
        }
    }
}

class ImageTimestamp {
    
    var path:String = ""
    var filename:String = ""
    var filenameDate:String = ""
    var folderPath:String = ""
    var valueDate:Date?
    var photoTakenDate:Date?
    var dateTimeOriginal:Date?
    var exifCreateDate:Date?
    var exifModifyDate:Date?
    var fileCreateDate:Date?
    var fileModifyDate:Date?
    var softwareModifyDate:Date?
    var videoCreateDate:Date?
    var videoModifyDate:Date?
    var trackCreateDate:Date?
    var trackModifyDate:Date?
    var event:String = ""
    
    init(_ image:Image){
        self.path = image.path
        self.filename = image.filename
        self.folderPath = image.containerPath ?? ""
        self.photoTakenDate = image.photoTakenDate
        self.dateTimeOriginal = image.exifDateTimeOriginal
        self.exifCreateDate = image.exifCreateDate
        self.exifModifyDate = image.exifModifyDate
        self.fileCreateDate = image.filesysCreateDate
        self.fileModifyDate = image.exifModifyDate
        self.softwareModifyDate = image.softwareModifiedTime
        self.videoCreateDate = image.videoCreateDate
        self.videoModifyDate = image.videoModifyDate
        self.trackCreateDate = image.trackCreateDate
        self.trackModifyDate = image.trackModifyDate
        self.event = image.event ?? ""
        self.filenameDate = image.dateTimeFromFilename ?? ""
    }
}

