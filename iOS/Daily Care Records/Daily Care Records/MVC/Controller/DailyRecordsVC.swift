//
//  DailyRecordsVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/9/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class DailyRecordsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var tblRecords: UITableView!
    var client_id = ""
    var postcode = ""
    var client_name = ""
    var height:CGFloat = 0.0
    private var dailyRecordArray : [DailyRecord] = [DailyRecord]()
    @IBOutlet weak var recordDatePicker: UIDatePicker!
    private var selectedTime = ""
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    var btn = UIButton()
    private var tapG:UITapGestureRecognizer!
    
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: appDel.access == 1 ? UIImage(named:"plus-white") : nil,titleText: "Daily Records", controller: self, isReveal : false)
        if utilityMgr.getUDVal(forKey: "employee_type") as! String == "2" {
             utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Daily Records", controller: self, isReveal : false)
        }else{
            utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: appDel.access == 1 ? UIImage(named:"plus-white") : nil,titleText: "Daily Records", controller: self, isReveal : false)
        }
       
        tblRecords.register(UINib.init(nibName: "SelectTimeCell", bundle: nil), forCellReuseIdentifier: "SelectTimeCell")
        tblRecords.register(UINib.init(nibName: "RecordCell", bundle: nil), forCellReuseIdentifier: "RecordCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hidePopUp()
        pageNo = 1
        getDailyRecords(true)
    }
    // MARK:- Server calls
    private func getDailyRecords(_ isIntial:Bool){
        var start = "all"
        var end = "all"
        if !isIntial {
            let cell : SelectTimeCell? = tblRecords.cellForRow(at: IndexPath(row: 0, section: 0)) as! SelectTimeCell?
            if cell != nil {
                start = (cell?.btnFrom.currentTitle!)!
                end = (cell?.btnTo.currentTitle!)!
                print(start)
                print(end)
            }
        }
        DispatchQueue.global(qos: isIntial ? .userInitiated : .background).async {
            utilityMgr.showIndicator()
            if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3") {
                self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.view_DailyRecordsManagerSctionData+"/\(pageNo)/"+"\(start)/\(end)/\(self.client_id)")
            } else {
                self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.view_DailyRecords+"/\(pageNo)/"+"\(start)/\(end)/\(self.client_id)")
            }
        }
    }
    private func webserviceCall(link:String){
        print(link)
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            self.btn.isEnabled = true
            if methodName == "view_DailyRecordsData" {
                if pageNo == 1 {
                    self.dailyRecordArray.removeAll()
                }
                for i in 0..<(response["data"] as! NSArray).count {
                    print(response["data"])
                    let record = DailyRecord()
                    let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                    record.client_id = dict["client_id"] as? String
                    record.postcode = dict["postcode"] as? String
                    record.date = dict["date"] as? String
                    record.employeeid = dict["employeeid"] as? String
                    record.firstname = dict["firstname"] as? String
                    record.lastname = dict["lastname"] as? String
                    record.time = dict["time"] as? String
                    record.employee_name = dict["carer_name"] as? String 
                    record.employee_number = dict["carer_number"] as? String //employee_number
                    record.question_answers = [Question]()
                    for j in 0..<(dict["question_answers"] as! NSArray).count {
                        let ques = Question()
                        ques.answer = ((dict["question_answers"] as! NSArray)[j] as! NSDictionary)["answer"] as? String
                        ques.question = ((dict["question_answers"] as! NSArray)[j] as! NSDictionary)["question"] as? String
                        ques.record_id = ((dict["question_answers"] as! NSArray)[j] as! NSDictionary)["record_id"] as? String
                        record.question_answers?.append(ques)
                    }
                    self.dailyRecordArray.append(record)
                }
                DispatchQueue.main.async {
                    self.tblRecords.reloadData()
                }
            } else if methodName == "view_DailyRecordsManagerSctionData" {
                if pageNo == 1 {
                    self.dailyRecordArray.removeAll()
                }
                for i in 0..<(response["data"] as! NSArray).count {
                    let record = DailyRecord()
                    let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                    record.client_id = dict["client_id"] as? String
                    record.postcode = dict["postcode"] as? String
                    record.date = dict["date"] as? String
                    record.employeeid = dict["employeeid"] as? String
                    record.firstname = dict["firstname"] as? String
                    record.lastname = dict["lastname"] as? String
                    record.time = dict["time"] as? String
                    record.employee_name = dict["employee_name"] as? String
                    record.employee_number = dict["employee_number"] as? String
                    record.question_answers = [Question]()
                    for j in 0..<(dict["question_answers"] as! NSArray).count {
                        let ques = Question()
                        ques.answer = ((dict["question_answers"] as! NSArray)[j] as! NSDictionary)["answer"] as? String
                        ques.question = ((dict["question_answers"] as! NSArray)[j] as! NSDictionary)["question"] as? String
                        ques.record_id = ((dict["question_answers"] as! NSArray)[j] as! NSDictionary)["record_id"] as? String
                        record.question_answers?.append(ques)
                    }
                    self.dailyRecordArray.append(record)
                }
                print(self.dailyRecordArray)
                DispatchQueue.main.async {
                    self.tblRecords.reloadData()
                }
            }else if methodName == "get_staffMemberInfo"{
                if let dict = response["data"] as? [String:Any]{
                    DispatchQueue.main.async {
                        self.nameLbl.text = dict["employee_name"] as? String
                        let url = URL(string: (dict["employee_picture"] as? String)!)
                        self.imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile-placeholder"), options: [], completed: nil)
                        self.showPopUp()
                    }
                }
                
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            pageNo += 1
            getDailyRecords(false)
        }
    }
    // MARK:- Tableview methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : dailyRecordArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell : SelectTimeCell! = tableView.dequeueReusableCell(withIdentifier: "SelectTimeCell") as! SelectTimeCell!
            cell.btnFrom.tag = 100
            cell.btnTo.tag = 101
            cell.btnSubmit.tag = 102  // .....
            self.btn = cell.btnSubmit
            cell.btnFrom.addTarget(self, action: #selector(unhidePicker(_:)), for: .touchUpInside)
            cell.btnTo.addTarget(self, action: #selector(unhidePicker(_:)), for: .touchUpInside)
            cell.btnSubmit.addTarget(self, action: #selector(submitDates(_:)), for: .touchUpInside)
            cell.nameLbl.text = client_name
            cell.nameLbl.textColor = APP_COLOR_BLUE
            return cell
        } else {
            let cell : RecordCell! = tableView.dequeueReusableCell(withIdentifier: "RecordCell") as! RecordCell!
            let date = dailyRecordArray[indexPath.row].date
            cell.lblDate.text = "Date: \(TimeManager.FormatDateString(strDate: date!, fromFormat: "yyyy-MM-dd", toFormat: "dd/MM/yyyy"))"
//           let Id = "Staff Id: \(dailyRecordArray[indexPath.row].client_id!)" //firstname! + " " + dailyRecordArray[indexPath.row].lastname!)" //
//            let attributedText = NSMutableAttributedString(string:dailyRecordArray[indexPath.row].employee_number ?? "")
//            attributedText.addAttribute(NSUnderlineStyleAttributeName , value:1, range: NSMakeRange(0, attributedText.length))
//            let text = NSMutableAttributedString(string: "Staff ID:")
//            let newText:NSMutableAttributedString = NSMutableAttributedString()
//            newText.append(text)
//            newText.append(attributedText)
//            cell.lblName.attributedText =  newText
            cell.lblName.text = "Carer's Name: \(String(describing: dailyRecordArray[indexPath.row].employee_name! ))"
            cell.lblTime.text = "Time: \(TimeManager.FormatDateString(strDate: dailyRecordArray[indexPath.row].time!, fromFormat: "HH:mm:ss", toFormat: "hh:mm a"))"
            let ques = dailyRecordArray[indexPath.row].question_answers
            var ans = ""
            for j in 0..<(ques?.count)! {
                 ans = ans + "" + (ques?[j].answer!)!
                ans.capitalizeFirstLetter()
                let trimmed = ans.trimmingCharacters(in: .whitespacesAndNewlines)
                ans = trimmed
                if ans.last != "."{
                    ans.insert(".", at: ans.endIndex)
                }
//                ans = ans + "" + (ques?[j].answer!)!// + "."
            }
            height = ans.stringHeight(with:  cell!.lblRecord.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
            cell.lblRecord.text = ans
//            cell.nameBtn.tag = indexPath.row
//            cell.nameBtn.addTarget(self, action: #selector(nameBtnPressed(sender:)), for: .touchUpInside)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 135
        } else {
//            let ques = dailyRecordArray[indexPath.row].question_answers
//            var ans = ""
//            for j in 0..<(ques?.count)! {
//                ans = ans + "" + (ques?[j].answer)! + "."
//            }
//            let cell : RecordCell? = tableView.cellForRow(at: indexPath) as! RecordCell?
//            if cell != nil {
//                height = ans.stringHeight(with: cell!.lblRecord.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!) + 10
//            }
//            var height : CGFloat = 80//150
            return height+80
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? .leastNormalMagnitude : 44
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 1 {
//            let header = Bundle.main.loadNibNamed(String(describing: "RecordHeader"), owner: self, options: nil)?[0] as! UIView
//            return header
//        }
        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- IBActions
    @IBAction func leftbarAction () {
        self.popView()
    }
    @IBAction func rightbarAction(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddDailyRecordVC") as! AddDailyRecordVC
        vc.postcode = postcode
        vc.client_id = client_id
        vc.client_name = client_name
        self.pushview(objtype: vc)
    }
    @IBAction func unhidePicker(_ sender:UIButton) {
        selectedTime = sender.tag == 100 ? "from" : "to"
        view.bringSubview(toFront: recordDatePicker)
        dismissKeyboard()
        viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
    }
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if sender.tag == 101 {
            let cell : SelectTimeCell? = tblRecords.cellForRow(at: IndexPath(row: 0, section: 0)) as! SelectTimeCell?
            if cell != nil {
                if selectedTime == "from" {
                    cell?.btnFrom.setTitle(TimeManager.FormatDateString(strDate: String(describing:recordDatePicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"), for: .normal) //yyyy-MM-dd
                } else {
                    cell?.btnTo.setTitle(TimeManager.FormatDateString(strDate: String(describing:recordDatePicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"), for: .normal)
                }
            }
        }
    }
    @IBAction func submitDates(_ sender:UIButton){
         let cell : SelectTimeCell? = tblRecords.cellForRow(at: IndexPath(row: 0, section: 0)) as! SelectTimeCell?
        if (cell?.btnFrom.currentTitle == "dd-mm-yyyy")||(cell?.btnTo.currentTitle == "dd-mm-yyyy"){
          kAlertView(title: APPNAME, message: "Please fill the empty Date field.")
        }else{
            btn.isEnabled = false
            pageNo = 1
            getDailyRecords(false)
        }
    }
    
     // Shows staff detail on clicking on staff_Id.
    @IBAction func nameBtnPressed(sender:UIButton){
//        utilityMgr.showIndicator()
//        let staff_ID = dailyRecordArray[sender.tag].employeeid!
//        webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.get_staffMemberInfo+"\(staff_ID)")
//          showPopUp()
//        nameLbl.text = dailyRecordArray[sender.tag].employee_name
    }
    
    
    //MARK:- ShowPopUpView.
    private func showPopUp(){
        alphaView.isHidden = false
        baseView.isHidden = false
        tapG = UITapGestureRecognizer(target: self, action: #selector(tapPressed(_ :)))
        alphaView.addGestureRecognizer(tapG)
    }
    //MARK:- HidePopUpView.
    private func hidePopUp(){
        if tapG != nil{
            alphaView.removeGestureRecognizer(tapG)
        }
        alphaView.isHidden = true
        baseView.isHidden = true
    }
    //MARK:- TapPressed Action.
    func tapPressed(_ sender:UITapGestureRecognizer){
        hidePopUp()
    }
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
