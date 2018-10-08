//
//  AddManagerVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/18/18.
//  Copyright © 2018 techwin labs. All rights reserved.


import UIKit

class AddManagerVC: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var tfEmployeeNumber: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfCountryCode: UITextField!
     @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var imgProfile: MImageView!
    @IBOutlet weak var countryCodePicker: UIPickerView!
    var titleStr = ""
    var designation_id = ""
    var designation = ""
    var userType:String?
    private var countryArray:[Country]=[Country]()
    @IBOutlet weak var viewPicker: UIView!
    private var employee_country_code : String?
    private var isEmailAvailable:Bool?
    private var isEmployeeNameAvailable:Bool?
    
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: titleStr, controller: self, isReveal : false)
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
        tap.numberOfTapsRequired = 1
        imgProfile.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        userType = utilityMgr.getUDVal(forKey: "employee_type") as? String
        (userType == "3") ? (btnSubmit.setTitle("Assign Access", for: .normal)) : (btnSubmit.setTitle("Submit", for: .normal))
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_CountryCode
            self.webserviceCall(param: nil, link: link)
        }
    }
    // MARK:- Server Calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                print(response)
                let methodName = response["method"] as! String
                if methodName == "checkEmployeeNumberIsFree" {
                    print(self.isEmployeeNameAvailable)
                    self.isEmployeeNameAvailable = response["message"] as! String == "1"
                    print(self.isEmployeeNameAvailable)
                    if self.isEmployeeNameAvailable == nil || self.isEmployeeNameAvailable == false{
                        self.tfEmployeeNumber.text = ""
                        self.kAlertView(title: APPNAME, message: "This employee is already added")
                    }
                } else if methodName == "checkEmailIsFree" {
                    self.isEmailAvailable = response["message"] as! String == "1"
                    if self.isEmailAvailable == nil || self.isEmailAvailable == false{
                        self.tfEmail.text = ""
                        self.kAlertView(title: APPNAME, message: "The employee with this email has been added")
                    }
                    
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                let methodName = response["method"] as! String
                if methodName == "get_CountryCode" {
                    let data = response["data"] as! NSArray
                    self.countryArray.removeAll()
                    for i in 0..<data.count {
                        let dict = data[i] as! NSDictionary
                        let c = Country()
                        c.countries_id = dict["countries_id"] as? String
                        c.countries_name = dict["countries_name"] as? String
                        c.country_code = dict["country_code"] as? String
                        c.countries_iso_code = dict["countries_iso_code"] as? String
                        c.flag = dict["flag"] as? String
                        self.countryArray.append(c)
                    }
                    DispatchQueue.main.async {
                        self.countryCodePicker.reloadAllComponents()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Pickerview methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryArray[row].countries_name
    }
    // MARK:- Textfield delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmployeeNumber && textField.text != "" {
            isEmployeeNameAvailable = nil
            DispatchQueue.global(qos: .background).async {
                self.webserviceCall(param: ["employee_number":self.tfEmployeeNumber.text!], link: UrlConstants.BASE_URL+UrlConstants.checkEmployeeNumberIsFree)
            }
        } else if textField == tfEmail && tfEmail.text?.isValidEmail() == true {
            DispatchQueue.global(qos: .background).async {
                self.webserviceCall(param: ["employee_email":self.tfEmail.text!], link: UrlConstants.BASE_URL+UrlConstants.checkEmailIsFree)
            }
        } else if textField == tfEmail && tfEmail.text?.isValidEmail() == false {
            kAlertView(title: APPNAME, message: Constants.Register.EMAIL_VALIDATION_MESSAGE)
        }
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
    @IBAction func countryCoseChosen(_ sender: UIButton) {
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
    }
    
    //MARK:- Assign Access action.
    @IBAction func submitPressed(_ sender: UIButton) {
        if tfName.text == "" || tfEmployeeNumber.text == "" || tfEmail.text == "" || tfCountryCode.text == "" || tfMobile.text == "" {
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
//            isEmailAvailable = true
//            isEmployeeNameAvailable = true
            //if isEmailAvailable != nil && isEmployeeNameAvailable != nil
            sender.isEnabled = false
            if isEmailAvailable == true && isEmployeeNameAvailable == true {
                if isEmailAvailable! == false {
                    kAlertView(title: APPNAME, message: Constants.Register.EMAIL_UNAVAILABLE)
                    return
                }
                if isEmployeeNameAvailable! == false {
                    kAlertView(title: APPNAME, message: Constants.Register.EMPLOYEE_NUMBER_UNAVAILABLE)
                    return
                }
                if isEmailAvailable! && isEmployeeNameAvailable! {
                    let paramDict = NSMutableDictionary()
                    paramDict["employee_name"] = tfName.text!
                    paramDict["employee_number"] = tfEmployeeNumber.text!
                    paramDict["employee_email"] = tfEmail.text!
                    paramDict["employee_country_code"] = tfCountryCode.text!
                    paramDict["employee_mobile"] = tfMobile.text!
                    if tfGender.text != "" {
                        paramDict["gender"] = tfGender.text! == "Male" ? 1 : 2
                    }
                    paramDict["employee_designation"] = designation_id
                    DispatchQueue.global(qos: .userInitiated).async {
                        utilityMgr.showIndicator()
                        if self.imgProfile.image != UIImage(named: "addNewImage") {
                            apiMgr.uploadImage(paramDict, url: UrlConstants.BASE_URL+UrlConstants.add_newStaffMember, imageName: "employee_picture", image: self.imgProfile.image!, success: { (respons) in
                                sender.isEnabled = true
                                utilityMgr.hideIndicator()
//                                self.popView()
//                                self.kAlertView(title: APPNAME, message: "Staff Member added successfully")
                                if self.userType == "3"{
                                    let vc =  managerStoryBoard.instantiateViewController(withIdentifier: "AccessRightsVC") as! AccessRightsVC
                                    self.pushview(objtype: vc)
                                }else{
                                self.popView()
                                }
                              
                            }, failure: { (error) in
                                sender.isEnabled = true
                                utilityMgr.hideIndicator()
                                print(error)
                                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
                            })
                        } else {
                            apiMgr.postRequest(paramDict, url: UrlConstants.BASE_URL+UrlConstants.add_newStaffMember, success: { (response) in
                                sender.isEnabled = true
                                print("submit button api response..\(response)")
                                utilityMgr.hideIndicator()
//                                self.popView()
                                //  self.kAlertView(title: APPNAME, message: "Staff Member added successfully")
                                if self.userType == "3"{
                                let vc =  managerStoryBoard.instantiateViewController(withIdentifier: "AccessRightsVC") as! AccessRightsVC
                                self.pushview(objtype: vc)
                            }else{
                                self.popView()
                            }
                                
                            }, failure: { (error) in
                                sender.isEnabled = true
                                utilityMgr.hideIndicator()
                                print(error)
                                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
                            })
                        }
                    }
                }
            }
        }
    }
    func uploadImage() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    @IBAction func leftbarAction () {
        self.popView()
    }
    
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if sender.tag == 101 {
            employee_country_code = countryArray[countryCodePicker.selectedRow(inComponent: 0)].country_code
            tfCountryCode.text = countryArray[countryCodePicker.selectedRow(inComponent: 0)].countries_name
        }
    }

}
