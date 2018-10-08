//
//  MedicationStatusVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/6/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class MedicationStatusVC: UIViewController,UITextViewDelegate {
    @IBOutlet weak var scrollMedicationStatus: UIScrollView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMedicine: UILabel!
    @IBOutlet weak var viewChoose: UIView!
    @IBOutlet var outButtons: [UIButton]!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var detailTextView: MTextView!
    @IBOutlet weak var title_Lbl: UILabel!
    var title_name = ""
    var client = Client()
    var program = Program()
    var care_time : Int!
    private var status : Int?
    var btn = UIButton()
    private var message = ""
    
    // MARK :- View lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTextView.delegate = self
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Medication Chart", controller: self, isReveal : false)
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        title_Lbl.text = title_name
        hideDetailView()
        lblDate.text = "Date : \(TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"))" //yyyy-MM-dd
        lblMedicine.text = "Medicine : \(program.medicine!)"
        btnSubmit.putShadow()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any],link:String){
        apiMgr.PostApi(param, webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            print(response)
            let methodName = response["method"] as! String
            if methodName == "enter_newMedication" {
                DispatchQueue.main.async {
                    medicineCompleted = true
                    self.popView()
                }
            }
        }) { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        }
    }
    // MARK:- IBActions
    @IBAction func allButtons(_ sender: UIButton) {
        btn = sender
        btn.tag = sender.tag
        print(btn.tag)
        for button in outButtons{
            print(button.tag)
            if button==sender{
                if sender.isSelected==true{
                    status = nil
                    sender.isSelected=false
                    btn.isSelected = false
                } else{
                    status = sender.tag
                    sender.isSelected=true
                    btn.isSelected = true
                    if sender.tag != 1{
                        print("tag is \(sender.tag)")
                        print("Show alert here.")
                        showDetailView()
                    }
                }
            }else{
                button.isSelected=false
            }
        }
    }
    @IBAction func submit(_ sender: UIButton) {
        if status != nil {
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                let param = ["client_id":self.client.client_id!,"program_id":self.client.program_id!,"date":TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd"),"medicine":self.program.medicine!,"care_time":self.care_time,"status":self.status!,"dose":self.program.dose!,"type":self.program.type!,"detail":self.program.detail!,"time":self.client.program_startdate!,"message":self.message] as [String : Any]
                print(param)
                self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.enter_newMedication)
            }
        }else{
            kAlertView(title: APPNAME, message: "Please choose an option.")
        }
    }
    @IBAction func leftbarAction () {
        self.popView()
    }

    @IBAction func continueAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if (detailTextView.text == "")||(detailTextView.text == "Enter Detail"){
            self.kAlertView(title: APPNAME, message: "Please enter text.")
        }else{
            if status != nil {
                DispatchQueue.global(qos: .userInitiated).async {
                    utilityMgr.showIndicator()
                    let param = ["client_id":self.client.client_id!,"program_id":self.client.program_id!,"date":TimeManager.FormatDateString(strDate: String(describing:Date()), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd"),"medicine":self.program.medicine!,"care_time":self.care_time,"status":self.status!,"dose":self.program.dose!,"type":self.program.type!,"detail":self.program.detail!,"time":self.client.program_startdate!,"message":self.message] as [String : Any]
                    print(param)
                    self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.enter_newMedication)
                }
            }
            message = detailTextView.text
            hideDetailView()
        }
    }
    
    @IBAction func cancelAction(_ sender: MButton) {
        hideDetailView()
    }
    
    private func hideDetailView(){
        self.view.endEditing(true)
        self.btnSubmit.isHidden = false
        self.alphaView.isHidden = true
        self.alertView.isHidden = true
        detailTextView.text = ""
        btn.isSelected = false
    }
    private func showDetailView(){
        self.btnSubmit.isHidden = true
        self.alphaView.isHidden = false
        self.alertView.isHidden = false
        detailTextView.text = "Enter Detail"
        detailTextView.textColor = UIColor.lightGray
    }
    
    //MARK:- Text View Delegate..
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == detailTextView{
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }


}
