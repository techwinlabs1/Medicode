//
//  CheckScheduleVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/19/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class CheckScheduleVC: UIViewController,FSCalendarDelegate,FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var btnStaffMember: MButton!
    @IBOutlet weak var tblSchedule: UITableView!
    @IBOutlet weak var tblStaff: UITableView!
    @IBOutlet weak var btnAddSchedule: MButton!
    private var staffArray:[Employee]=[Employee]()
    private var scheduleArray:[Schedule]=[Schedule]()
    private var selected_employeeid : String?
    private var pastDate:Bool = false
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Check Availability", controller: self, isReveal : false)
        tblSchedule.register(UINib.init(nibName: "ScheduleCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.allowsMultipleSelection = false
        calendarView.select(calendarView.today)
        // check if login user has access to add schedule.
        if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
            print("currentLoginUser..\(user)")
            if user == "3"{
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
        tblStaff.layer.borderColor = UIColor.lightGray.cgColor
        tblStaff.layer.borderWidth = 1
        calendarView.select(Date())
        pageNo = 1
        getStaffMembers()
    }
    // MARK:- Server calls
    private func getStaffMembers(){
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_allStaffMembers+"\(pageNo)/"
            self.webserviceCall(link: link)
        }
    }
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            print(response)
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_allStaffMembers" {
                let dataA = response["data"] as! NSArray
                if pageNo == 1 {
                    self.staffArray.removeAll()
                }
                for i in 0..<dataA.count{
                    let emp = Employee()
                    let dict = dataA[i] as! NSDictionary
                    emp.employeeid = dict["employeeid"] as? String
                    emp.company_id = dict["company_id"] as? String
                    emp.employee_type = dict["employee_type"] as? String
                    emp.employee_number = dict["employee_number"] as? String
                    emp.employee_name = dict["employee_name"] as? String
                    emp.employee_email = dict["employee_email"] as? String
                    emp.employee_country_code = dict["employee_country_code"] as? String
                    emp.employee_mobile = dict["employee_mobile"] as? String
                    emp.employee_picture = dict["employee_picture"] as? String
                    emp.employee_designation = dict["employee_designation"] as? String
                    emp.designation = dict["designation"] as? String
                    self.staffArray.append(emp)
                }
                DispatchQueue.main.async {
                    self.tblStaff.reloadData()
                }
            } else if methodName == "get_DayScheduleOfCarer" {
                let dataA = response["data"] as! NSArray
                self.scheduleArray.removeAll()
                for i in 0..<dataA.count{
                    let emp = Schedule()
                    let dict = dataA[i] as! NSDictionary
                    emp.schedule_id = dict["schedule_id"] as? String
                    emp.company_id = dict["company_id"] as? String
                    emp.employeeid = dict["employeeid"] as? String
                    emp.client_id = dict["client_id"] as? String
                    emp.employee_name = dict["employee_name"] as? String
                    emp.start_datetime = dict["start_datetime"] as? String
                    emp.end_datetime = dict["end_datetime"] as? String
                    emp.secheduled_by = dict["secheduled_by"] as? String
                    emp.employee_picture = dict["employee_picture"] as? String
                    emp.created_at = dict["created_at"] as? String
                    emp.updated_at = dict["updated_at"] as? String
                    emp.status = dict["status"] as? String
                    emp.client_name = dict["client_name"] as? String
                    emp.client_picture = dict["client_picture"] as? String
                    emp.employee_number = dict["employee_number"] as? String
                    self.scheduleArray.append(emp)
                }
                DispatchQueue.main.async {
                    if self.scheduleArray.count > 0 {
                        self.tblSchedule.isHidden = false
                    } else {
                        self.tblSchedule.isHidden = true
                        self.kAlertView(title: APPNAME, message: Constants.Register.NO_SCHEDULE)
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
    // MARK:- FSCalender methods
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        //  heightCalender.constant = bounds.height
        //  calenderView.layoutIfNeeded()
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if date.toLocalDate() < Date().toLocalDate(){
            pastDate = true
            print("PastDate.")
        }else{
            pastDate = false
            print("current or future Date.")
        }
        DispatchQueue.global(qos: .background).async {
            let nDate = TimeManager.FormatDateString(strDate: String(describing:date), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
            if self.selected_employeeid != nil {
                utilityMgr.showIndicator()
                DispatchQueue.global(qos: .userInitiated).async {
                    let link = UrlConstants.BASE_URL+UrlConstants.get_DayScheduleOfCarer+self.selected_employeeid!+"/\(nDate)"
                    print(link)
                    self.webserviceCall(link: link)
                }
            }
        }
    }
    // MARK:- Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == tblStaff ? staffArray.count : scheduleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblSchedule {
            let cell : ScheduleCell! = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell") as! ScheduleCell!
            cell.lblname.text = scheduleArray[indexPath.row].employee_name
            cell.lblStarttime.text = scheduleArray[indexPath.row].start_datetime
            cell.lblEndtime.text = scheduleArray[indexPath.row].client_name
            cell.btnChangeSchedule.setTitle(scheduleArray[indexPath.row].status! == "0" ? "To do" : "Done", for: .normal)
            return cell
        } else {
            var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
            }
            cell?.textLabel?.text = staffArray[indexPath.row].employee_name
            cell?.textLabel?.font = UIFont(name: APP_FONT, size: 15.0)
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed(String(describing: "ScheduleHeader"), owner: self, options: nil)?[0] as! UIView
        let clientName = header.viewWithTag(100) as! UILabel
        clientName.text = "Staff Name"
        let time = header.viewWithTag(101) as! UILabel
        time.text = "Time"
        let name = header.viewWithTag(102) as! UILabel
        name.text = "Client Name"
        if ScreenSize.SCREEN_WIDTH <= 320 {
            clientName.text = "Staff\nName"
            name.text = "Client\nName"
        }
        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == tblSchedule ? ScreenSize.SCREEN_WIDTH <= 320 ? 60 : 40 : .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == tblSchedule ? 80 : 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tblStaff {
            tableView.isHidden = true
            btnStaffMember.setTitle(self.staffArray[indexPath.row].employee_name, for: .normal)
            selected_employeeid = staffArray[indexPath.row].employeeid
            DispatchQueue.global(qos: .userInitiated).async {
                let link = UrlConstants.BASE_URL+UrlConstants.get_DayScheduleOfCarer+self.staffArray[indexPath.row].employeeid!+"/\(TimeManager.FormatDateString(strDate: String(describing:self.calendarView.selectedDate!), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd"))"
                self.webserviceCall(link: link)
            }
        }
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tblStaff {
            if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
                pageNo += 1
                getStaffMembers()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- IBActions
    @IBAction func selectStaffMember(_ sender: UIButton) {
        tblStaff.isHidden = !tblStaff.isHidden
    }
    @IBAction func addSchedulePressed(_ sender: UIButton) {
        if pastDate{
            self.kAlertView(title: APPNAME, message: Constants.Register.CAN_NOT_CREATE_EVENT)
        }else{
            let vc = managerStoryBoard.instantiateViewController(withIdentifier: "AddScheduleVC") as! AddScheduleVC
            vc.previousSelectedDate = calendarView.selectedDate ?? Date()
            self.pushview(objtype: vc)
        }
    }
    @IBAction func leftbarAction () {
        self.popView()
    }

}
