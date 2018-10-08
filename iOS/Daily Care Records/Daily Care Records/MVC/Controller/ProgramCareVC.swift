//
//  ProgramCareVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/6/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ProgramCareVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblProgram: UITableView!
    var client_id = ""
    private var client = Client()
    private var selectedSegment = 0
    var isManager = false
    @IBOutlet weak var addPocView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var lblPocTitle: UILabel!
    @IBOutlet weak var tfMedname: UITextField!
    @IBOutlet weak var tfMedtype: UITextField!
    @IBOutlet weak var tfMedDose: UITextField!
    @IBOutlet weak var tfMedtime: UITextField!
    @IBOutlet weak var tfMeddetail: UITextField!
    @IBOutlet weak var btnMedSubmit: UIButton!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var datePickerPoc: UIDatePicker!
    private var selectedIndexValue = 0
    private var isEdited = false
    private var section0Height:CGFloat = 0.0
    private var cellHeight:CGFloat = 0.0
    var supervisorAccess = true
    var editHide = false
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Program of Care", controller: self, isReveal : false)
        tblProgram.register(UINib.init(nibName: "MedicineCell", bundle: nil), forCellReuseIdentifier: "MedicineCell")
        tblProgram.register(UINib.init(nibName: "MedicineTimeCell", bundle: nil), forCellReuseIdentifier: "MedicineTimeCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //MARK:- check if supervisor has access to add medication
        if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
            print("currentLoginUser..\(user)")
            if user == "3"{
                if let accessTo = UserDefaults.standard.value(forKey: "sectionAccess") as? String{
                    let convertedArray = accessTo.components(separatedBy: ",")
                    if convertedArray.contains("1"){
                        editHide = false
                    }else{
                        editHide = true
                    }
                }
            }
        }
        btnMedSubmit.putShadow()
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.get_ClientCareProgram+self.client_id)
        }
    }
    // MARK:- Server Calls
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_ClientCareProgram" {
                DispatchQueue.main.async {
                    let dict = response["data"] as! NSDictionary
                    self.client.program_id = dict["program_id"] as? String
                    self.client.client_id = dict["client_id"] as? String
                    self.client.program_startdate = dict["program_startdate"] as? String
                    self.client.comments = response["comments"] as? String
                    if self.client.comments != ""{
                        let cell : MedicineTimeCell! = self.tblProgram.dequeueReusableCell(withIdentifier: "MedicineTimeCell") as! MedicineTimeCell!
                        self.section0Height = (self.client.comments?.stringHeight(with: cell.txtViewInstruction.frame.width, font:  UIFont(name: APP_FONT, size: 14.0)!))!
                    }
                    self.client.am_time_care_program = [Program]()
                    for i in 0..<(dict["am_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.detail = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        self.client.am_time_care_program?.append(program)
                    }
                    self.client.noon_time_care_program = [Program]()
                    for i in 0..<(dict["noon_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.detail = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        self.client.noon_time_care_program?.append(program)
                    }
                    self.client.tea_time_care_program = [Program]()
                    for i in 0..<(dict["tea_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.detail = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        self.client.tea_time_care_program?.append(program)
                    }
                    self.client.night_time_care_program = [Program]()
                    for i in 0..<(dict["night_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.detail = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        self.client.night_time_care_program?.append(program)
                    }
                    self.tblProgram.delegate = self
                    self.tblProgram.dataSource = self
                    self.tblProgram.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func updateProgramOfCare(_ param:[String:AnyObject]){
        apiMgr.PostApi(param, webserviceURL: UrlConstants.BASE_URL+UrlConstants.update_ClientCareProgram, success: { (response) in
            utilityMgr.hideIndicator()
            DispatchQueue.main.async {
                self.popView()
            }
        }) { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            switch selectedSegment {
            case 0:
                return (client.am_time_care_program?.count)!
            case 1:
                return (client.noon_time_care_program?.count)!
            case 2:
                return (client.tea_time_care_program?.count)!
            case 3:
                return (client.night_time_care_program?.count)!
            default:
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell : MedicineTimeCell! = tableView.dequeueReusableCell(withIdentifier: "MedicineTimeCell") as! MedicineTimeCell!
            cell.viewInstruction.isHidden = false
            cell.viewMed.isHidden = true
            cell.segmentTime.addTarget(self, action: #selector(timeSelected(_:)), for: .valueChanged)
            if client.comments == "" {
                cell.txtViewInstruction.text = "-"
            } else {
                let heightI = self.section0Height//client.comments!.stringHeight(with: cell.txtViewInstruction.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
                print("cell time height.\(heightI)")
                cell.heightInstruction.constant =  heightI + 10
                cell.heightInsView.constant = 30 + cell.heightInstruction.constant  //30
                cell.txtViewInstruction.text = client.comments
            }
            return cell
        } else {
            let cell : MedicineCell! = tableView.dequeueReusableCell(withIdentifier: "MedicineCell") as! MedicineCell!
            switch selectedSegment {
            case 0:
                cell.lblMedname.text = client.am_time_care_program?[indexPath.row].medicine
                cell.lblDos.text = client.am_time_care_program?[indexPath.row].dose
                cell.lblType.text = client.am_time_care_program?[indexPath.row].type
                cell.lblTime.text = client.am_time_care_program?[indexPath.row].time
                if client.am_time_care_program?[indexPath.row].detail == "" {
                    cell.lblDetails.text = "-"
                } else {
                    let heightI = client.am_time_care_program?[indexPath.row].detail!.stringHeight(with: cell.lblDetails.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
                    cell.heightDetails.constant = heightI! + 10
                    cellHeight = heightI! + 10
                    cell.heightViewDetails.constant = 30 + cell.heightDetails.constant
                    cell.lblDetails.text = client.am_time_care_program?[indexPath.row].detail
                }
                return cell
            case 1:
                cell.lblMedname.text = client.noon_time_care_program?[indexPath.row].medicine
                cell.lblDos.text = client.noon_time_care_program?[indexPath.row].dose
                cell.lblType.text = client.noon_time_care_program?[indexPath.row].type
                cell.lblTime.text = client.noon_time_care_program?[indexPath.row].time
                if client.noon_time_care_program?[indexPath.row].detail == "" {
                    cell.lblDetails.text = "-"
                } else {
                    let heightI = client.noon_time_care_program?[indexPath.row].detail!.stringHeight(with: cell.lblDetails.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
                    cell.heightDetails.constant = heightI! + 10
                      cellHeight = heightI! + 10
                    cell.heightViewDetails.constant = 30 + cell.heightDetails.constant
                    cell.lblDetails.text = client.noon_time_care_program?[indexPath.row].detail
                }
                return cell
            case 2:
                cell.lblMedname.text = client.tea_time_care_program?[indexPath.row].medicine
                cell.lblDos.text = client.tea_time_care_program?[indexPath.row].dose
                cell.lblType.text = client.tea_time_care_program?[indexPath.row].type
                cell.lblTime.text = client.tea_time_care_program?[indexPath.row].time
                if client.tea_time_care_program?[indexPath.row].detail == "" {
                    cell.lblDetails.text = "-"
                } else {
                    let heightI = client.tea_time_care_program?[indexPath.row].detail!.stringHeight(with: cell.lblDetails.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
                    cell.heightDetails.constant = heightI! + 10
                      cellHeight = heightI! + 10
                    cell.heightViewDetails.constant = 30 + cell.heightDetails.constant
                    cell.lblDetails.text = client.tea_time_care_program?[indexPath.row].detail
                }
                return cell
            case 3:
                cell.lblMedname.text = client.night_time_care_program?[indexPath.row].medicine
                cell.lblDos.text = client.night_time_care_program?[indexPath.row].dose
                cell.lblType.text = client.night_time_care_program?[indexPath.row].type
                cell.lblTime.text = client.night_time_care_program?[indexPath.row].time
                if client.night_time_care_program?[indexPath.row].detail == "" {
                    cell.lblDetails.text = "----"
                } else {
                    let heightI = client.night_time_care_program?[indexPath.row].detail!.stringHeight(with: cell.lblDetails.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
                    cell.heightDetails.constant = heightI! + 10
                      cellHeight = heightI! + 10
                    cell.heightViewDetails.constant = 30 + cell.heightDetails.constant
                    cell.lblDetails.text = client.night_time_care_program?[indexPath.row].detail
                }
                return cell
            default:
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if client.comments == "" {
                return 130
            } else {
                let heightI = (client.comments?.stringHeight(with: ScreenSize.SCREEN_WIDTH-20, font: UIFont(name: APP_FONT, size: 14.0)!))! + 130 //90
                print("segment section height.\(heightI)")
                return heightI //+30
            }
        } else {
            switch selectedSegment {
            case 0:
                if client.am_time_care_program?[indexPath.row].detail == "" {
                    return 150 //108
                } else {
//                    let heightI = (client.am_time_care_program?[indexPath.row].detail?.stringHeight(with: ScreenSize.SCREEN_WIDTH-20, font: UIFont(name: APP_FONT, size: 14.0)!))! + 150 //80
//                    return heightI
                         return 150 + cellHeight
                }
            case 1:
                if client.noon_time_care_program?[indexPath.row].detail == "" {
                    return 150
                } else {
//                    let heightI = (client.noon_time_care_program?[indexPath.row].detail?.stringHeight(with: ScreenSize.SCREEN_WIDTH-20, font: UIFont(name: APP_FONT, size: 14.0)!))! + 150 //80
//                    return heightI
                        return 150 + cellHeight
                }
            case 2:
                if client.tea_time_care_program?[indexPath.row].detail == "" {
                    return 150
                } else {
//                    let heightI = (client.tea_time_care_program?[indexPath.row].detail?.stringHeight(with: ScreenSize.SCREEN_WIDTH-20, font: UIFont(name: APP_FONT, size: 14.0)!))! + 150 //80
//                    return heightI
                       return 150 + cellHeight
                }
            case 3:
                if client.night_time_care_program?[indexPath.row].detail == "" {
                    return 150
                } else {
//                    let heightI = (client.night_time_care_program?[indexPath.row].detail?.stringHeight(with: ScreenSize.SCREEN_WIDTH-20, font: UIFont(name: APP_FONT, size: 14.0)!))! + 150 //80
//                    return heightI
                         return 150 + cellHeight
                }
            default:
                return 0
            }
        }
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            return nil
//        } else {
//            let header = Bundle.main.loadNibNamed(String(describing: "ProgramCareHeader"), owner: self, options: nil)?[0] as! UIView
//            return header
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return section == 0 ? .leastNormalMagnitude : 55
//    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return isManager && indexPath.section == 1
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if !editHide{
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            tableView.setEditing(false, animated: true)
            self.selectedIndexValue = editActionsForRowAt.row
            self.addPocView.isHidden = false
            self.prefillPocValues()
        }
        edit.backgroundColor = APP_COLOR_BLUE
        let del = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            tableView.setEditing(false, animated: true)
            self.isEdited = true
            switch self.selectedSegment{
            case 0:
                print("am")
                DispatchQueue.main.async {
                    self.client.am_time_care_program?.remove(at: editActionsForRowAt.row)
                    self.tblProgram.beginUpdates()
                    self.tblProgram.deleteRows(at: [editActionsForRowAt], with: .fade)
                    self.tblProgram.endUpdates()
                }
            case 1:
                print("noon")
                DispatchQueue.main.async {
                    self.client.noon_time_care_program?.remove(at: editActionsForRowAt.row)
                    self.tblProgram.beginUpdates()
                    self.tblProgram.deleteRows(at: [editActionsForRowAt], with: .fade)
                    self.tblProgram.endUpdates()
                }
            case 2:
                print("pm")
                DispatchQueue.main.async {
                    self.client.tea_time_care_program?.remove(at: editActionsForRowAt.row)
                    self.tblProgram.beginUpdates()
                    self.tblProgram.deleteRows(at: [editActionsForRowAt], with: .fade)
                    self.tblProgram.endUpdates()
                }
            case 3:
                print("night")
                DispatchQueue.main.async {
                    self.client.night_time_care_program?.remove(at: editActionsForRowAt.row)
                    self.tblProgram.beginUpdates()
                    self.tblProgram.deleteRows(at: [editActionsForRowAt], with: .fade)
                    self.tblProgram.endUpdates()
                }
            default:break
            }
        }
        del.backgroundColor = APP_COLOR_GREEN
        return [del,edit]
      }
        return []
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isManager && section == 1 {
            let footer = Bundle.main.loadNibNamed(String(describing: "ProgramOfCareFooter"), owner: self, options: nil)?[0] as! UIView
            let addBtn = footer.viewWithTag(100) as! UIButton
            let submitBtn = footer.viewWithTag(101) as! UIButton
            addBtn.addTarget(self, action: #selector(addPoc(_:)), for: .touchUpInside)
            submitBtn.addTarget(self, action: #selector(submitPoc(_:)), for: .touchUpInside)
            submitBtn.putShadow()
            //MARK:- hide buttons if supervisor has no access to these buttons
            if editHide{
                addBtn.isHidden = true
                submitBtn.isHidden = true
            }else{
                addBtn.isHidden = false
                submitBtn.isHidden = false
            }
            
            return footer
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isManager && section == 1 {
            return 125
        }
        return .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    private func prefillPocValues(){
        // when editing prefill values
        lblPocTitle.text = "Edit Program of Care"
        btnMedSubmit.setTitle("Edit", for: .normal)
        var oldProgram:Program?=Program()
        switch selectedSegment {
        case 0:
            oldProgram = client.am_time_care_program?[selectedIndexValue]
        case 1:
            oldProgram = client.noon_time_care_program?[selectedIndexValue]
        case 2:
            oldProgram = client.tea_time_care_program?[selectedIndexValue]
        case 3:
            oldProgram = client.night_time_care_program?[selectedIndexValue]
        default:
            break
        }
        tfMedname.text = oldProgram?.medicine
        tfMedDose.text = oldProgram?.dose
        tfMedtime.text = oldProgram?.time
        tfMedtype.text = oldProgram?.type
        tfMeddetail.text = oldProgram?.detail
    }
    // MARK:- IBActions
    @IBAction func addPocLocal(_ sender: UIButton) {
        if tfMedname.text == "" || tfMedDose.text == "" || tfMedDose.text == "" || tfMedtime.text == "" || tfMedtype.text == "" || tfMeddetail.text == "" {
           kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
            isEdited = true
            addPocView.isHidden = true
            if sender.currentTitle == "Edit" {
                // replace previous object with new object
                let newProgram = Program()
                newProgram.medicine = tfMedname.text
                newProgram.dose = tfMedDose.text
                newProgram.time = tfMedtime.text
                newProgram.type = tfMedtype.text
                newProgram.detail = tfMeddetail.text
                switch selectedSegment {
                case 0:
                    client.am_time_care_program?[selectedIndexValue] = newProgram
                case 1:
                    client.noon_time_care_program?[selectedIndexValue] = newProgram
                case 2:
                    client.tea_time_care_program?[selectedIndexValue] = newProgram
                case 3:
                    client.night_time_care_program?[selectedIndexValue] = newProgram
                default:
                    break
                }
            } else {
                // add new object
                let newProgram = Program()
                newProgram.medicine = tfMedname.text
                newProgram.dose = tfMedDose.text
                newProgram.time = tfMedtime.text
                newProgram.type = tfMedtype.text
                newProgram.detail = tfMeddetail.text
                switch selectedSegment {
                case 0:
                    client.am_time_care_program?.append(newProgram)
                case 1:
                    client.noon_time_care_program?.append(newProgram)
                case 2:
                    client.tea_time_care_program?.append(newProgram)
                case 3:
                    client.night_time_care_program?.append(newProgram)
                default:
                    break
                }
            }
            tblProgram.reloadData()
        }
    }
    @IBAction func selectTime(_ sender: UIButton) {
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
    }
    @IBAction func addPoc(_ sender: UIButton) {
        lblPocTitle.text = "Add Program of Care"
        btnMedSubmit.setTitle("Add", for: .normal)
        tfMedname.text = ""
        tfMedDose.text = ""
        tfMedtime.text = ""
        tfMedtype.text = ""
        tfMeddetail.text = ""
        addPocView.isHidden = false
    }
    @IBAction func submitPoc (_ sender: UIButton) {
        // update poc
                if isEdited {
    
                    var param = [String:AnyObject]()
                    param["program_id"] = client.program_id! as AnyObject?
                    param["client_id"] = client.client_id! as AnyObject?
                    let am = NSMutableArray()
                    for i in 0..<(client.am_time_care_program?.count)! {
                        let dict = NSMutableDictionary()
                        dict["medicine"] = client.am_time_care_program?[i].medicine
                        dict["dose"] = client.am_time_care_program?[i].dose
                        dict["time"] = client.am_time_care_program?[i].time
                        dict["type"] = client.am_time_care_program?[i].type
                        dict["detail"] = client.am_time_care_program?[i].detail
                        am.add(dict)
                    }
                    let amData = try! JSONSerialization.data(withJSONObject: am, options: [])
                    let aMString = String(data: amData, encoding: .utf8)
                    param["am_time_care_program"] = aMString! as AnyObject?
                    let noon = NSMutableArray()
                    for i in 0..<(client.noon_time_care_program?.count)! {
                        let dict = NSMutableDictionary()
                        dict["medicine"] = client.noon_time_care_program?[i].medicine
                        dict["dose"] = client.noon_time_care_program?[i].dose
                        dict["time"] = client.noon_time_care_program?[i].time
                        dict["type"] = client.noon_time_care_program?[i].type
                        dict["detail"] = client.noon_time_care_program?[i].detail
                        noon.add(dict)
                    }
                    let noonData = try! JSONSerialization.data(withJSONObject: noon, options: [])
                    let noonString = String(data: noonData, encoding: .utf8)
                    param["noon_time_care_program"] = noonString! as AnyObject?
                    let tea = NSMutableArray()
                    for i in 0..<(client.tea_time_care_program?.count)! {
                        let dict = NSMutableDictionary()
                        dict["medicine"] = client.tea_time_care_program?[i].medicine
                        dict["dose"] = client.tea_time_care_program?[i].dose
                        dict["time"] = client.tea_time_care_program?[i].time
                        dict["type"] = client.tea_time_care_program?[i].type
                        dict["detail"] = client.tea_time_care_program?[i].detail
                        tea.add(dict)
                    }
                    let teaData = try! JSONSerialization.data(withJSONObject: tea, options: [])
                    let teaString = String(data: teaData, encoding: .utf8)
                    param["tea_time_care_program"] = teaString! as AnyObject?
                    let night = NSMutableArray()
                    for i in 0..<(client.night_time_care_program?.count)! {
                        let dict = NSMutableDictionary()
                        dict["medicine"] = client.night_time_care_program?[i].medicine
                        dict["dose"] = client.night_time_care_program?[i].dose
                        dict["time"] = client.night_time_care_program?[i].time
                        dict["type"] = client.night_time_care_program?[i].type
                        dict["detail"] = client.night_time_care_program?[i].detail
                        night.add(dict)
                    }
                    let nightData = try! JSONSerialization.data(withJSONObject: night, options: [])
                    let nightString = String(data: nightData, encoding: .utf8)
                    param["night_time_care_program"] = nightString! as AnyObject?
                    DispatchQueue.global(qos: .background).async {
                        utilityMgr.showIndicator()
                        DispatchQueue.main.async {
                             sender.isEnabled = false
                        }
                        print("programOfCare Parameters..\(param)")
                        self.updateProgramOfCare(param)
                    }
                }
        }
    @IBAction func leftbarAction () {
        utilityMgr.hideIndicator()
        self.popView()
    }
    @IBAction func timeSelected(_ sender:UISegmentedControl){
        selectedSegment = sender.selectedSegmentIndex
        tblProgram.reloadData()
    }
    @IBAction func closeView(_ sender: UIButton) {
        addPocView.isHidden = true
    }
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if sender.tag == 101 {
            tfMedtime.text = TimeManager.FormatDateString(strDate: String(describing:datePickerPoc.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm")
        }
    }

}
