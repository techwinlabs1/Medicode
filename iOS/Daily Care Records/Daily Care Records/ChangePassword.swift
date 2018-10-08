//
//  ChangePassword.swift
//  Medication
//
//  Created by Techwin Labs Mac-3 on 16/08/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ChangePassword: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var current_Password: UITextField!
    @IBOutlet weak var new_Password: UITextField!
    @IBOutlet weak var confirm_Password: UITextField!
    
    //MARK:- ViewController LifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()
       utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Change Password", controller: self, isReveal : true)
        current_Password.addTarget(self, action: #selector(textField(_:)), for: .editingChanged)
        new_Password.addTarget(self, action: #selector(textField(_:)), for: .editingChanged)
        confirm_Password.addTarget(self, action: #selector(textField(_:)), for: .editingChanged)
        hideKeyboardWhenTappedAround()
    }

    //MARK:- Change PAssword Action.
    @IBAction func change_pass_Action(_ sender: MButton) {
        if current_Password.text == "" || new_Password.text == "" || confirm_Password.text == ""{
            kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
        }else if(new_Password.text != confirm_Password.text){
                confirm_Password.text = ""
            kAlertView(title: APPNAME, message: "Password not matched.")
                return
        }else{
            let param = ["oldpassword":current_Password.text!,"newpassword":confirm_Password.text!]
            let link = UrlConstants.BASE_URL+UrlConstants.change_password
            self.webserviceCall(link:link , param: param)
        }
        
    }
    
    
    //MARK:- Text Field Delegate Methods.
    
   
    @objc func textField(_ textField: UITextField){
        switch textField {
        case current_Password:
            print("Current Password")
            if textField.text?.count == 5{
                new_Password.becomeFirstResponder()
            }
        case new_Password:
            print("New Password")
            if textField.text?.count == 5{
                confirm_Password.becomeFirstResponder()
            }
        case confirm_Password:
            print("Confirm Password")
            if textField.text?.count == 5{
                confirm_Password.resignFirstResponder()
            }
            
        default:
            break
        }
    }
    
    //MARK:- Webservice call method.
    private func webserviceCall(link:String, param:[String:Any]){
        apiMgr.PostApi(param, webserviceURL: link, success: { (response) in
            
            print(response)
            let method = response["method"] as! String
            if method == "change_password"{
                if response["status"] as! Int == 200{
                    self.clearAllFields()
                  self.kAlertView(title: APPNAME, message: response["message"] as! String)
                }
            }
        }, failure: {(error) in
            print(error?.localizedDescription)
            
        })
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
       revealViewController().revealToggle(animated: true)
    }
    //MARK:- Clear All Fields.
    private func clearAllFields(){
        current_Password.text = ""
        new_Password.text = ""
        confirm_Password.text = ""
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}// Class ends here.
