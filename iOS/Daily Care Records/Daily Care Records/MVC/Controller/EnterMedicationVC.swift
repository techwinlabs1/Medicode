//
//  EnterMedicationVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/9/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class EnterMedicationVC: UIViewController , UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tblMedication: UITableView!
    var client_id = ""
    var titleName = ""
    private var client = Client()
    private var selectedSegment = 0
    private var resultDict = NSDictionary()
    private var cellHeight:CGFloat = 0.0
    private var messageHeight:CGFloat = 0.0
    // MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Medication Chart", controller: self, isReveal : false)
        tblMedication.register(UINib.init(nibName: "MedicineTimeCell", bundle: nil), forCellReuseIdentifier: "MedicineTimeCell")
        tblMedication.register(UINib.init(nibName: "CompletedMedicationCell", bundle: nil), forCellReuseIdentifier: "CompletedMedicationCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
      
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.get_ClientCareProgram+self.client_id)
        }
    }
    
    // MARK:- Server Calls
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            print(response)
            let methodName = response["method"] as! String
            if methodName == "get_ClientCareProgram" {
                DispatchQueue.main.async {
                    let dict = response["data"] as! NSDictionary
                    self.resultDict = dict
                    self.client.program_id = dict["program_id"] as? String
                    self.client.client_id = dict["client_id"] as? String
                    self.client.program_startdate = dict["program_startdate"] as? String
                    self.client.comments = response["comments"] as? String
                    self.client.am_time_care_program = [Program]()
                    self.client.completed_programs = [Program]()
                    self.client.completed_am_time_program = [Program]()
                    for i in 0..<(dict["am_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.timeGiven = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
                        program.detail = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        program.message = ((dict["am_time_care_program"] as! NSArray)[i] as AnyObject)["message"] as? String
                        if program.status == "0" {
                            self.client.am_time_care_program?.append(program)
                        } else {
                            // separate array for completed programs
//                            self.client.completed_programs?.append(program)
                            self.client.completed_am_time_program?.append(program)
                            
                        }
                    }
                    self.client.noon_time_care_program = [Program]()
                    self.client.completed_noon_time_program = [Program]()

                    for i in 0..<(dict["noon_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.timeGiven = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
                        program.detail = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        program.message = ((dict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["message"] as? String
//                        self.client.noon_time_care_program?.append(program)
                        if program.status == "0" {
                            self.client.noon_time_care_program?.append(program)
                        } else {
                            self.client.completed_noon_time_program?.append(program)
                        }
                    }
                    self.client.tea_time_care_program = [Program]()
                    self.client.completed_tea_time_program = [Program]()
                    for i in 0..<(dict["tea_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.timeGiven = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
                        program.detail = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        program.message = ((dict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["message"] as? String
//                        self.client.tea_time_care_program?.append(program)
                        if program.status == "0" {
                            self.client.tea_time_care_program?.append(program)
                        } else {
                            self.client.completed_tea_time_program?.append(program)
                        }
                    }
                    self.client.night_time_care_program = [Program]()
                    self.client.completed_night_time_program = [Program]()

                    for i in 0..<(dict["night_time_care_program"] as! NSArray).count {
                        let program = Program()
                        program.medicine = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
                        program.dose = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
                        program.time = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
                        program.type = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
                        program.timeGiven = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
                        program.detail = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
                        program.status = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
                        program.message = ((dict["night_time_care_program"] as! NSArray)[i] as AnyObject)["message"] as? String
//                        self.client.night_time_care_program?.append(program)
                        if program.status == "0" {
                            self.client.night_time_care_program?.append(program)
                        } else {
                            self.client.completed_night_time_program?.append(program)
                        }
                    }
                    self.tblMedication.delegate = self
                    self.tblMedication.dataSource = self
                    self.tblMedication.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    // MARK: - Table view methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
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
        } else {
              switch selectedSegment {
            case 0:
                let count = client.completed_am_time_program?.count
                if count != nil{
                     return (client.completed_am_time_program?.count)!
                }else{
                    return 0
                }
            case 1:
                let count = client.completed_noon_time_program?.count
                if count != nil{
                    return (client.completed_noon_time_program?.count)!
                }else{
                    return 0
                }
//            return (client.completed_noon_time_program?.count)!
            case 2:
                let count = client.completed_tea_time_program?.count
                if count != nil{
                    return (client.completed_tea_time_program?.count)!
                }else{
                    return 0
                }
//            return (client.completed_tea_time_program?.count)!
            case 3:
                let count = client.completed_night_time_program?.count
                if count != nil{
                    return (client.completed_night_time_program?.count)!
                }else{
                    return 0
                }
//            return (client.completed_night_time_program?.count)!
            default:
            return 0
        }
//            return (client.completed_programs?.count)!
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell : MedicineTimeCell! = tableView.dequeueReusableCell(withIdentifier: "MedicineTimeCell") as! MedicineTimeCell!
            cell.viewInstruction.isHidden = true
            cell.viewMed.isHidden = false
            cell.nameLabel.text = titleName
            cell.segmentTime.addTarget(self, action: #selector(timeSelected(_:)), for: .valueChanged)
            cell.lblDate.text = TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy") //yyyy-MM-dd
            switch selectedSegment {
            case 0:
                cell.lblMedCount.text = "\(client.am_time_care_program!.count)"
            case 1:
                cell.lblMedCount.text = "\(client.noon_time_care_program!.count)"
            case 2:
                cell.lblMedCount.text = "\(client.tea_time_care_program!.count)"
            case 3:
                cell.lblMedCount.text = "\(client.night_time_care_program!.count)"
            default:
                break
            }
            return cell
        } else if indexPath.section == 1 {
//            var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
//            if cell == nil {
//                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//                cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//            }
            let cell : CompletedMedicationCell! = tableView.dequeueReusableCell(withIdentifier: "CompletedMedicationCell") as! CompletedMedicationCell!
            cell.noteTextLbl.isHidden = true
            cell.noteHeaderLbl.isHidden = true
            switch selectedSegment {
            case 0:
//               cell?.textLabel?.text = client.am_time_care_program?[indexPath.row].medicine
                cell.lblMedname.text = client.am_time_care_program?[indexPath.row].medicine
                cell.lblType.text = client.am_time_care_program?[indexPath.row].type
                cell.dose.text = client.am_time_care_program?[indexPath.row].dose
                cell.statusTitle.text = "Time:"
                cell.lblStatus.text = client.am_time_care_program?[indexPath.row].time
                cell.detailTitle.text = "Details:"
                if let detail = client.am_time_care_program?[indexPath.row].detail{
                    cellHeight = detail.stringHeight(with: cell.detailLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
                }
                cell.detailLbl.text = client.am_time_care_program?[indexPath.row].detail
            case 1:
//                cell?.textLabel?.text = client.noon_time_care_program?[indexPath.row].medicine
                cell.lblMedname.text = client.noon_time_care_program?[indexPath.row].medicine
                cell.lblType.text = client.noon_time_care_program?[indexPath.row].type
                cell.dose.text = client.noon_time_care_program?[indexPath.row].dose
                cell.statusTitle.text = "Time:"
                cell.lblStatus.text = client.noon_time_care_program?[indexPath.row].time
                cell.detailTitle.text = "Details:"
                if let detail = client.noon_time_care_program?[indexPath.row].detail{
                    cellHeight = detail.stringHeight(with: cell.detailLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
                }
                cell.detailLbl.text = client.noon_time_care_program?[indexPath.row].detail
            case 2:
//                cell?.textLabel?.text = client.tea_time_care_program?[indexPath.row].medicine
                cell.lblMedname.text = client.tea_time_care_program?[indexPath.row].medicine
                cell.lblType.text = client.tea_time_care_program?[indexPath.row].type
                cell.dose.text = client.tea_time_care_program?[indexPath.row].dose
                cell.statusTitle.text = "Time:"
                cell.lblStatus.text = client.tea_time_care_program?[indexPath.row].time
                cell.detailTitle.text = "Details:"
                if let detail = client.tea_time_care_program?[indexPath.row].detail{
                    cellHeight = detail.stringHeight(with: cell.detailLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
                }
                cell.detailLbl.text = client.tea_time_care_program?[indexPath.row].detail
            case 3:
//                cell?.textLabel?.text = client.night_time_care_program?[indexPath.row].medicine
                cell.lblMedname.text = client.night_time_care_program?[indexPath.row].medicine
                cell.lblType.text = client.night_time_care_program?[indexPath.row].type
                cell.dose.text = client.night_time_care_program?[indexPath.row].dose
                cell.statusTitle.text = "Time:"
                cell.lblStatus.text = client.night_time_care_program?[indexPath.row].time
                cell.detailTitle.text = "Details:"
                if let detail = client.night_time_care_program?[indexPath.row].detail{
                    cellHeight = detail.stringHeight(with: cell.detailLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!)
                }
                cell.detailLbl.text = client.night_time_care_program?[indexPath.row].detail

            default:
                break
            }
//            let sep = UILabel(frame: CGRect(x: 0, y: 44, width: ScreenSize.SCREEN_WIDTH, height: 1))
//            sep.backgroundColor = UIColor(red: 242/255, green: 241/255, blue: 240/255, alpha: 1)
//            cell?.accessoryType = .disclosureIndicator
//            cell?.addSubview(sep)
            return cell!
        } else {
            let cell : CompletedMedicationCell! = tableView.dequeueReusableCell(withIdentifier: "CompletedMedicationCell") as! CompletedMedicationCell!
            cell.noteTextLbl.isHidden = false
            cell.noteHeaderLbl.isHidden = false
            completed_Medication(cell: cell, indexPath: indexPath)
//            cell.lblMedname.text = client.completed_programs?[indexPath.row].medicine
//            cell.lblType.text = client.completed_programs?[indexPath.row].type
//            cell.dose.text = client.completed_programs?[indexPath.row].dose
//            cell.detailTitle.text = "TimeGiven:"
//            cell.detailLbl.text = client.completed_programs?[indexPath.row].timeGiven
//            cell.statusTitle.text = "Status:"
//            switch client.completed_programs![indexPath.row].status! {
//            case "1":
//                cell.lblStatus.text = "Administer"
//            case "2":
//                cell.lblStatus.text = "Prepared"
//            case "3":
//                cell.lblStatus.text = "prompt"
//            case "4":
//                cell.lblStatus.text = "Other"
//            default:
//                break
//            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 130
        } else if indexPath.section == 1 {
            return 162 + cellHeight //45
        } else {
            return 165 + messageHeight//85
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? "Completed Medication" : nil
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? 44 : .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MedicationStatusVC") as! MedicationStatusVC
            vc.client = client
            vc.care_time = selectedSegment + 1
            vc.title_name = titleName
            switch selectedSegment {
            case 0:
                vc.program = (client.am_time_care_program?[indexPath.row])!
            case 1:
                vc.program = (client.noon_time_care_program?[indexPath.row])!
            case 2:
                vc.program = (client.tea_time_care_program?[indexPath.row])!
            case 3:
                vc.program = (client.night_time_care_program?[indexPath.row])!
            default:
                break
            }
            self.pushview(objtype: vc)
        }
    }
    
    private func completed_Medication(cell: CompletedMedicationCell, indexPath:IndexPath){
        switch selectedSegment {
        case 0:
            cell.lblMedname.text = client.completed_am_time_program?[indexPath.row].medicine
            cell.lblType.text = client.completed_am_time_program?[indexPath.row].type
            cell.dose.text = client.completed_am_time_program?[indexPath.row].dose
            cell.detailTitle.text = "TimeGiven:"
            cell.detailLbl.text = client.completed_am_time_program?[indexPath.row].timeGiven
            cell.statusTitle.text = "Status:"
            cell.noteTextLbl.text = client.completed_am_time_program?[indexPath.row].message
            let note = client.completed_am_time_program?[indexPath.row].message
            messageHeight = (note?.stringHeight(with: cell.noteTextLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!))!
            switch client.completed_am_time_program![indexPath.row].status! {
            case "1":
                cell.lblStatus.text = "Administer"
            case "2":
                cell.lblStatus.text = "Prepared"
            case "3":
                cell.lblStatus.text = "prompt"
            case "4":
                cell.lblStatus.text = "Other"
            default:
                break
            }
        case 1:
            cell.lblMedname.text = client.completed_noon_time_program?[indexPath.row].medicine
            cell.lblType.text = client.completed_noon_time_program?[indexPath.row].type
            cell.dose.text = client.completed_noon_time_program?[indexPath.row].dose
            cell.detailTitle.text = "TimeGiven:"
            cell.detailLbl.text = client.completed_noon_time_program?[indexPath.row].timeGiven
            cell.statusTitle.text = "Status:"
            cell.noteTextLbl.text = client.completed_noon_time_program?[indexPath.row].message
            let note = client.completed_noon_time_program?[indexPath.row].message
            messageHeight = (note?.stringHeight(with: cell.noteTextLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!))!
            switch client.completed_noon_time_program![indexPath.row].status! {
            case "1":
                cell.lblStatus.text = "Administer"
            case "2":
                cell.lblStatus.text = "Prepared"
            case "3":
                cell.lblStatus.text = "prompt"
            case "4":
                cell.lblStatus.text = "Other"
            default:
                break
            }
        case 2:
            cell.lblMedname.text = client.completed_tea_time_program?[indexPath.row].medicine
            cell.lblType.text = client.completed_tea_time_program?[indexPath.row].type
            cell.dose.text = client.completed_tea_time_program?[indexPath.row].dose
            cell.detailTitle.text = "TimeGiven:"
            cell.detailLbl.text = client.completed_tea_time_program?[indexPath.row].timeGiven
            cell.statusTitle.text = "Status:"
            cell.noteTextLbl.text = client.completed_tea_time_program?[indexPath.row].message
            let note = client.completed_tea_time_program?[indexPath.row].message
            messageHeight = (note?.stringHeight(with: cell.noteTextLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!))!
            switch client.completed_tea_time_program![indexPath.row].status! {
            case "1":
                cell.lblStatus.text = "Administer"
            case "2":
                cell.lblStatus.text = "Prepared"
            case "3":
                cell.lblStatus.text = "prompt"
            case "4":
                cell.lblStatus.text = "Other"
            default:
                break
            }
        case 3:
             cell.lblMedname.text = client.completed_night_time_program?[indexPath.row].medicine
             cell.lblType.text = client.completed_night_time_program?[indexPath.row].type
             cell.dose.text = client.completed_night_time_program?[indexPath.row].dose
             cell.detailTitle.text = "TimeGiven:"
             cell.detailLbl.text = client.completed_night_time_program?[indexPath.row].timeGiven
             cell.statusTitle.text = "Status:"
             cell.noteTextLbl.text = client.completed_night_time_program?[indexPath.row].message
             let note = client.completed_night_time_program?[indexPath.row].message
             messageHeight = (note?.stringHeight(with: cell.noteTextLbl.frame.size.width, font: UIFont(name: "OpenSans", size: 15.0)!))!
             switch client.completed_night_time_program![indexPath.row].status! {
             case "1":
                cell.lblStatus.text = "Administer"
             case "2":
                cell.lblStatus.text = "Prepared"
             case "3":
                cell.lblStatus.text = "prompt"
             case "4":
                cell.lblStatus.text = "Other"
             default:
                break
            }
        default:
            break
        }
    }
    // MARK:- IBActions
    @IBAction func leftbarAction () {
        self.popView()
    }
    @IBAction func timeSelected(_ sender:UISegmentedControl){
        selectedSegment = sender.selectedSegmentIndex
//        self.client.completed_programs = [Program]()
//        switch selectedSegment {
//        case 0:
//            for i in 0..<(resultDict["am_time_care_program"] as! NSArray).count {
//                let program = Program()
//                program.medicine = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
//                program.dose = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
//                program.time = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
//                program.type = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
//                program.detail = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
//                program.status = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
//                program.timeGiven = ((resultDict["am_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
//                if program.status != "0" {
//                    self.client.completed_programs?.append(program)
//                    if client.am_time_care_program?.count != 0{
//                        self.client.am_time_care_program?.remove(at: i)
//                    }
//                }
//            }
//        case 1:
//            for i in 0..<(resultDict["noon_time_care_program"] as! NSArray).count {
//                let program = Program()
//                program.medicine = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
//                program.dose = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
//                program.time = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
//                program.type = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
//                program.detail = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
//                 program.timeGiven = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
//                program.status = ((resultDict["noon_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
//                if program.status != "0" {
//                    self.client.completed_programs?.append(program)
//                    if client.noon_time_care_program?.count != 0{
//                        self.client.noon_time_care_program?.remove(at: i)
//                    }
//                }
//            }
//        case 2:
//            for i in 0..<(resultDict["tea_time_care_program"] as! NSArray).count {
//                let program = Program()
//                program.medicine = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
//                program.dose = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
//                program.time = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
//                program.type = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
//                program.detail = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
//                  program.timeGiven = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
//                program.status = ((resultDict["tea_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
//                if program.status != "0" {
//                    self.client.completed_programs?.append(program)
//                    if client.tea_time_care_program?.count != 0{
//                        self.client.tea_time_care_program?.remove(at: i)
//                    }
//                }
//            }
//        case 3:
//            for i in 0..<(resultDict["night_time_care_program"] as! NSArray).count {
//                let program = Program()
//                program.medicine = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["medicine"] as? String
//                program.dose = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["dose"] as? String
//                program.time = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["time"] as? String
//                program.type = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["type"] as? String
//                program.detail = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["detail"] as? String
//                program.timeGiven = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["time_given"] as? String
//                program.status = ((resultDict["night_time_care_program"] as! NSArray)[i] as AnyObject)["status"] as? String
//                if program.status != "0" {
//                    self.client.completed_programs?.append(program)
//                    if self.client.night_time_care_program?.count != 0{
//                        self.client.night_time_care_program?.remove(at: i)
//                   }
//                }
//            }
//        default:
//            break
//        }
        tblMedication.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
