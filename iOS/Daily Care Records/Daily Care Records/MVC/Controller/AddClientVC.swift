//
//  AddClientVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/17/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class AddClientVC: UIViewController, UITableViewDelegate,UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate {
    @IBOutlet weak var addPocView: UIView!
    @IBOutlet weak var tfPostcode: UITextField!
    @IBOutlet weak var tfFirstname: UITextField!
    @IBOutlet weak var tfLastname: UITextField!
    @IBOutlet weak var tfDob: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfEmergencycontact: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfPersonalInfo: UITextField!
    @IBOutlet weak var tfInstructions: UITextField!
    @IBOutlet weak var imgProfile: MImageView!
    @IBOutlet weak var segmentProgramCare: UISegmentedControl!
    @IBOutlet weak var tfPocMedicationname: UITextField!
    @IBOutlet weak var tfPocmedicationtype: UITextField!
    @IBOutlet weak var tfPocDos: UITextField!
    @IBOutlet weak var tfPocTime: UITextField!
    @IBOutlet weak var tfPocMedicationDetail: UITextField!
    @IBOutlet weak var segmentViewMedication: UISegmentedControl!
    @IBOutlet weak var tblMedicationList: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var viewPicker: UIView!
    @IBOutlet weak var profileDatepicker: UIDatePicker!
    @IBOutlet weak var viewPoc: MView!
    @IBOutlet weak var viewMedView: MView!
    @IBOutlet weak var additional_InfoField: MTextView!
    
    //MARK:- outlets of addPocView elements.
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var medicationTypeField: UITextField!
    @IBOutlet weak var doseField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var detailField: UITextField!
    @IBOutlet weak var heightForBaseView: NSLayoutConstraint!
    
    var indexPath:IndexPath?
    
    private var am_time_care_program = NSMutableArray()
    private var noon_time_care_program = NSMutableArray()
    private var tea_time_care_program = NSMutableArray()
    private var night_time_care_program = NSMutableArray()

    
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Add Client", controller: self, isReveal : false)
        tblMedicationList.register(UINib.init(nibName: "MedicineCell", bundle: nil), forCellReuseIdentifier: "MedicineCell")
        // Do any additional setup after loading the view.
        additional_InfoField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        heightForBaseView.constant = 190
        self.addPocView.isHidden = true
        btnSubmit.putShadow()
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
        tap.numberOfTapsRequired = 1
        imgProfile.addGestureRecognizer(tap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func unhidePicker(){
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
    }
    // MARK: - Table view methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentViewMedication.selectedSegmentIndex {
        case 0:
            return am_time_care_program.count
        case 1:
            return noon_time_care_program.count
        case 2:
            return tea_time_care_program.count
        case 3:
            return night_time_care_program.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : MedicineCell! = tableView.dequeueReusableCell(withIdentifier: "MedicineCell") as! MedicineCell!
        cell.viewDetails.isHidden = true
        switch segmentViewMedication.selectedSegmentIndex {
        case 0:
            cell.lblMedname.text = (am_time_care_program[indexPath.row] as AnyObject)["medicine"] as? String
            cell.lblDos.text = (am_time_care_program[indexPath.row] as AnyObject)["dose"] as? String
            cell.lblType.text = (am_time_care_program[indexPath.row] as AnyObject)["type"] as? String
            cell.lblTime.text = (am_time_care_program[indexPath.row] as AnyObject)["time"] as? String
            return cell
        case 1:
            cell.lblMedname.text = (noon_time_care_program[indexPath.row] as AnyObject)["medicine"] as? String
            cell.lblDos.text = (noon_time_care_program[indexPath.row] as AnyObject)["dose"] as? String
            cell.lblType.text = (noon_time_care_program[indexPath.row] as AnyObject)["type"] as? String
            cell.lblTime.text = (noon_time_care_program[indexPath.row] as AnyObject)["time"] as? String
            return cell
        case 2:
            cell.lblMedname.text = (tea_time_care_program[indexPath.row] as AnyObject)["medicine"] as? String
            cell.lblDos.text = (tea_time_care_program[indexPath.row] as AnyObject)["dose"] as? String
            cell.lblType.text = (tea_time_care_program[indexPath.row] as AnyObject)["type"] as? String
            cell.lblTime.text = (tea_time_care_program[indexPath.row] as AnyObject)["time"] as? String
            return cell
        case 3:
            cell.lblMedname.text = (night_time_care_program[indexPath.row] as AnyObject)["medicine"] as? String
            cell.lblDos.text = (night_time_care_program[indexPath.row] as AnyObject)["dose"] as? String
            cell.lblType.text = (night_time_care_program[indexPath.row] as AnyObject)["type"] as? String
            cell.lblTime.text = (night_time_care_program[indexPath.row] as AnyObject)["time"] as? String
            return cell
        default:
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150//44
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = Bundle.main.loadNibNamed(String(describing: "ProgramCareHeader"), owner: self, options: nil)?[0] as! UIView
//        return header
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            print("Edit pressed...")
            self.addPocView.isHidden = false
            self.editPocData(atIndexPath: indexPath)
            self.indexPath = indexPath
        }
        edit.backgroundColor = APP_COLOR_BLUE
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            switch self.segmentViewMedication.selectedSegmentIndex{
            case 0: // Am segment pressed..
                self.am_time_care_program.removeObject(at: indexPath.row)
                self.tblMedicationList.beginUpdates()
                self.tblMedicationList.deleteRows(at: [indexPath], with: .fade)
                self.tblMedicationList.endUpdates()
            case 1: // Noon segment pressed..
                self.noon_time_care_program.removeObject(at: indexPath.row)
                self.tblMedicationList.beginUpdates()
                self.tblMedicationList.deleteRows(at: [indexPath], with: .fade)
                self.tblMedicationList.endUpdates()
            case 2: // Tea segment pressed..
                self.tea_time_care_program.removeObject(at: indexPath.row)
                self.tblMedicationList.beginUpdates()
                self.tblMedicationList.deleteRows(at: [indexPath], with: .fade)
                self.tblMedicationList.endUpdates()
            case 3: // Night segment pressed..
                self.night_time_care_program.removeObject(at: indexPath.row)
                self.tblMedicationList.beginUpdates()
                self.tblMedicationList.deleteRows(at: [indexPath], with: .fade)
                self.tblMedicationList.endUpdates()
            default:break
            }
        }
        delete.backgroundColor = APP_COLOR_GREEN
        return [delete,edit]
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    // MARK:- Image Picker delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imagePicked = info[UIImagePickerControllerEditedImage] as? UIImage
        imgProfile.image = imagePicked
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    // MARK:- IBActions
    func uploadImage() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    @IBAction func dobPressed(_ sender: UIButton) {
        profileDatepicker.datePickerMode = .date
        unhidePicker()
    }
    @IBAction func genderPressed(_ sender: UIButton) {
        let genderAlert = UIAlertController(title: APPNAME, message: nil, preferredStyle: .actionSheet)
        let male = UIAlertAction(title: "Male", style: .default) { (m) in
            self.tfGender.text = "Male"
        }
        let female = UIAlertAction(title: "Female", style: .default) { (fe) in
            self.tfGender.text = "Female"
        }
        let can = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        genderAlert.addAction(male)
        genderAlert.addAction(female)
        genderAlert.addAction(can)
        if let popover = genderAlert.popoverPresentationController{
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(genderAlert, animated: true, completion: nil)
    }
    @IBAction func programCareSelected(_ sender: UISegmentedControl) {
        tfPocMedicationname.text = ""
        tfPocmedicationtype.text = ""
        tfPocDos.text = ""
        tfPocTime.text = ""
        tfPocMedicationDetail.text = ""
    }
    @IBAction func pocSelectTimePressed(_ sender: UIButton) {
        profileDatepicker.datePickerMode = .time
        unhidePicker()
    }
    @IBAction func addPocPressed(_ sender: MButton) {
        if tfPocMedicationname.text == "" || tfPocmedicationtype.text == "" || tfPocDos.text == "" || tfPocTime.text == "" || tfPocMedicationDetail.text == "" {
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
            var dict = [String:AnyObject]()
            dict["medicine"] = tfPocMedicationname.text! as AnyObject?
            dict["dose"] = tfPocDos.text! as AnyObject?
            dict["time"] = tfPocTime.text! as AnyObject?
            dict["type"] = tfPocmedicationtype.text! as AnyObject?
            dict["detail"] = tfPocMedicationDetail.text! as AnyObject?
            switch segmentProgramCare.selectedSegmentIndex {
            case 0:
                am_time_care_program.add(dict)
            case 1:
                noon_time_care_program.add(dict)
            case 2:
                tea_time_care_program.add(dict)
            case 3:
                night_time_care_program.add(dict)
            default:
                break
            }
            heightForBaseView.constant = 250
            tblMedicationList.reloadData()
            dismissKeyboard()
            tfPocMedicationname.text = ""
            tfPocmedicationtype.text = ""
            tfPocDos.text = ""
            tfPocTime.text = ""
            tfPocMedicationDetail.text = ""
        }
    }
    
    //MARK:- TextView delegate.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == additional_InfoField{
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    @IBAction func segmentViewMedicationSelected(_ sender: UISegmentedControl) {
        tblMedicationList.reloadData()
    }
    @IBAction func submitPressed(_ sender: UIButton) {
        if tfPostcode.text! == "" || tfFirstname.text! == "" || tfLastname.text! == "" || tfDob.text! == "" || tfAddress.text! == "" || tfEmergencycontact.text! == "" || tfPersonalInfo.text! == "" || tfGender.text! == "" || additional_InfoField.text! == "" || tfInstructions.text! == "" {
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
            var am_time_care_program_string = "[]"
            if am_time_care_program.count > 0 {
                let aData = try! JSONSerialization.data(withJSONObject: am_time_care_program, options: [])
                am_time_care_program_string = String.init(data: aData, encoding: .utf8)!
            }
            var noon_time_care_program_string = "[]"
            if noon_time_care_program.count > 0 {
                let aData = try! JSONSerialization.data(withJSONObject: noon_time_care_program, options: [])
                noon_time_care_program_string = String.init(data: aData, encoding: .utf8)!
            }
            var tea_time_care_program_string = "[]"
            if tea_time_care_program.count > 0 {
                let aData = try! JSONSerialization.data(withJSONObject: tea_time_care_program, options: [])
                tea_time_care_program_string = String.init(data: aData, encoding: .utf8)!
            }
            var night_time_care_program_string = "[]"
            if night_time_care_program.count > 0 {
                let aData = try! JSONSerialization.data(withJSONObject: night_time_care_program, options: [])
                night_time_care_program_string = String.init(data: aData, encoding: .utf8)!
            }
            let param = NSMutableDictionary()
            param["postcode"] = self.tfPostcode.text!
            param["firstname"] = self.tfFirstname.text!
            param["lastname"] = self.tfLastname.text!
            param["dob"] = self.tfDob.text!
            param["address"] = self.tfAddress.text!
            param["emergency_contact"] = self.tfEmergencycontact.text!
            param["personal_information"] = self.tfPersonalInfo.text!
            param["additional_information"] = self.additional_InfoField.text!
            param["gender"] = self.tfGender.text! == "Male" ? 1 : 2
            param["am_time_care_program"] = am_time_care_program_string
            param["noon_time_care_program"] = noon_time_care_program_string
            param["tea_time_care_program"] = tea_time_care_program_string
            param["night_time_care_program"] = night_time_care_program_string
            var image = UIImage()
            if self.imgProfile.image == UIImage(named:"addNewImage"){
//                image = UIImage(named:"profile-placeholder")!
                self.kAlertView(title: APPNAME, message: Constants.Register.UPLOAD_PROFILE_PIC)
                return
            }else{
                image = self.imgProfile.image!
                 sender.isEnabled = false
            }
            print(param)
            
            
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                apiMgr.uploadImage(param, url: UrlConstants.BASE_URL+UrlConstants.add_newClient, imageName: "client_picture", image:image , success: { (response) in //self.imgProfile.image!
                    utilityMgr.hideIndicator()
                         sender.isEnabled = true
                    self.popView()
                    self.kAlertView(title: APPNAME, message: "Client added successfully")
                }, failure: { (error) in
                    sender.isEnabled = true
                    utilityMgr.hideIndicator()
                    print(error)
                    self.popView()
//                    self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
                })
            }
        }
    }
    func editPocData(atIndexPath:IndexPath){
        switch self.segmentViewMedication.selectedSegmentIndex{
        case 0: // for Am care porgram
            nameField.text = (am_time_care_program[atIndexPath.row] as AnyObject)["medicine"] as? String
            medicationTypeField.text = (am_time_care_program[atIndexPath.row] as AnyObject)["type"] as? String
            timeField.text = (am_time_care_program[atIndexPath.row] as AnyObject)["time"] as? String
            doseField.text = (am_time_care_program[atIndexPath.row] as AnyObject)["dose"] as? String
            detailField.text = (am_time_care_program[atIndexPath.row] as AnyObject)["detail"] as? String
        case 1: // for noon care program
            nameField.text = (noon_time_care_program[atIndexPath.row] as AnyObject)["medicine"] as? String
            medicationTypeField.text = (noon_time_care_program[atIndexPath.row] as AnyObject)["type"] as? String
            timeField.text = (noon_time_care_program[atIndexPath.row] as AnyObject)["time"] as? String
            doseField.text = (noon_time_care_program[atIndexPath.row] as AnyObject)["dose"] as? String
            detailField.text = (noon_time_care_program[atIndexPath.row] as AnyObject)["detail"] as? String
        case 2:  // for tea care program
            nameField.text = (tea_time_care_program[atIndexPath.row] as AnyObject)["medicine"] as? String
            medicationTypeField.text = (tea_time_care_program[atIndexPath.row] as AnyObject)["type"] as? String
            timeField.text = (tea_time_care_program[atIndexPath.row] as AnyObject)["time"] as? String
            doseField.text = (tea_time_care_program[atIndexPath.row] as AnyObject)["dose"] as? String
            detailField.text = (tea_time_care_program[atIndexPath.row] as AnyObject)["detail"] as? String
        case 3: // for night care program
            nameField.text = (night_time_care_program[atIndexPath.row] as AnyObject)["medicine"] as? String
            medicationTypeField.text = (night_time_care_program[atIndexPath.row] as AnyObject)["type"] as? String
            timeField.text = (night_time_care_program[atIndexPath.row] as AnyObject)["time"] as? String
            doseField.text = (night_time_care_program[atIndexPath.row] as AnyObject)["dose"] as? String
            detailField.text = (night_time_care_program[atIndexPath.row] as AnyObject)["detail"] as? String
        default:break
        }
    }
    @IBAction func closePocView(_ sender: UIButton) {
        self.addPocView.isHidden = true
    }
    
    @IBAction func editMedicineAction(_ sender: UIButton) { //MARK:- Edit medicine detail action for addPocView
        if nameField.text! == "" || doseField.text! == "" || medicationTypeField.text! == "" || detailField.text! == "" || timeField.text! == "" {
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        }else{
            self.addPocView.isHidden = true
            if sender.currentTitle == "Edit" {
                // set edited values and show these values on appropriate row of tableView
                var dict = [String:AnyObject]()
                dict["medicine"] = nameField.text! as AnyObject?
                dict["dose"] = doseField.text! as AnyObject?
                dict["time"] = timeField.text! as AnyObject?
                dict["type"] = medicationTypeField.text! as AnyObject?
                dict["detail"] = detailField.text! as AnyObject?
                switch segmentViewMedication.selectedSegmentIndex {
                case 0:
                    am_time_care_program[(self.indexPath?.row)!] = dict
                case 1:
                    noon_time_care_program[(self.indexPath?.row)!] = dict
                case 2:
                    tea_time_care_program[(self.indexPath?.row)!] = dict
                case 3:
                    night_time_care_program[(self.indexPath?.row)!] = dict
                default:
                    break
                }
                tblMedicationList.reloadData()
                tfPocMedicationname.text = ""
                tfPocmedicationtype.text = ""
                tfPocDos.text = ""
                tfPocTime.text = ""
                tfPocMedicationDetail.text = ""
                self.indexPath = nil
        }
        }
    }
    
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if sender.tag == 101 {
            if profileDatepicker.datePickerMode == .date {
                tfDob.text = TimeManager.FormatDateString(strDate: String(describing:profileDatepicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
            } else {
                tfPocTime.text = TimeManager.FormatDateString(strDate: String(describing:profileDatepicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm")
                if addPocView.isHidden == false{
                    timeField.text = TimeManager.FormatDateString(strDate: String(describing:profileDatepicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm")
                }
                
            }
        }
    }
    @IBAction func leftbarAction () {
        self.popView()
    }
}
