//
//  LoginVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/4/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit
import Crashlytics

class LoginVC: UIViewController , UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet weak var tfCompanyname: UITextField!
    @IBOutlet weak var tfEmployeeId: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var tblCompanies: UITableView!
    @IBOutlet weak var lblNoCompanies: UILabel!
    private var companyArray = NSMutableArray()
    private var company_id : String?
    
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var numberPadView: UIView!
    @IBOutlet weak var labl1: MLabel!
    @IBOutlet weak var labl2: UILabel!
    @IBOutlet weak var labl3: UILabel!
    @IBOutlet weak var labl4: UILabel!
    @IBOutlet weak var labl5: UILabel!
    var password = [String]()
    
    // MARK:- View life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        tfCompanyname.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
   tfEmployeeId.delegate = self
 roundlabels()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(clearPasswrd), name: NSNotification.Name(rawValue: "ClearPassword"), object: nil)
        if let email = utilityMgr.getUDVal(forKey: "employee_email") as? String {
            self.tfEmployeeId.text = email
        }
          //  btnLogin.putShadow()
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil{
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "search_company" {
                    self.company_id = nil
                    self.companyArray.removeAllObjects()
                    for i in 0..<(response["data"] as! NSArray).count {
                        self.companyArray.add((response["data"] as! NSArray)[i])
                    }
                    DispatchQueue.main.async {
                        if self.companyArray.count == 0 {
                            self.tblCompanies.isHidden = true
                            self.lblNoCompanies.isHidden = false
                        } else {
                            self.tblCompanies.isHidden = false
                            self.tblCompanies.backgroundColor = UIColor.clear
                            self.lblNoCompanies.isHidden = true
                        }
                        self.tblCompanies.reloadData()
                    }
                } else if methodName == "employee_login" {
                    self.crossBtn.isUserInteractionEnabled = true
                    self.forgotBtn.isUserInteractionEnabled = true 
                    self.password.removeAll()
                    self.clearlabels()
                    let dict = response["data"] as! NSDictionary
                    print(dict)
                    utilityMgr.setUDVal(val: dict["company_id"]!, forKey: "company_id")
                    utilityMgr.setUDVal(val: dict["employee_country_code"]!, forKey: "employee_country_code")
                    utilityMgr.setUDVal(val: dict["employee_designation"]!, forKey: "employee_designation")
                    utilityMgr.setUDVal(val: dict["employee_email"]!, forKey: "employee_email")
                    utilityMgr.setUDVal(val: dict["employee_mobile"]!, forKey: "employee_mobile")
                    utilityMgr.setUDVal(val: dict["employee_name"]!, forKey: "employee_name")
                    utilityMgr.setUDVal(val: dict["employee_number"]!, forKey: "employee_number")
                    utilityMgr.setUDVal(val: dict["employee_picture"]!, forKey: "employee_picture")
                    utilityMgr.setUDVal(val: dict["employee_type"]!, forKey: "employee_type")
                    utilityMgr.setUDVal(val: dict["employeeid"]!, forKey: "employeeid")
                    if dict["employee_type"] as! String == "2" {
          //        utilityMgr.setUDVal(val: self.tfCompanyname.text!, forKey: "employee_company")
                    }
                    utilityMgr.setUDVal(val: dict["token"]!, forKey: "token")
                    utilityMgr.setUDVal(val: true, forKey: "isLogin")
                    
                    // user info
                    Crashlytics.sharedInstance().setUserIdentifier(dict["employeeid"] as? String)
                    Crashlytics.sharedInstance().setUserName(TimeZone.current.identifier)
                    
                    UserDefaults.standard.synchronize()
                    if dict["employee_type"] as! String == "3" {
                        DispatchQueue.global(qos: .background).async {
                            self.webserviceCall(param: nil, link: UrlConstants.BASE_URL+UrlConstants.get_section_accesses)
                        }
                    }else{
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeScreen"), object: nil)
                        }
                        
                    }
                    
                    //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeScreen"), object: nil)
                }
            }, failure: { (error) in
                self.password.removeAll()
                self.clearlabels()
                self.crossBtn.isUserInteractionEnabled = true
                self.forgotBtn.isUserInteractionEnabled = true
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            } )
        }else{
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "get_section_accesses"{
                    // 1....medication creation or modification 2...schedule creation or modification 3..user creation or modification 4..profile creation or modification.
                    print("response for (get_section_accesses) api .\(response)")
                    if let innerDict = response["access"] as? [String: Any]{
                        if let stringData = innerDict["section_roles"] as? String{
                            print("inner string is \(stringData)")
                            let defaults = UserDefaults.standard
                            defaults.set(stringData, forKey: "sectionAccess")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HomeScreen"), object: nil)
                        }
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }

    }
    
    private func clearlabels(){
        labl1.backgroundColor = UIColor.lightGray
        labl2.backgroundColor = UIColor.lightGray
        labl3.backgroundColor = UIColor.lightGray
        labl4.backgroundColor = UIColor.lightGray
        labl5.backgroundColor = UIColor.lightGray
        labl1.text = ""
        labl2.text = ""
        labl3.text = ""
        labl4.text = ""
        labl5.text = ""
    }
    @objc private func clearPasswrd(){
        NotificationCenter.default.removeObserver("ClearPassword")
        clearlabels()
        clearPassword()
        self.password.removeAll()
    }
    // MARK:- Text field callback
    func textFieldDidChange(_ textField: UITextField) {
//        if (textField.text?.characters.count)! > 0 {
//            let param = ["keyword":textField.text!]
//            self.webserviceCall(param: param,link:UrlConstants.BASE_URL+UrlConstants.search_company)
//        } else {
//            tblCompanies.isHidden = true
//        }
        
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.numberPadView.isHidden = true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        view.endEditing(true)
        self.numberPadView.isHidden = false
        textField.resignFirstResponder()
        return true
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        }
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.text = (companyArray[indexPath.row] as AnyObject)["company_name"] as? String
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.textAlignment = .center
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        company_id = (companyArray[indexPath.row] as AnyObject)["company_id"] as? String
        tfCompanyname.text = (companyArray[indexPath.row] as AnyObject)["company_name"] as? String
        tableView.isHidden = true
    }
    // MARK:- IBActions
    @IBAction func login(_ sender: UIButton) {
        print("Device Token..\(String(describing: utilityMgr.getUDVal(forKey: "devicetoken")))")
        self.dismissKeyboard()
//        if company_id == nil {
////            kAlertView(title: APPNAME, message: Constants.Register.VALID_COMPANY)
//        } else
            if (tfEmployeeId.text?.isEmpty)! || (tfPassword.text?.isEmpty)! {
               
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
                // check valid email.
                if isValidEmail(testStr: tfEmployeeId.text!){
                    DispatchQueue.global(qos: .background).async {
                        utilityMgr.showIndicator()
                        let param = ["company_id":"1","employee_number":self.tfEmployeeId.text!,"employee_password":self.tfPassword.text!,"device_type":1,"device_token":utilityMgr.getUDVal(forKey: "devicetoken") ?? 123,"timezone":TimeZone.current.identifier] as [String : Any] //self.company_id!
                        print(param)
                        self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.employee_login)
                    }
                }else{
                    self.password.removeAll()
                    self.clearlabels()
                    kAlertView(title: APPNAME, message: Constants.Register.EMAIL_VALIDATION_MESSAGE)
                }
        }
    }
  
    // E_mail validation.
   private func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
  
    //MARK:- Keypad action for password field.
    @IBAction func keypadAction(_ sender: UIButton) {
        if sender.tag == 10{
            clearPassword()
        }else if sender.tag == 11 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPassword") as! ForgotPassword
            self.pushview(objtype: vc)
        }else{
        
             self.addPassword(string: (sender.titleLabel?.text!)!)
        }
       
    }
    //MARK:- Add password digits and change color of password dots.
    private func addPassword(string:String){
        if labl1.text == ""{
            labl1.backgroundColor = APP_COLOR_BLUE
            labl1.text = string
            password.append(string)
            labl1.textColor = UIColor.clear
        }else if labl2.text == ""{
            labl2.backgroundColor = APP_COLOR_BLUE
            labl2.text = string
            password.append(string)
            labl2.textColor = UIColor.clear
        }else if labl3.text == ""{
            labl3.backgroundColor = APP_COLOR_BLUE
            labl3.text = string
            password.append(string)
            labl3.textColor = UIColor.clear
        }else if labl4.text == ""{
            labl4.backgroundColor = APP_COLOR_BLUE
            labl4.text = string
            password.append(string)
            labl4.textColor = UIColor.clear
        }else if labl5.text == ""{
            labl5.backgroundColor = APP_COLOR_BLUE
            labl5.text = string
            password.append(string)
            labl5.textColor = UIColor.clear
           let pass =  password.joined(separator: "")
            print(pass)
            login(passwrd: pass)
        }
         print(password)
    }
    //MARK:- Clear password digit when pressing cancel button on numberPad.
    private func clearPassword(){
        if labl5.text != ""{
            labl5.backgroundColor = UIColor.lightGray
            labl5.text = ""
            password.remove(at: 4)
            labl5.textColor = UIColor.clear
        }else if labl4.text != ""{
            labl4.backgroundColor = UIColor.lightGray
            labl4.text = ""
            password.remove(at: 3)
            labl4.textColor = UIColor.clear
        }else if labl3.text != ""{
            labl3.backgroundColor = UIColor.lightGray
            labl3.text = ""
            password.remove(at: 2)
            labl3.textColor = UIColor.clear
        }else if labl2.text != ""{
            labl2.backgroundColor = UIColor.lightGray
            labl2.text = ""
            password.remove(at: 1)
            labl2.textColor = UIColor.clear
        }else if labl1.text != ""{
            labl1.backgroundColor = UIColor.lightGray
            labl1.text = ""
            password.remove(at: 0)
            labl1.textColor = UIColor.clear
        }
        print(password)
    }
    //MARK:- Round password labels.
    private func roundlabels(){
    labl1.layer.cornerRadius = labl1.frame.size.height/2
    labl1.clipsToBounds = true
        labl2.layer.cornerRadius = labl2.frame.size.height/2
        labl2.clipsToBounds = true
        labl3.layer.cornerRadius = labl3.frame.size.height/2
        labl3.clipsToBounds = true
        labl4.layer.cornerRadius = labl4.frame.size.height/2
        labl4.clipsToBounds = true
        labl5.layer.cornerRadius = labl5.frame.size.height/2
        labl5.clipsToBounds = true
        
    }
    //MARK:- Auto login after entering 5th digit of password.
    private func login(passwrd:String){
        if (tfEmployeeId.text?.isEmpty)!{
            self.password.removeAll()
            self.clearlabels()
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        } else {
            // check valid email.
            if isValidEmail(testStr: tfEmployeeId.text!){
                DispatchQueue.global(qos: .background).async {
                    utilityMgr.showIndicator()
                    let param = ["company_id":"1","employee_number":self.tfEmployeeId.text!,"employee_password":passwrd,"device_type":1,"device_token":utilityMgr.getUDVal(forKey: "devicetoken") ?? 123,"timezone":TimeZone.current.identifier] as [String : Any] //self.company_id!
                    print(param)
//                    self.crossBtn.isUserInteractionEnabled = true
//                    self.forgotBtn.isUserInteractionEnabled = true
                    self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.employee_login)
                }
            }else{
                kAlertView(title: APPNAME, message: Constants.Register.EMAIL_VALIDATION_MESSAGE)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
