//
//  AccessRightsVC.swift
//  Medication
//
//  Created by Techwin Labs on 5/11/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class AccessRightsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tblSupervisors: UITableView!
    @IBOutlet weak var btnMedication: UIButton!
    @IBOutlet weak var btnScheduling: UIButton!
    @IBOutlet weak var btnUserCreation: UIButton!
    @IBOutlet weak var btnProfileCreation: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var supervisor_tableHeight: NSLayoutConstraint!
    @IBOutlet weak var baseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var secondTbl: UITableView!
    @IBOutlet weak var secondTblHeight: NSLayoutConstraint!
    
    private var supervisorArray : [Employee] = [Employee]()
    private var empSavedA = NSMutableArray()
    private var accessSavedA = NSMutableArray()
    private var assignedAccess = [String]()
    private var supervisor_Id = ""
    
    // MARK:- View life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Access Rights", controller: self, isReveal : true)
        btnSubmit.putShadow()
        supervisor_tableHeight.constant = 0
        self.baseViewHeight.constant = 50
        self.secondTblHeight.constant = 0
//        DispatchQueue.global(qos: .background).async {
//            pageNo = 1
//            utilityMgr.showIndicator()
//            let link = UrlConstants.BASE_URL+UrlConstants.get_UserByUserTypes+"3/\(pageNo)"
//            self.webserviceCall(param: nil, link: link)
//        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if assignedAccess.count == 0{
            enableAccessBtns(bool: false)
        }
    }
    //MARK:- Enable/Disable Access Btns
    private func enableAccessBtns(bool:Bool){
        btnScheduling.isUserInteractionEnabled = bool
        btnMedication.isUserInteractionEnabled = bool
        btnUserCreation.isUserInteractionEnabled = bool
        btnProfileCreation.isUserInteractionEnabled = bool
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "update_section_access"{
                    DispatchQueue.main.async {
                        let link = UrlConstants.BASE_URL+UrlConstants.supervisor_Access+"/"+self.supervisor_Id
                        self.webserviceCall(param: nil, link: link)
                        self.kAlertView(title: APPNAME, message: response["message"] as! String)
                        
                    }
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
                if methodName == "get_UserByUserTypes" {
                    self.supervisor_tableHeight.constant = 100
                    self.baseViewHeight.constant = 150
                    let dataA = response["data"] as! NSArray
                    self.supervisorArray.removeAll()
                    for i in 0..<dataA.count{
                        let dict = dataA[i] as! NSDictionary
                        let cli = Employee()
                        cli.company_id = dict["company_id"] as? String
                        cli.designation = dict["designation"] as? String
                        cli.employee_country_code = dict["employee_country_code"] as? String
                        cli.employee_designation = dict["employee_designation"] as? String
                        cli.employee_email = dict["employee_email"] as? String
                        cli.employee_mobile = dict["employee_mobile"] as? String
                        cli.employee_name = dict["employee_name"] as? String
                        cli.employee_number = dict["employee_number"] as? String
                        cli.employee_picture = dict["employee_picture"] as? String
                        cli.employee_type = dict["employee_type"] as? String
                        cli.employeeid = dict["employeeid"] as? String
                        self.supervisorArray.append(cli)
                    }
                    DispatchQueue.main.async {
                        self.tblSupervisors.reloadData()
                    }
                }else if methodName == "get_section_accesses"{
                    if let sectionRole = response["access"] as? [String:Any]{
                        let str = sectionRole["section_roles"] as? String
                        if let strng = str{
                            let strArray = strng.components(separatedBy: ",")
                            print(strArray)
                            if strArray.count > 0{
                                self.assignedAccess.removeAll()
                                self.enableAccessBtns(bool: true)
                                for i in 0..<strArray.count{
                                    if strArray[i] != ""{
                                        self.assignedAccess.append(strArray[i])
                                    }
                                }
                                self.setSecondTblHeight(count: strArray.count)
                                self.secondTbl.reloadData()
                            }
                            self.chkValues(passArray: strArray)
                        }
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print("Error ....")
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    //MARK:- function to add checkBox on buttons as per Api response data
    func chkValues(passArray: [String]){
        removeCheckboxImages()
        for value in 0...passArray.count-1{
            print("Array item at index\(value) is \(passArray[value])")
            switch passArray[value]{
            case "1":
               btnMedication.setImage(#imageLiteral(resourceName: "check-box"), for: .normal)
            case "2":
                  btnScheduling.setImage(#imageLiteral(resourceName: "check-box"), for: .normal)
            case "3":
                  btnUserCreation.setImage(#imageLiteral(resourceName: "check-box"), for: .normal)
            case "4":
                  btnProfileCreation.setImage(#imageLiteral(resourceName: "check-box"), for: .normal)
            default:
                print("Nothing..")
            }
        }
    }
 
    private func setSecondTblHeight(count:Int){
        switch count {
        case 1:
            self.secondTblHeight.constant = 30
        case 2:
            self.secondTblHeight.constant = 60
        case 3:
            self.secondTblHeight.constant = 90
        case 4:
            self.secondTblHeight.constant = 120
        default:
            break
        }
    }
    //MARK:- function to remove checkbox from all buttons
    func removeCheckboxImages(){
        btnMedication.setImage(#imageLiteral(resourceName: "blank-check-box"), for: .normal)
        btnScheduling.setImage(#imageLiteral(resourceName: "blank-check-box"), for: .normal)
        btnUserCreation.setImage(#imageLiteral(resourceName: "blank-check-box"), for: .normal)
        btnProfileCreation.setImage(#imageLiteral(resourceName: "blank-check-box"), for: .normal)
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == secondTbl{
            return assignedAccess.count
        }else{
            return supervisorArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == secondTbl{
            let cell:AccessCell2 = tableView.dequeueReusableCell(withIdentifier: "AccessCell2") as! AccessCell2
            let value = assignedAccess[indexPath.row] as! String
            switch value {
            case "1":
                cell.titleLbl.text = "Access to Medication"
            case "2":
                cell.titleLbl.text = "Access to Scheduling"
            case "3":
                cell.titleLbl.text = "Access to User Creation"
            case "4":
                cell.titleLbl.text = "Access to Profile Creation"
            default:
               break
            }
            return cell
        }else{
        let cell:AccessCell! = tableView.dequeueReusableCell(withIdentifier: "AccessCell") as! AccessCell!
//        cell.btnCheckbox.addTarget(self, action: #selector(superVisorSelected(_:)), for: .touchUpInside)
//        cell.btnCheckbox.tag = indexPath.row
        cell.btnName.setTitle(supervisorArray[indexPath.row].employee_name, for: .normal)
        cell.btnName.isEnabled = false
//        cell.btnView.tag = indexPath.row
//        cell.btnView.titleLabel?.textColor = APP_COLOR_BLUE
//        cell.btnView.addTarget(self, action: #selector(viewButtonClicked(_:)), for: .touchUpInside)
        return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        supervisor_tableHeight.constant = 0
        self.baseViewHeight.constant = 50
        titleLbl.text = supervisorArray[indexPath.row].employee_name
        if supervisorArray[indexPath.row].employeeid != nil{
            print(supervisorArray[indexPath.row].employeeid)
            let supervisor_id = supervisorArray[indexPath.row].employeeid
            self.supervisor_Id = supervisor_id!
            empSavedA.removeAllObjects()
            empSavedA.add(supervisorArray[indexPath.row].employeeid!)
//            if empSavedA.contains(supervisorArray[indexPath.row].employeeid!) {
//                empSavedA.remove(supervisorArray[indexPath.row].employeeid!)
//            } else {
//                empSavedA.add(supervisorArray[indexPath.row].employeeid!)
//            }
            let link = UrlConstants.BASE_URL+UrlConstants.supervisor_Access+"/"+supervisor_id!
            self.webserviceCall(param: nil, link: link)
        }
        print(empSavedA)
        print(empSavedA.count)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == secondTbl {
            return 30
        }else{
             return 44
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- IBActions
    @IBAction func accessSelected(_ sender: UIButton) {
        sender.setImage(sender.currentImage == #imageLiteral(resourceName: "blank-check-box") ? #imageLiteral(resourceName: "check-box") : #imageLiteral(resourceName: "blank-check-box"), for: .normal)
    }
    @IBAction func submit(_ sender: UIButton) {
        print(empSavedA)
        if empSavedA.count == 0 || (btnMedication.currentImage == #imageLiteral(resourceName: "blank-check-box") && btnScheduling.currentImage == #imageLiteral(resourceName: "blank-check-box") && btnUserCreation.currentImage == #imageLiteral(resourceName: "blank-check-box") && btnProfileCreation.currentImage == #imageLiteral(resourceName: "blank-check-box")) {
//            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
            let employess = empSavedA.componentsJoined(by: ",")
            print(employess)
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                self.webserviceCall(param: ["employess":employess,"accesses":""], link: UrlConstants.BASE_URL+UrlConstants.update_section_access)
            }
        } else {
            let employess = empSavedA.componentsJoined(by: ",")
            print(employess)
            let a = NSMutableArray()
            if btnMedication.currentImage == #imageLiteral(resourceName: "check-box") {
                a.add(1)
            }
            if btnScheduling.currentImage == #imageLiteral(resourceName: "check-box") {
                a.add(2)
            }
            if btnUserCreation.currentImage == #imageLiteral(resourceName: "check-box") {
                a.add(3)
            }
            if btnProfileCreation.currentImage == #imageLiteral(resourceName: "check-box") {
                a.add(4)
            }
            let accesses = a.componentsJoined(by: ",")
            print(accesses)
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                self.webserviceCall(param: ["employess":employess,"accesses":accesses], link: UrlConstants.BASE_URL+UrlConstants.update_section_access)
            }
        }
    }
    @IBAction func superVisorSelected (_ sender: UIButton) {
        sender.setImage(sender.currentImage == #imageLiteral(resourceName: "blank-check-box") ? #imageLiteral(resourceName: "check-box") : #imageLiteral(resourceName: "blank-check-box"), for: .normal)
        if empSavedA.contains(supervisorArray[sender.tag].employeeid!) {
            empSavedA.remove(supervisorArray[sender.tag].employeeid!)
        } else {
            empSavedA.add(supervisorArray[sender.tag].employeeid!)
        }
    }
    @IBAction func viewButtonClicked (_ sender: UIButton){
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell:AccessCell = tblSupervisors.cellForRow(at: indexPath) as! AccessCell
        cell.btnCheckbox.setImage(#imageLiteral(resourceName: "check-box"), for: .normal)
        
        print("View button tag..\(sender.tag)")
        if supervisorArray[sender.tag].employeeid != nil{
            let supervisor_id = supervisorArray[sender.tag].employeeid
            print("supervisor_id..\(String(describing: supervisor_id))")
            if empSavedA.contains(supervisorArray[sender.tag].employeeid!) {
                empSavedA.remove(supervisorArray[sender.tag].employeeid!)
            } else {
                empSavedA.add(supervisorArray[sender.tag].employeeid!)
            }
            let link = UrlConstants.BASE_URL+UrlConstants.supervisor_Access+"/"+supervisor_id!
            self.webserviceCall(param: nil, link: link)
        }
    }
    
    @IBAction func showSupervisorList(_ sender: UIButton) {
                    pageNo = 1
                    utilityMgr.showIndicator()
                    let link = UrlConstants.BASE_URL+UrlConstants.get_UserByUserTypes+"3/\(pageNo)"
                    self.webserviceCall(param: nil, link: link)
    }
    
}
