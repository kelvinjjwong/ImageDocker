//
//  DateTimeViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/9/16.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class DateTimeViewController: NSViewController {
    
    // MARK: Controls
    
    // Calendar
    
    @IBOutlet weak var calendarViewContainer: NSView!
    var calendarView:LunarCalendarView!
    var calendarDateFormatter:DateFormatter!
    
    // Table
    @IBOutlet weak var table: NSScrollView!
    
    // Reference Date
    @IBOutlet weak var chkReferenceDate: NSButton!
    @IBOutlet weak var txtReferenceDate: NSTextField!
    @IBOutlet weak var chkReferenceTime: NSButton!
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
    
    // Refer / Selected / Adjust
    
    @IBOutlet weak var chkReference: NSButton!
    @IBOutlet weak var chkSelected: NSButton!
    @IBOutlet weak var chkAdjust: NSButton!
    
    // Apply to
    @IBOutlet weak var chkEXIFCreateDate: NSButton!
    @IBOutlet weak var chkEXIFModifyDate: NSButton!
    @IBOutlet weak var chkEXIFDateTimeOriginal: NSButton!
    @IBOutlet weak var chkFileCreateDate: NSButton!
    
    // Progress
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblMessage: NSTextField!
    
    // OK button
    @IBOutlet weak var btnOK: NSButton!
    
    
    // MARK: INIT
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "DateTimeViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarDateFormatter = DateFormatter()
        self.calendarDateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.calendarView = LunarCalendarView()
        self.calendarView.delegate = self
        let now = Date()
        self.calendarView.date = now
        self.calendarView.selectedDate = now;
        
        self.calendarViewContainer.addSubview(self.calendarView.view)
        
        self.reinitNumbers()
        
    }
    
    private func reinitNumbers() {
        self.txtAdjustYear.integerValue = 0
        self.txtAdjustMonth.integerValue = 0
        self.txtAdjustDay.integerValue = 0
        self.txtAdjustHour.integerValue = 0
        self.txtAdjustMinute.integerValue = 0
        self.txtAdjustSecond.integerValue = 0
    }
    
    // MARK: ACTIONS
    
    // MARK: SWITCHER
    
    @IBAction func onChkReferenceClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkSelected.state = .off
            self.chkAdjust.state = .off
        }
    }
    
    @IBAction func onChkSelectedClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkReference.state = .off
            self.chkAdjust.state = .off
        }
    }
    
    @IBAction func onChkAdjustClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkSelected.state = .off
            self.chkReference.state = .off
        }
    }
    
    // MARK: DATE TIME CASCADE
    
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
    }
    
    @IBAction func onStepperSelectedYearClicked(_ sender: NSStepper) {
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
    }
    
    // MARK: ADJUST DATE
    
    @IBAction func onPlusMinusAdjustDateClicked(_ sender: NSButton) {
        if self.btnPlusMinusDate.image == NSImage(named: .addTemplate) {
            self.btnPlusMinusDate.image = NSImage(named: .removeTemplate)
        }else if self.btnPlusMinusDate.image == NSImage(named: .removeTemplate) {
            self.btnPlusMinusDate.image = NSImage(named: .addTemplate)
        }
    }
    
    @IBAction func onStepperAdjustYearClicked(_ sender: NSStepper) {
        let value = sender.integerValue
        self.txtAdjustYear.integerValue = value
    }
    
    @objc private func increaseAdjustYear() {
        self.txtAdjustYear.integerValue += 1
    }
    
    @objc private func decreaseAdjustYear() {
        self.txtAdjustYear.integerValue -= 1
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
    }
    
    // MARK: ADJUST TIME
    
    @IBAction func onPlusMinusAdjustTimeClicked(_ sender: NSButton) {
        if self.btnPlusMinusTime.image == NSImage(named: .addTemplate) {
            self.btnPlusMinusTime.image = NSImage(named: .removeTemplate)
        }else if self.btnPlusMinusTime.image == NSImage(named: .removeTemplate) {
            self.btnPlusMinusTime.image = NSImage(named: .addTemplate)
        }
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
    }
    
    // MARK: OK
    
    @IBAction func onOKClicked(_ sender: NSButton) {
    }
    
}

// MARK: Calendar delegate

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
        
        self.chkSelected.state = .on
        self.chkReference.state = .off
        self.chkAdjust.state = .off
    }
}
