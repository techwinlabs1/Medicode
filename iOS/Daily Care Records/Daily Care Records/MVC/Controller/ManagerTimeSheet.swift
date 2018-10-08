//
//  ManagerTimeSheet.swift
//  Medication
//
//  Created by Techwin Labs on 4/27/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ManagerTimeSheet: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tblStaff: UITableView!
    @IBOutlet weak var tblTimeSheet: UITableView!
    @IBOutlet weak var tblStaffHeight: NSLayoutConstraint!
    
    private var timeSheetArray:[TimeSheet]=[TimeSheet]()
    private var expandedSection : Int?
    private var expandedScheduleArray:[Schedule]=[Schedule]()
    private var staffArray:[Employee]=[Employee]()
    private var selected_employeeid : String?
    @IBOutlet weak var btnStaffMember: MButton!
    private var heightForRow:CGFloat = 0.0
    
    // MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Time Sheet", controller: self, isReveal : true)
        tblTimeSheet.register(UINib.init(nibName: "TimeSheetCell", bundle: nil), forCellReuseIdentifier: "TimeSheetCell")
        getStaffMembers()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tblTimeSheet.isHidden = true
        tblStaffHeight.constant = 0
        tblStaff.layer.borderColor = UIColor.lightGray.cgColor
        tblStaff.layer.borderWidth = 1
    }
    // MARK:- Server calls
    private func getStaffMembers(){
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_UserByUserTypes+"1/1"
            self.webserviceCall(link: link)
        }
    }
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_UserByUserTypes" {
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
            } else if methodName == "get_TimeSheetRecords" {
                DispatchQueue.main.async {
                    if pageNo == 1 {
                        self.timeSheetArray.removeAll()
                    }
                    for i in 0..<(response["data"] as! NSArray).count{
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let t = TimeSheet()
                        t.date = dict["date"] as? String
                        print(dict["date"] as? String)
                        t.employee_name = dict["dict"] as? String
                        t.employee_number = dict["employee_number"] as? String
                        t.schedule = [Schedule]()
                        t.workedhours = dict["workedhours"] as? String
                        t.totalhours = dict["totalhours"] as? String
                        let sA = dict["schedule"] as! NSArray
                        for j in 0..<sA.count {
                            let newDict = sA[j] as! NSDictionary
                            let s = Schedule()
                            s.client_id = newDict["client_id"] as? String
                            s.client_name = newDict["client_name"] as? String
                            s.employeeid = newDict["employeeid"] as? String
                            s.end_datetime = newDict["end_datetime"] as? String
                            s.minutes = newDict["minutes"] as? String
                            s.schedule_id = newDict["schedule_id"] as? String
                            s.secheduled_by = newDict["secheduled_by"] as? String
                            s.start_datetime = newDict["start_datetime"] as? String
                            s.status = newDict["status"] as? String
                            s.totalhrs = newDict["totalhrs"] as? String
                            t.schedule.append(s)
                        }
                        self.timeSheetArray.append(t)
                    }
                    
                    self.tblTimeSheet.reloadData()
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
        if tableView == tblStaff {
            return 1
        } else {
            return timeSheetArray.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblTimeSheet {
            if expandedSection != nil && expandedSection == section {
                return expandedScheduleArray.count+1
            }
            return 0
        }
        return staffArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblTimeSheet {
            let cell : TimeSheetCell! = tableView.dequeueReusableCell(withIdentifier: "TimeSheetCell") as! TimeSheetCell!
            if indexPath.row == 0{
                cell.lblName.text = "Client"
                cell.lblStart.text = "Start"
                cell.lblEnd.text = "End"
                cell.lblTotal.text = "Total"
                cell.lblName.textColor = UIColor.black
                cell.lblStart.textColor = UIColor.black
                cell.lblEnd.textColor = UIColor.black
                cell.lblTotal.textColor = UIColor.black
                return cell
            }else{
                let indexPath = indexPath.row - 1
                 if ((expandedScheduleArray[indexPath].start_datetime) == "0000-00-00 00:00:00"){
                     cell.lblStart.text = ""
                }else{
                    let startTime = TimeManager.FormatDateString(strDate: expandedScheduleArray[indexPath].start_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")
                    cell.lblStart.text = "\(startTime)" //"Start Time :- \(expandedScheduleArray[indexPath.row].start_datetime!)"
                }
                if ((expandedScheduleArray[indexPath].end_datetime) == "0000-00-00 00:00:00"){
                     cell.lblEnd.text = ""
                }else{
                    let endTime = TimeManager.FormatDateString(strDate: expandedScheduleArray[indexPath].end_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")
                    cell.lblEnd.text = "\(endTime)"
                }
                let name = expandedScheduleArray[indexPath].client_name!
                self.heightForRow = name.stringHeight(with:  cell.lblName.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
                cell.lblName.text = "\(expandedScheduleArray[indexPath].client_name!)"
    
                cell.lblTotal.text = "\(expandedScheduleArray[indexPath].totalhrs!)"
                return cell
            }

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
        if tableView == tblTimeSheet {
            let header = Bundle.main.loadNibNamed(String(describing: "DataUsageHeader"), owner: self, options: nil)?[0] as! UIView
            let supV : UIView = header.viewWithTag(1000)!
            let img = supV.viewWithTag(303) as! UIImageView
            img.image = UIImage(named: "time-sheet")
            let dateLbl = supV.viewWithTag(100) as! UILabel
             let totalTimeLbl = supV.viewWithTag(203) as! UILabel
            totalTimeLbl.isHidden = false
            let date = timeSheetArray[section].date!
            if date == "0000-00-00"{
                dateLbl.text = ""
            }else{
                 dateLbl.text =  TimeManager.FormatDateString(strDate: timeSheetArray[section].date!, fromFormat: "yyyy-MM-dd", toFormat: "dd-MM-yyyy")//timeSheetArray[section].date
            }
            let actualData =  timeSheetArray[section].totalhours! //timeSheetArray[section].workedhours! + "/" +
            let actualDataLbl = supV.viewWithTag(103) as! UILabel
            actualDataLbl.isHidden = false
            let p1 = supV.viewWithTag(101) as! UILabel
            let p2 = supV.viewWithTag(104) as! UILabel
            p1.isHidden = true
            p2.isHidden = true
            actualDataLbl.text = actualData
            let tapG : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
            tapG.numberOfTapsRequired = 1
            header.tag = section
            header.addGestureRecognizer(tapG)
            return header
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTimeSheet {
            return 70
        }
        return .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblStaff {
            return 44
        }
        if indexPath.row == 0{
            return 30
        }else{
            return 10+heightForRow//135
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pageNo = 1
        if tableView == tblStaff {
            tblStaffHeight.constant = 0
            tableView.isHidden = true
            btnStaffMember.setTitle(staffArray[indexPath.row].employee_name, for: .normal)
            selected_employeeid = staffArray[indexPath.row].employeeid
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.get_TimeSheetRecords+"/\(self.selected_employeeid!)"+"/\(pageNo)")
            }
        }
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == tblStaff {
//            if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
//                pageNo += 1
//                getStaffMembers()
//            }
        }else if scrollView == tblTimeSheet{
            if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
                pageNo += 1
                DispatchQueue.global(qos: .userInitiated).async {
                    utilityMgr.showIndicator()
                    self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.get_TimeSheetRecords+"/\(self.selected_employeeid!)"+"/\(pageNo)")
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBActions
    @IBAction func selectStaffMember(_ sender: UIButton) {
         tblTimeSheet.isHidden = false
        tblStaff.isHidden = !tblStaff.isHidden
        (tblStaffHeight.constant == 0) ? (tblStaffHeight.constant = 180) : (tblStaffHeight.constant = 0)
    }
    // MARK:- tap gesture selector
    func headerTapped(_ sender : UITapGestureRecognizer){
        expandedSection = sender.view?.tag
        expandedScheduleArray = timeSheetArray[sender.view!.tag].schedule
        tblTimeSheet.reloadData()
    }

}
