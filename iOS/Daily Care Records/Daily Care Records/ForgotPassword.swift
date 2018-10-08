//
//  ForgotPassword.swift
//  Medication
//
//  Created by Techwin Labs Mac-3 on 08/08/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ForgotPassword: UIViewController {

    @IBOutlet weak var email_field: UITextField!
    var param = NSMutableDictionary()
    //MARK:- ViewController lifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK:- Send Request button Action.
    @IBAction func sendRequestAction(_ sender: UIButton) {
        if email_field.text == ""{
            self.kAlertView(title: APPNAME, message:Constants.Register.ALL_REQUIRED_FIELD_MESSAGE )
                return
        }
        let param = ["email":email_field.text!]
        utilityMgr.showIndicator()
        self.webserviceCall(link: UrlConstants.BASE_URL+UrlConstants.forgot_password, Param: param)
    }
    
    //MARK:- back button action.
    @IBAction func backToLoginAction(_ sender: UIButton) {
      self.popView()
        
    }
   
  
      //Webservice call function.
    private func webserviceCall(link:String, Param:[String:Any]){
        apiMgr.PostApi(Param, webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            print(response)
            let method = response["method"] as! String
            if method == "forgot_password"{
                print("Forgot password response.")
                let alert = UIAlertController(title: APPNAME, message: response["message"] as! String, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (ok) in
                    self.popView()
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: {(error) in
            utilityMgr.hideIndicator()
            print(error?.localizedDescription)
             self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}// class ends here.
