//
//  TimeSheetVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/5/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class TimeSheetVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblTimeSheet: UITableView!
    private var timeSheetArray:[TimeSheet]=[TimeSheet]()
    private var expandedSection : Int?
    private var expandedScheduleArray:[Schedule]=[Schedule]()
    private var heightForRow:CGFloat = 0.0
    
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Time Sheet", controller: self, isReveal : true)
        pageNo = 1
        tblTimeSheet.register(UINib.init(nibName: "TimeSheetCell", bundle: nil), forCellReuseIdentifier: "TimeSheetCell")
        getTimeSheet(page: pageNo)
        // Do any additional setup after loading the view.
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            print(response)
            let methodName = response["method"] as! String
            if methodName == "get_TimeSheetRecords" {
                DispatchQueue.main.async {
                    if pageNo == 1 {
                        self.timeSheetArray.removeAll()
                    }
                    for i in 0..<(response["data"] as! NSArray).count{
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let t = TimeSheet()
                        if dict["date"] as? String != "0000-00-00"{
                            t.date = TimeManager.FormatDateString(strDate: (dict["date"] as? String)!, fromFormat: "yyyy-MM-dd", toFormat: "dd-MM-yyyy")//newDict["start_datetime"] as? String
                        }else{
                             t.date = "00:00"
                        }
//                        t.date = dict["date"] as? String
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
                            if newDict["start_datetime"] as? String != "0000-00-00 00:00:00"{
                                 s.start_datetime = TimeManager.FormatDateString(strDate: (newDict["start_datetime"] as? String)!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")//newDict["start_datetime"] as? String
                            }else{
                                s.start_datetime = "00:00"
                            }
                            if newDict["end_datetime"] as? String != "0000-00-00 00:00:00"{
                                s.end_datetime = TimeManager.FormatDateString(strDate: (newDict["end_datetime"] as? String)!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")//newDict["end_datetime"] as? String
                            }else{
                                s.end_datetime = "00:00"
                            }
                            s.minutes = newDict["minutes"] as? String
                            s.schedule_id = newDict["schedule_id"] as? String
                            s.secheduled_by = newDict["secheduled_by"] as? String
                           
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
    private func getTimeSheet(page:Int){
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            self.webserviceCall(param: nil, link: UrlConstants.BASE_URL+UrlConstants.get_TimeSheetRecords+"/\(utilityMgr.getUDVal(forKey: "employeeid")!)"+"/\(pageNo)")
        }
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            pageNo += 1
            getTimeSheet(page:pageNo)
        }
    }
    // MARK:- Tableview delegate and datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return timeSheetArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if expandedSection != nil && expandedSection == section {
            return expandedScheduleArray.count+1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed(String(describing: "DataUsageHeader"), owner: self, options: nil)?[0] as! UIView
        let supV : UIView = header.viewWithTag(1000)!
        let img = supV.viewWithTag(303) as! UIImageView
        img.image = UIImage(named: "time-sheet")
        let dateLbl = supV.viewWithTag(100) as! UILabel
        dateLbl.text = timeSheetArray[section].date
        let actualData = timeSheetArray[section].totalhours! //timeSheetArray[section].workedhours! + "/" + timeSheetArray[section].totalhours!
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            let name = expandedScheduleArray[indexPath.row-1].client_name!
            self.heightForRow = name.stringHeight(with:  cell.lblName.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
            cell.lblName.text = "\(expandedScheduleArray[indexPath.row-1].client_name!)"
            cell.lblStart.text = expandedScheduleArray[indexPath.row-1].start_datetime!//"Start Time :- \(startDate)"
            cell.lblStart.text = expandedScheduleArray[indexPath.row-1].start_datetime!//"Start Time :- \(startDate)"
            cell.lblEnd.text = expandedScheduleArray[indexPath.row-1].end_datetime!//"End Time :- \(endTime)"
            cell.lblTotal.text = "\(expandedScheduleArray[indexPath.row-1].totalhrs!)"
            return cell
        }
//            let startDate = TimeManager.FormatDateString(strDate: expandedScheduleArray[indexPath.row].start_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")
//            let endTime = TimeManager.FormatDateString(strDate: expandedScheduleArray[indexPath.row].end_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")
        
//        cell.lblStatus.text = "Status :- \(expandedScheduleArray[indexPath.row].status! == "0" ? "To do" : "Done")"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 30
        }else{
            return 10+heightForRow
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- tap gesture selector
    func headerTapped(_ sender : UITapGestureRecognizer){
        expandedSection = sender.view?.tag
        expandedScheduleArray = timeSheetArray[sender.view!.tag].schedule
        tblTimeSheet.reloadData()
    }

}
