//
//  CarerProfileVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/18/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class CarerProfileVC: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imgProfile: MImageView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfContactNumber: UITextField!
    @IBOutlet weak var tfEmployeeNumber: UITextField!
    @IBOutlet weak var tfDesignation: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    var titleString = ""
    var client_id = ""
    var editingEnabled = false
    let emp = Employee()
    var topRightBtnClicked = true
    var openedFromSideMenu:Bool = false
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imgProfile.sd_setImage(with: URL(string: utilityMgr.getUDVal(forKey: "employee_picture")! as! String), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        if openedFromSideMenu{
              utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: titleString, controller: self, isReveal : true)
        }else{
              utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: editingEnabled ? UIImage(named:"save-tick") : nil,titleText: titleString, controller: self, isReveal : false)
        }
      
        if editingEnabled {
            let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
            tap.numberOfTapsRequired = 1
            imgProfile.addGestureRecognizer(tap)
        }
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            print(UrlConstants.BASE_URL+UrlConstants.get_staffMemberInfo+self.client_id)
            self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.get_staffMemberInfo+self.client_id)
        }
        // Do any additional setup after loading the view.
    }
   
    // MARK:- Server Calls
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_staffMemberInfo" {
                DispatchQueue.main.async {
                    let dict = response["data"] as! NSDictionary
                    self.updateStaffData(dict: dict)
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func updateStaffMember(){
        //Body Request : staff_id, employee_name, employee_number, employee_email, employee_country_code, employee_mobile,
        //Optional : employee_picture, employee_designation, gender
        if tfEmployeeNumber.text == "" || tfEmail.text == "" || tfContactNumber.text == "" {
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                let param = NSMutableDictionary()
                param["staff_id"] = self.emp.employeeid!
                param["employee_name"] = self.emp.employee_name!
                param["employee_number"] = self.emp.employee_number!
                param["employee_email"] = self.tfEmail.text!
                param["employee_country_code"] = self.emp.employee_country_code!
                param["employee_mobile"] = self.tfContactNumber.text!
                param["employee_designation"] = self.emp.employee_designation!
                param["gender"] = self.tfGender.text == "Male" ? 1 : 2
                if self.imgProfile.image != UIImage(named:"profile-placeholder") {
                    // with image
                    apiMgr.uploadImage(param, url: UrlConstants.BASE_URL+UrlConstants.update_staffMemberInfo, imageName: "employee_picture", image: self.imgProfile.image!, success: { (response) in
                        print(response)
                        
                        utilityMgr.hideIndicator()
                        self.topRightBtnClicked = true
                        self.popView()
                        self.kAlertView(title: APPNAME, message: response["message"] as? String)
                    }, failure: { (error) in
                        utilityMgr.hideIndicator()
                        self.topRightBtnClicked = true
                        print(error)
                        self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
                    })
                } else {
                    // without
                    print(param)
                    apiMgr.postRequest(param, url: UrlConstants.BASE_URL+UrlConstants.update_staffMemberInfo, success: { (response) in
                        utilityMgr.hideIndicator()
                        print(response)
                        self.popView()
                        self.kAlertView(title: APPNAME, message: response["message"] as? String)
                    }, failure: { (error) in
                        utilityMgr.hideIndicator()
                        print(error)
                        self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
                    })
                }
            }
        }
    }
    private func updateStaffData(dict:NSDictionary){
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
        emp.gender = dict["gender"] as? String
        emp.designation = dict["designation"] as? String
        tfEmail.text = emp.employee_email
        tfEmail.isUserInteractionEnabled = editingEnabled
        tfContactNumber.text = emp.employee_mobile
        tfContactNumber.isUserInteractionEnabled = editingEnabled
        tfEmployeeNumber.text = emp.employee_number
        tfEmployeeNumber.isUserInteractionEnabled = editingEnabled
        tfDesignation.text = emp.designation
        tfDesignation.isUserInteractionEnabled = editingEnabled
        tfGender.text = emp.gender! == "1" ? "Male" : "Female"
        
    }
    // MARK:- Image Picker delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagePicked = info[UIImagePickerControllerEditedImage] as? UIImage{
            imgProfile.image = imagePicked
        }else if let imagepicked = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imgProfile.image = imagepicked
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- IBActions
    @IBAction func leftbarAction () {
        if openedFromSideMenu{
            utilityMgr.hideIndicator()
        }else{
            utilityMgr.hideIndicator()
            self.popView()
        }
      
    }
    @IBAction func rightbarAction(){
        // update profile
        if topRightBtnClicked{
            topRightBtnClicked = false
            updateStaffMember()
        }
        
    }
    @IBAction func genderChosen(_ sender: UIButton) {
        if editingEnabled {
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
    }
    func uploadImage() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }


}
