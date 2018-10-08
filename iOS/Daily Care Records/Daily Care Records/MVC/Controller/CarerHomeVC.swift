//
//  CarerHomeVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/4/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class CarerHomeVC: UIViewController, FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var tblSchedule: UITableView!
    private var scheduleArray = NSMutableArray()
    var selectedDate = ""
    private var dailyScheduleArray : [Schedule] = [Schedule]()
    @IBOutlet weak var topScheduleTable: NSLayoutConstraint!
    @IBOutlet weak var btnAvailability: MButton!
    @IBOutlet weak var btnAddSchedule: MButton!
    private var selectedRow:IndexPath?
    var deleteMedicationRow:Int?
    var statusBtn = UIButton()
    private var pastDate:Bool = false
    private var selectedDatesArry = [[String:Any]]()
    // MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Schedule", controller: self, isReveal : true)
        tblSchedule.register(UINib.init(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calendarView.allowsMultipleSelection = false
        calendarView.select(calendarView.today)
        if utilityMgr.getUDVal(forKey: "employee_type") as! String == "1" {
            btnAddSchedule.isHidden = true
            btnAvailability.isHidden = true
            DispatchQueue.global(qos: .background).async {
                utilityMgr.showIndicator()
                if self.selectedDate == "" {
                    self.selectedDate = TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
                }
            let urlString = UrlConstants.BASE_URL+UrlConstants.get_MyDayWiseScheduleCount+self.selectedDate
                self.webserviceCall(param: nil, link: urlString)
            }
        } else {
            // manager
            // check current login supervisor has access to schedule from manager
            if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
                if user == "3"{
                    IsScheduleVCOpen = true   // variable for notification handling only for supervisor
                    if let accessTo = UserDefaults.standard.value(forKey: "sectionAccess") as? String{
                        let convertedArray = accessTo.components(separatedBy: ",")
                        if convertedArray.contains("2"){
                            btnAddSchedule.isHidden = false
                        }else{
                            btnAddSchedule.isHidden = true
                        }
                    }
                }
            }
            //            btnAddSchedule.isHidden = false
            btnAvailability.isHidden = false
            topScheduleTable.constant = 43
            DispatchQueue.global(qos: .background).async {
                utilityMgr.showIndicator()
                if self.selectedDate == "" {
                    self.selectedDate = TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
                }
                let urlString = UrlConstants.BASE_URL+UrlConstants.get_DayWiseScheduleCount+self.selectedDate
                self.webserviceCall(param: nil, link: urlString)
            }
        }
        if selectedRow != nil{
            self.presentAlert(indexPath: selectedRow!)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        IsScheduleVCOpen = false
    }
    
    
    
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "updateScheduleStatus" {
                    if self.statusBtn.titleLabel?.text == "To do"{
                        self.statusBtn.setTitleColor(UIColor.red, for: .normal)
                        self.statusBtn.setTitle("Done", for: .normal)
                        let cell = self.tblSchedule.cellForRow(at: IndexPath(row: self.statusBtn.tag, section: 0)) as! ScheduleCell
                        cell.backgroundColor = UIColor.lightGray
                    }else if self.statusBtn.titleLabel?.text == "Done"{
                        self.statusBtn.setTitleColor(UIColor.yellow, for: .normal)
                        self.statusBtn.setTitle("To do", for: .normal)
                        let cell = self.tblSchedule.cellForRow(at: IndexPath(row: self.statusBtn.tag, section: 0)) as! ScheduleCell
                        cell.backgroundColor = APP_COLOR_GREEN
                    }
                    self.getDayWiseSchedule(nDate:self.selectedDate)
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                print(response)
                let methodName = response["method"] as! String
                if methodName == "get_MyDayWiseScheduleCount" {
                    if self.selectedDate == ""{
                    let nDate = TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
                        self.selectedDate = nDate
                    }
                        self.getDayWiseSchedule(nDate:self.selectedDate) //nDate
//                    self.getDayWiseSchedule(nDate:nDate)
                    DispatchQueue.main.async {
                        self.scheduleArray.removeAllObjects()
                        self.selectedDatesArry = (response["data"] as? [[String:Any]])!
                        for i in 0..<(response["data"] as! NSArray).count {
                            self.scheduleArray.add((response["data"] as! NSArray)[i])
                        }
//                        for j in 0..<self.scheduleArray.count {
//                            if (self.scheduleArray[j] as AnyObject)["count"] as! String != "0" {
//                                self.calendarView.select(TimeManager.dateFromString(strDate: (self.scheduleArray[j] as AnyObject)["date"] as! String, fromFormat: "yyyy-MM-dd"))
//
//
//                            }
//                        }
                        self.calendarView.reloadData()
                    }
                } else if methodName == "get_DayWiseScheduleCount" {
                    let nDate = TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
                    self.selectedDate = nDate
                    self.getMyDayWiseSchedule(nDate:nDate)
                    DispatchQueue.main.async {
                        self.scheduleArray.removeAllObjects()
                        self.selectedDatesArry = (response["data"] as? [[String:Any]])!
                        
                        for i in 0..<(response["data"] as! NSArray).count {
                            self.scheduleArray.add((response["data"] as! NSArray)[i])
                        }
//                        for j in 0..<self.scheduleArray.count {
//                            if (self.scheduleArray[j] as AnyObject)["count"] as! String != "0" {
//                                self.calendarView.select(TimeManager.dateFromString(strDate: (self.scheduleArray[j] as AnyObject)["date"] as! String, fromFormat: "yyyy-MM-dd"))
//                            }
//                        }
                        self.calendarView.reloadData()
                    }
                }else if methodName == "delete_Schedule" {
                    print("*** Successfully deleted ***")
        DispatchQueue.main.async {
            if self.deleteMedicationRow != nil{
                let indexPath = IndexPath(row: self.deleteMedicationRow!, section: 0)
                self.dailyScheduleArray.remove(at: self.deleteMedicationRow!)
                self.tblSchedule.beginUpdates()
                self.tblSchedule.deleteRows(at: [indexPath], with: .fade)
                self.tblSchedule.endUpdates()
                self.deleteMedicationRow = nil
            }
        }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    private func getDayWiseSchedule(nDate:String){
        let urlString = UrlConstants.BASE_URL+UrlConstants.get_MyDayWiseSchedule+nDate
        apiMgr.GetApi(webserviceURL: urlString, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "MyDayWiseSchedule" {
                DispatchQueue.main.async {
                    self.dailyScheduleArray.removeAll()
                    for i in 0..<(response["data"] as! NSArray).count {
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let d = Schedule()
                        d.schedule_id = dict["schedule_id"] as? String
                        d.company_id = dict["company_id"] as? String
                        d.employeeid = dict["employeeid"] as? String
                        d.client_id = dict["client_id"] as? String
                        d.start_datetime = dict["start_datetime"] as? String
                        d.end_datetime = dict["end_datetime"] as? String
                        d.secheduled_by = dict["secheduled_by"] as? String
                        d.created_at = dict["created_at"] as? String
                        d.status = dict["status"] as? String
                        d.client_name = dict["client_name"] as? String
                        d.employee_name = dict["employee_name"] as? String
                        d.employee_number = dict["employee_number"] as? String
                        d.employee_picture = dict["employee_picture"] as? String
                        d.postcode = dict["client_postcode"] as? String
                        self.dailyScheduleArray.append(d)
                    }
                    DispatchQueue.main.async {
                        if self.dailyScheduleArray.count == 0 {
                            self.tblSchedule.isHidden = true
                        } else {
                            self.tblSchedule.isHidden = false
                        }
                        self.tblSchedule.reloadData()
                    }
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func getMyDayWiseSchedule(nDate:String){
        utilityMgr.showIndicator()
        let urlString = UrlConstants.BASE_URL+UrlConstants.get_DayWiseSchedule+nDate
        apiMgr.GetApi(webserviceURL: urlString, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_DayWiseSchedule" {
                DispatchQueue.main.async {
                    self.dailyScheduleArray.removeAll()
                    for i in 0..<(response["data"] as! NSArray).count {
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let d = Schedule()
                        d.schedule_id = dict["schedule_id"] as? String
                        d.company_id = dict["company_id"] as? String
                        d.employeeid = dict["employeeid"] as? String
                        d.client_id = dict["client_id"] as? String
                        d.start_datetime = dict["start_datetime"] as? String
                        d.end_datetime = dict["end_datetime"] as? String
                        d.secheduled_by = dict["secheduled_by"] as? String
                        d.created_at = dict["created_at"] as? String
                        d.status = dict["status"] as? String
                        d.client_name = dict["client_name"] as? String
                        d.employee_name = dict["employee_name"] as? String
                        d.employee_number = dict["employee_number"] as? String
                        d.employee_picture = dict["employee_picture"] as? String
                        d.postcode = dict["client_postcode"] as? String
                        self.dailyScheduleArray.append(d)
                    }
                        if self.dailyScheduleArray.count == 0 {
                            self.tblSchedule.isHidden = true
//                            self.kAlertView(title: APPNAME, message: Constants.Register.NO_SCHEDULE)
                        } else {
                            self.tblSchedule.isHidden = false
                        }
                        self.tblSchedule.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    // MARK:- Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyScheduleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ScheduleCell! = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as! ScheduleCell!
        cell.lblname.text = dailyScheduleArray[indexPath.row].employee_name!
        let startTime = TimeManager.FormatDateString(strDate: dailyScheduleArray[indexPath.row].start_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "HH:mm a")
        let endTime = TimeManager.FormatDateString(strDate: dailyScheduleArray[indexPath.row].end_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "HH:mm a")
        cell.lblStarttime.text = startTime //dailyScheduleArray[indexPath.row].start_datetime!
        cell.lblEndtime.text = endTime
        cell.client_name.text = dailyScheduleArray[indexPath.row].client_name!
        cell.btnChangeSchedule.setTitle(dailyScheduleArray[indexPath.row].status! == "0" ? "To do" : "Done", for: .normal)
        let status = dailyScheduleArray[indexPath.row].status!
        if status == "0"{
            cell.backgroundColor = APP_COLOR_GREEN
            cell.btnChangeSchedule.setTitleColor(UIColor.yellow, for: .normal)
        } else{
            cell.backgroundColor = UIColor.lightGray
            cell.btnChangeSchedule.setTitleColor(UIColor.red, for: .normal)
        }
//        if dailyScheduleArray[indexPath.row].status! == "0" {
            cell.btnChangeSchedule.tag = indexPath.row
        statusBtn = cell.btnChangeSchedule
        statusBtn.tag = cell.btnChangeSchedule.tag
        if utilityMgr.getUDVal(forKey: "employee_type") as? String == "1"{
        cell.btnChangeSchedule.addTarget(self, action: #selector(updateStatus(_:)), for: .touchUpInside)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed(String(describing: "ScheduleHeader"), owner: self, options: nil)?[0] as! UIView
//        if ScreenSize.SCREEN_WIDTH <= 320 {
//            let clientName = header.viewWithTag(100) as! UILabel
//            clientName.text = "Client\nName"
//        }
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScreenSize.SCREEN_WIDTH <= 320 ? 60 : 40
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
            if (user == "2")||(user == "3"){
                return
            }
        }
        if (self.selectedDate) == (TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")){
            self.selectedRow = indexPath
            self.presentAlert(indexPath: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            tableView.setEditing(false, animated: true)
            let vc = managerStoryBoard.instantiateViewController(withIdentifier: "AddScheduleVC") as! AddScheduleVC
            vc.schedule_id = self.dailyScheduleArray[editActionsForRowAt.row].schedule_id
            vc.startTime = self.dailyScheduleArray[editActionsForRowAt.row].start_datetime!
            vc.endTime = self.dailyScheduleArray[editActionsForRowAt.row].end_datetime!
            vc.employeeId = self.dailyScheduleArray[editActionsForRowAt.row].employeeid!
            vc.clientId = self.dailyScheduleArray[editActionsForRowAt.row].client_id!
            vc.client_name = self.dailyScheduleArray[editActionsForRowAt.row].client_name
            vc.staff_name = self.dailyScheduleArray[editActionsForRowAt.row].employee_name
            self.pushview(objtype: vc)
        }
        edit.backgroundColor = APP_COLOR_BLUE
        let del = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let schedule_Id = self.dailyScheduleArray[editActionsForRowAt.row].schedule_id!
            self.deleteMedicationRow = editActionsForRowAt.row
            DispatchQueue.global(qos: .background).async {
                utilityMgr.showIndicator()
                self.webserviceCall(param: nil, link: UrlConstants.BASE_URL+UrlConstants.delete_Schedule+schedule_Id)
//                DispatchQueue.main.async {
//                    self.dailyScheduleArray.remove(at: editActionsForRowAt.row)
//                    self.tblSchedule.beginUpdates()
//                    self.tblSchedule.deleteRows(at: [editActionsForRowAt], with: .fade)
//                    self.tblSchedule.endUpdates()
//                }
            }
        }
        del.backgroundColor = APP_COLOR_GREEN
        return [del,edit]
    }
    // MARK:- FSCalender methods
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        //  heightCalender.constant = bounds.height
        //  calenderView.layoutIfNeeded()
    }
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//       let nextMonth = Calendar.current.date(byAdding: .month, value: 0, to: calendar.currentPage)
//        print(nextMonth)
//        let date2 = TimeManager.FormatDateString(strDate: String(describing: nextMonth!), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM")
//        print(date2)
//        self.selectedDate = date2
//        let urlString = UrlConstants.BASE_URL+UrlConstants.get_MyDayWiseScheduleCount+date2
//        print(urlString)
//        self.webserviceCall(param: nil, link: urlString)
//    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if date.toLocalDate() < Date().toLocalDate()
        {
            pastDate = true
        }
        else{
            pastDate = false
        }
            utilityMgr.showIndicator()
            let nDate = TimeManager.FormatDateString(strDate: String(describing:date), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
            self.selectedDate = nDate
            if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3") {
                self.getMyDayWiseSchedule(nDate: nDate)
            } else {
                self.getDayWiseSchedule(nDate:nDate)
            }
    }
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {

    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
       let date = TimeManager.FormatDateString(strDate: String(describing:date), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
        for i in 0..<selectedDatesArry.count{
            if ((selectedDatesArry[i] as AnyObject)["date"] as? String) == date{
                let count = (selectedDatesArry[i] as AnyObject)["count"] as! String
                return Int(count)!
            }
        }
        return 0
    }
   
    func presentAlert(indexPath:IndexPath){
        let name = dailyScheduleArray[indexPath.row].client_name
        let time = TimeManager.FormatDateString(strDate: dailyScheduleArray[indexPath.row].start_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "HH:mm a")
        var alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let nameLbl = UIAlertAction(title: name!+" "+time, style: .default , handler: nil)
        let marchart = UIAlertAction(title: "MAR Chart", style: .default) { (mar) in
            //            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterMedicationVC") as! EnterMedicationVC
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MedicationChartVC") as! MedicationChartVC
            vc.client_id = self.dailyScheduleArray[indexPath.row].client_id!
            vc.titleString = self.dailyScheduleArray[indexPath.row].client_name!
            self.pushview(objtype: vc)
        }
        let prog = UIAlertAction(title: "Program of Care", style: .default) { (progr) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProgramCareVC") as! ProgramCareVC
            vc.client_id = self.dailyScheduleArray[indexPath.row].client_id!
            self.pushview(objtype: vc)
        }
        let profile = UIAlertAction(title: "View Client Profile", style: .default) { (profi) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.titleString = self.dailyScheduleArray[indexPath.row].client_name!
            vc.client_id = self.dailyScheduleArray[indexPath.row].client_id!
            self.pushview(objtype: vc)
        }
        let daily = UIAlertAction(title: "Daily Records", style: .default) { (dR) in
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DailyRecordsVC") as! DailyRecordsVC
            vc.client_id = self.dailyScheduleArray[indexPath.row].client_id!
            vc.client_name = self.dailyScheduleArray[indexPath.row].client_name!
            vc.postcode = self.dailyScheduleArray[indexPath.row].postcode!
            self.pushview(objtype: vc)
        }
        alert.addAction(nameLbl)
        alert.addAction(marchart)
        alert.addAction(prog)
        alert.addAction(daily)
        alert.addAction(profile)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancel)
        present(alert, animated: false, completion: nil)
    }
    
    
    // MARK:- IBActions
    @IBAction func updateStatus(_ sender:UIButton){
        if (self.selectedDate) == (TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")){
        let alertToDo = UIAlertController(title: "Select Action", message: Constants.Register.TASK_OPTIONS, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (y) in
            DispatchQueue.global(qos: .userInitiated).async {
                if sender.titleLabel?.text != "Done"{
                    print(self.statusBtn.titleLabel?.text)
                self.statusBtn.setTitle("Done", for: .normal)
                    utilityMgr.showIndicator()
                    let param = ["schedule_id":self.dailyScheduleArray[sender.tag].schedule_id!,"status":"1"]//,"start_datetime":self.dailyScheduleArray[sender.tag].start_datetime!
                    print(param)
                    self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.updateScheduleStatus)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let No = UIAlertAction(title: "NO", style: .default) { (No) in
            print(self.statusBtn.titleLabel?.text)
            if sender.titleLabel?.text == "Done"{
                sender.setTitle("To do", for: .normal)
                self.statusBtn.setTitle("To do", for: .normal)
                utilityMgr.showIndicator()
                let param = ["schedule_id":self.dailyScheduleArray[sender.tag].schedule_id!,"status":"0"]
                print(param)
                self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.updateScheduleStatus)
//                let cell = self.tblSchedule.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! ScheduleCell
//                cell.backgroundColor = APP_COLOR_GREEN
//                sender.setTitleColor(UIColor.yellow, for: .normal)
            }

        }
        alertToDo.addAction(yes)
        alertToDo.addAction(cancel)
        alertToDo.addAction(No)
        present(alertToDo, animated: true, completion: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func availabilityPressed(_ sender: MButton) {
        let vc = managerStoryBoard.instantiateViewController(withIdentifier: "CheckScheduleVC") as! CheckScheduleVC
        self.pushview(objtype: vc)
    }
    @IBAction func addSchedulePressed(_ sender: MButton) {
        if pastDate{
            self.kAlertView(title: APPNAME, message:Constants.Register.CAN_NOT_CREATE_EVENT)
        }else{
            let vc = managerStoryBoard.instantiateViewController(withIdentifier: "AddScheduleVC") as! AddScheduleVC
            vc.previousSelectedDate = TimeManager.dateFromString(strDate: selectedDate, fromFormat: "yyyy-MM-dd")
            self.pushview(objtype: vc)
        }
        
      
    }
    
}
extension Date{
    func toLocalDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: self)
        let UTCTimeAsString = dateFormatter.date(from: strDate)
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: UTCTimeAsString!))
        return Date(timeInterval: seconds, since: UTCTimeAsString!)//UTCTimeAsString!
    }
}

