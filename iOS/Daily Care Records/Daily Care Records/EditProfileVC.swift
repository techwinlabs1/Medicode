//
//  EditProfileVC.swift
//  Daily Care Records
//
//  Created by Techwin Labs Mac-3 on 12/09/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    

 
    //MARK:- Oulets.
    
    @IBOutlet weak var name_Lbl: UILabel!
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var contact_field: UITextField!
    @IBOutlet weak var empNumber_field: UITextField!
    @IBOutlet weak var designation_field: UITextField!
    @IBOutlet weak var gender_field: UITextField!
    @IBOutlet weak var profile_Img: MImageView!
    @IBOutlet weak var countryCode: UITextField!
    @IBOutlet weak var pickerViewBase: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    
    
    //MARK:- Properties.
    var employee_id:String?
    var pickerArray:[[String:Any]] = [[String:Any]]()
    var employeeName:String = ""
    var profilePic:String = ""
    //MARK:- ViewController Life Cycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button"), rightImage:UIImage(named:"save-tick") , titleText: "Edit Profile", controller: self, isReveal: true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImage))
        tap.numberOfTapsRequired = 1
        profile_Img.addGestureRecognizer(tap)
        utilityMgr.showIndicator()
        webserviceCall(param: nil, link: UrlConstants.BASE_URL+UrlConstants.get_staffMemberInfo+employee_id!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pickerViewBase.isHidden = true
   
    }
   
    

    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil{
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let method = response["method"] as! String
                if method == "update_profile"{
                    if let dict = response["data"] as? [String:Any]{
                        utilityMgr.setUDVal(val: dict["employee_mobile"]!, forKey: "employee_mobile")
                        utilityMgr.setUDVal(val: dict["employee_name"]!, forKey: "employee_name")
                        utilityMgr.setUDVal(val: dict["employee_picture"]!, forKey: "employee_picture")
                        utilityMgr.setUDVal(val: dict["gender"]!, forKey: "gender")
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error?.localizedDescription)
            })
        }else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let method = response["method"] as! String
                if method == "get_staffMemberInfo"{
                    DispatchQueue.global(qos: .background).async {
                         self.webserviceCall(param: nil, link: UrlConstants.BASE_URL+UrlConstants.get_CountryCode)
                    }
                    if let dict:[String:Any] = response["data"] as? [String:Any]{
                        self.updateUI(data:dict)
                    }
                }else if method == "get_CountryCode"{
                    if let data = response["data"] as? [[String:Any]] {
                        self.pickerArray = data
                        self.picker.reloadAllComponents()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error?.localizedDescription)
            })
        }
        
    }
    
 
    //MARK:- UpdateUI Method.
    private func updateUI(data:[String:Any]){
        DispatchQueue.main.async {
            self.email_field.text = data["employee_email"] as? String
            self.contact_field.text = data["employee_mobile"] as? String
            self.empNumber_field.text = data["employee_number"] as? String
            self.countryCode.text = data["employee_country_code"] as? String
            self.name_Lbl.text = data["employee_name"] as? String
            self.name_field.text = data["employee_name"] as? String
            self.employeeName = data["employee_name"] as! String
            self.profilePic = data["employee_picture"] as! String
//            let gender = data["gender"] as? String
            self.gender_field.text = (data["gender"] as? String == "1") ? "Male" : "Female"
            let designation = data["employee_designation"] as! String
            switch designation{
            case "1":
                self.designation_field.text = "Carer"
            case "2":
                 self.designation_field.text = "Manager"
            case "3":
                self.designation_field.text = "Supervisor"
            default:
                break
            }
            self.profile_Img.sd_setImage(with: URL(string: (data["employee_picture"] as? String)!), placeholderImage: #imageLiteral(resourceName: "profile-placeholder"), options: [], completed: nil)
        }
    }
    
    //MARK:- Right Bar Action.
    @IBAction func rightbarAction(){
         view.endEditing(true)
        if isValidEmail(testStr: email_field.text!){
            utilityMgr.showIndicator()
            let param = NSMutableDictionary()
            param["employee_email"] = email_field.text!
            param["employee_country_code"] = countryCode.text!
            param["employee_mobile"] = contact_field.text!
            param["gender"] = (gender_field.text! == "Male") ? "1" : "2" 
            param["employee_name"] = name_field.text!
            apiMgr.uploadImage(param, url: UrlConstants.BASE_URL+UrlConstants.update_profile, imageName: "employee_picture", image: self.profile_Img.image!, success: { (response) in
                utilityMgr.hideIndicator()
                let method = response["method"] as! String
                if method == "update_profile"{
                    if let dict = response["data"] as? [String:Any]{
                        print(dict)
                        utilityMgr.setUDVal(val: dict["employee_mobile"]!, forKey: "employee_mobile")
                        utilityMgr.setUDVal(val: dict["employee_name"]!, forKey: "employee_name")
                        utilityMgr.setUDVal(val: dict["employee_picture"]!, forKey: "employee_picture")
                         self.name_Lbl.text = dict["employee_name"] as? String
                        self.name_field.text = dict["employee_name"] as? String
                         self.contact_field.text = dict["employee_mobile"] as? String
                         self.profilePic = dict["employee_picture"] as! String
                        self.profile_Img.sd_setImage(with: URL(string: (dict["employee_picture"] as? String)!), placeholderImage: #imageLiteral(resourceName: "profile-placeholder"), options: [], completed: nil)
                        self.kAlertView(title: APPNAME, message: response["message"] as? String)
                    }
                }
                
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error)
            })
        }else{
            self.kAlertView(title: APPNAME, message: Constants.Register.EMAIL_VALIDATION_MESSAGE)
        }

        }
    
    //MARK:- Select Gender action.
    @IBAction func genderBtnAction(_ sender: UIButton) {
        let genderAlert = UIAlertController(title: APPNAME, message: nil, preferredStyle: .actionSheet)
        let male = UIAlertAction(title: "Male", style: .default) { (m) in
            self.gender_field.text = "Male"
        }
        let female = UIAlertAction(title: "Female", style: .default) { (fe) in
            self.gender_field.text = "Female"
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
    
    //MARK:- Upload Image.
    func uploadImage() {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }
    
    //MARK:- ImagePicker delegates.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imagePicked = info[UIImagePickerControllerEditedImage] as? UIImage{
            profile_Img.image = imagePicked
        }else if let imagepicked = info[UIImagePickerControllerOriginalImage] as? UIImage{
            profile_Img.image = imagepicked
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //MARK:- Select Country Code Action.
    @IBAction func countryCodeAction(_ sender: UIButton) {
        unhidePicker()
        
    }
    //MARK:- PickerView delegates.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]["countries_name"] as? String
    }
    
    //MARK:- Unhide pickerView.
    private func unhidePicker(){
        dismissKeyboard()
        pickerViewBase.frame = CGRect.init(x: pickerViewBase.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: pickerViewBase.frame.size.width, height: pickerViewBase.frame.size.height)
        pickerViewBase.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.pickerViewBase.frame = CGRect.init(x: self.pickerViewBase.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.pickerViewBase.frame.size.height, width: self.pickerViewBase.frame.size.width, height: self.pickerViewBase.frame.size.height)
        }, completion: nil)
    }
    
    //MARK:- Left Bar button.
   @objc func sideMenuAction(){
        view.endEditing(true)
    revealViewController().revealToggle(animated: true)
    }
    //MARK:- Done Action.
    @IBAction func doneBtnAction(_ sender: UIButton) {
        pickerViewBase.isHidden = true
        countryCode.text = pickerArray[picker.selectedRow(inComponent: 0)]["countries_id"] as? String
    
    }
    //MARK:- Cancel Action.
    @IBAction func cancel(_ sender: UIButton) {
        pickerViewBase.isHidden = true
    }
    
    // E_mail validation.
    private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}// Class ends here.
