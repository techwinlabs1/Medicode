//
//  ProfileVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/6/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgProfile: MImageView!
    @IBOutlet weak var tfPostCode: UITextField!
    @IBOutlet weak var first_name: UITextField!
    @IBOutlet weak var last_name: UITextField!
    @IBOutlet weak var client_phnNo: UITextField!
    @IBOutlet weak var client_mail: UITextField!
    @IBOutlet weak var tfDob: UITextField!
    @IBOutlet weak var tfAddress: UITextField!
    @IBOutlet weak var tfEmergencyContact: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var txtViewInstructions: MTextView!
    @IBOutlet weak var heightInstructions: NSLayoutConstraint!
    @IBOutlet weak var txtViewPersonalInfo: MTextView!
    @IBOutlet weak var heightPersonalInfo: NSLayoutConstraint!
    @IBOutlet weak var heightContent: NSLayoutConstraint!
    @IBOutlet weak var heightPersonalView: NSLayoutConstraint!
    @IBOutlet weak var heightInstructionView: NSLayoutConstraint!
    @IBOutlet weak var viewPersonalInfo: UIView!
    var editingEnabled = false
    @IBOutlet weak var profileDatepicker: UIDatePicker!
    @IBOutlet weak var emergencyContactName: MTextView!
    @IBOutlet weak var gp_NameField: MTextView!
    @IBOutlet weak var gp_addressField: MTextView!
    @IBOutlet weak var gp_contactNoField: MTextView!
    @IBOutlet weak var alergiesField: MTextView!
    @IBOutlet weak var additional_InfoField: MTextView!
    @IBOutlet weak var emergencyContRelation: MTextView!
    @IBOutlet weak var dobButton: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var titleString = ""
    var client_id = ""
    private var clientDetail = Client()
    @IBOutlet weak var viewPicker: UIView!
    var topRightBtnClicked = true
    
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if editingEnabled {
            self.client_mail.addTarget(self, action: #selector(textChange(_:)), for: .editingDidEnd)
            utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: UIImage(named:"save-tick"),titleText: titleString, controller: self, isReveal : false)
            let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
            tap.numberOfTapsRequired = 1
            imgProfile.addGestureRecognizer(tap)
        } else {
            utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: titleString, controller: self, isReveal : false)
        }
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.view_ClientProfile+self.client_id)
        }
        // Do any additional setup after loading the view.
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    // MARK:- Server Calls
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "view_ClientProfile" {
                DispatchQueue.main.async {
                    let dict = response["data"] as! NSDictionary
                    self.updateData(dict: dict)
                }
            } 
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func updateClientProfile(){
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            let param = NSMutableDictionary()
            param["client_id"] = self.clientDetail.client_id!
            param["postcode"] = self.tfPostCode.text!
            param["firstname"] = self.clientDetail.firstname!
            param["lastname"] = self.clientDetail.lastname!
            param["dob"] = TimeManager.FormatDateString(strDate: self.tfDob.text!, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd") //self.tfDob.text!
            param["address"] = self.tfAddress.text!
            param["emergency_contact"] = self.tfEmergencyContact.text!
            param["personal_information"] = self.txtViewPersonalInfo.text!
            param["comments"] =  self.txtViewInstructions.text//""
            param["gender"] = self.tfGender.text! == "Male" ? 1 : 2
            param["emergency_contact_name"] = self.emergencyContactName.text
            param["emergency_contact_relation"] = self.emergencyContRelation.text
             param["doctor_name"] = self.gp_NameField.text
            param["doctor_address"] = self.gp_addressField.text
            param["doctor_contact_number"] = self.gp_contactNoField.text
            param["allergies"] = self.alergiesField.text
            param["additional_information"] = self.additional_InfoField.text
            param["email"] = self.client_mail.text
            param["phone_number"] = self.client_phnNo.text
            print(param)
            apiMgr.uploadImage(param, url: UrlConstants.BASE_URL+UrlConstants.update_ClientProfile, imageName: "client_picture", image: self.imgProfile.image!, success: { (response) in
                utilityMgr.hideIndicator()
                self.topRightBtnClicked = true
                self.popView()
                self.kAlertView(title: APPNAME, message: "Profile updated successfully")
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                 self.topRightBtnClicked = true
                print(error)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    //MARK:- Update data function.
    private func updateData(dict:NSDictionary){
        print(dict)
        clientDetail.client_picture = dict["client_picture"] as? String
        clientDetail.postcode = dict["postcode"] as? String
        if let date = dict["dob"] as? String{
            if date != "0000-00-00"{
                let dateOfB = TimeManager.FormatDateString(strDate: (dict["dob"] as? String)!, fromFormat: "yyyy-MM-dd", toFormat: "dd-MM-yyyy") //self.tfDob.text!
                print(dateOfB)
                clientDetail.dob =  dateOfB //dict["dob"] as? String
            }else{
                clientDetail.dob =  date //dict["dob"] as? String
            }
           
        }
        
        
        clientDetail.address = dict["address"] as? String
        clientDetail.emergency_contact = dict["emergency_contact"] as? String
        clientDetail.gender = dict["gender"] as? String
        clientDetail.personal_information = dict["personal_information"] as? String
        clientDetail.firstname = dict["firstname"] as? String
        clientDetail.lastname = dict["lastname"] as? String
        clientDetail.client_id = dict["client_id"] as? String
        clientDetail.additionalInfo = dict["additional_information"] as? String
        clientDetail.comments = dict["comments"] as? String
        clientDetail.allergies = dict["allergies"] as? String
        clientDetail.gp_name = dict["doctor_name"] as? String
        clientDetail.gp_address = dict["doctor_address"] as? String
        clientDetail.gp_contact = dict["doctor_contact_number"] as? String
        clientDetail.emergency_name = dict["emergency_contact_name"] as? String
        clientDetail.emergency_relation = dict["emergency_contact_relation"] as? String
        clientDetail.client_email = dict["email"] as? String
        clientDetail.client_phnNo = dict["phone_number"] as? String
        
        // fill appropriate data to fields.
        tfPostCode.text = clientDetail.postcode
        first_name.text = clientDetail.firstname
        last_name.text = clientDetail.lastname
        tfDob.text = clientDetail.dob
        print(clientDetail.dob)
        tfAddress.text = clientDetail.address
        tfEmergencyContact.text = clientDetail.emergency_contact
        tfGender.text = clientDetail.gender == "1" ? "Male" : "Female"
        imgProfile.sd_setImage(with: URL(string: clientDetail.client_picture!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        txtViewInstructions.text = clientDetail.comments //Instructions.
        if clientDetail.comments != ""{
            let height = clientDetail.comments?.stringHeight(with: txtViewInstructions.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
            print(height)
            heightInstructions.constant = height! + 60
            heightInstructionView.constant = height! + 60
            txtViewInstructions.isScrollEnabled = false
            heightPersonalView.constant = 60 + heightInstructions.constant
            heightContent.constant = 1350 + heightPersonalView.constant
        }
        additional_InfoField.text = clientDetail.additionalInfo
        alergiesField.text = clientDetail.allergies
        gp_NameField.text = clientDetail.gp_name
        gp_addressField.text = clientDetail.gp_address
        gp_contactNoField.text = clientDetail.gp_contact
        emergencyContactName.text = clientDetail.emergency_name
        emergencyContRelation.text = clientDetail.emergency_relation
        client_mail.text = clientDetail.client_email
        client_phnNo.text = clientDetail.client_phnNo
        
        txtViewPersonalInfo.text = clientDetail.personal_information
        if clientDetail.personal_information != "" {
            let height = clientDetail.personal_information?.stringHeight(with: txtViewPersonalInfo.frame.size.width, font: UIFont(name: APP_FONT, size: 14.0)!)
            heightPersonalInfo.constant = height! + 10
            heightPersonalView.constant = 30 + heightPersonalInfo.constant
        }
        
        //Enable editing for fields.
        tfPostCode.isUserInteractionEnabled = editingEnabled
        first_name.isUserInteractionEnabled = editingEnabled
        last_name.isUserInteractionEnabled = editingEnabled
        tfDob.isUserInteractionEnabled = editingEnabled
        tfAddress.isUserInteractionEnabled = editingEnabled
        tfEmergencyContact.isUserInteractionEnabled = editingEnabled
        txtViewInstructions.isUserInteractionEnabled = editingEnabled
        txtViewPersonalInfo.isUserInteractionEnabled = editingEnabled
        tfGender.isUserInteractionEnabled = editingEnabled
        self.emergencyContactName.isUserInteractionEnabled = editingEnabled
        emergencyContRelation.isUserInteractionEnabled = editingEnabled
        gp_NameField.isUserInteractionEnabled = editingEnabled
        gp_addressField.isUserInteractionEnabled = editingEnabled
        gp_contactNoField.isUserInteractionEnabled = editingEnabled
        alergiesField.isUserInteractionEnabled = editingEnabled
        additional_InfoField.isUserInteractionEnabled = editingEnabled
        dobButton.isUserInteractionEnabled = editingEnabled
        genderBtn.isUserInteractionEnabled = editingEnabled
        client_phnNo.isUserInteractionEnabled = editingEnabled
        client_mail.isUserInteractionEnabled = editingEnabled
//        print(heightContent.constant)
//        heightContent.constant = viewPersonalInfo.frame.origin.y //+ heightPersonalView.constant //+ 30 //viewPersonalInfo.frame.origin.y +
//        print(heightContent.constant)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @IBAction func dobPressed(_ sender: UIButton) {
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
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
    @IBAction func leftbarAction () {
        utilityMgr.hideIndicator()
        self.popView()
    }
    @IBAction func rightbarAction(){
        // save profile
        if topRightBtnClicked{
            topRightBtnClicked = false
            updateClientProfile()
        }
    }
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if sender.tag == 101 {
            tfDob.text = TimeManager.FormatDateString(strDate: String(describing:profileDatepicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy")
        }
    }
    func uploadImage() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    
    //MARK:- Clint Phone No TextField delegate.
    @objc func textChange(_ textFld:UITextField){
        if textFld == self.client_mail {
            if isValidEmail(testStr: textFld.text!) == false  {
                textFld.text = ""
                kAlertView(title: APPNAME, message: Constants.Register.EMAIL_VALIDATION_MESSAGE)
            }
        }
    }
    
    @IBAction func printAction(_ sender: UIButton) {
//        let img = snapshot()//self.view.toImage()
//        let imgView = UIImageView(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: 500))
//        imgView.image = img
//        imgView.contentMode = .scaleAspectFit
//        self.view.addSubview(imgView)
    }
    // E_mail validation.
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK:- Take screenShot of whole screen.
    func snapshot() -> UIImage?{
        UIGraphicsBeginImageContext(scrollView.contentSize)
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        return image
    }
}


