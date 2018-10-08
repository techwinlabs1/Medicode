//
//  AddDailyRecordVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/11/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class AddDailyRecordVC: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var tblAddRecord: UITableView!
    private var questionArray : [Question] = [Question]()
    var client_id = ""
    var postcode = ""
    var client_name = ""
    private var expandedRow : Int?
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var viewConcern: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var tfSubject: UITextField!
    @IBOutlet weak var txtViewConcern: MTextView!
    @IBOutlet weak var client_id_field: UILabel!
    @IBOutlet weak var post_code_field: UILabel!
    
    private var isConcernPopupShown = false
    private var concern_type = "" //( 0..for regular , 1 for urgent  )
    // MARK:- Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Add Daily Record", controller: self, isReveal : false)
        tblAddRecord.register(UINib.init(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        client_id_field.text = client_name
        post_code_field.text = postcode
        self.txtViewConcern.delegate = self
        isConcernPopupShown = false
        btnSubmit.putShadow()
        tfSubject.attributedPlaceholder = NSAttributedString(string: "  Enter Subject", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            let link = UrlConstants.BASE_URL+UrlConstants.get_dailyRecordsQuestions
            self.webserviceCall(param: nil, link: link)
        }
    }
    // MARK:- Server Calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "add_DailyRecords" {
                    DispatchQueue.main.async {
                        self.popView()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "get_dailyRecordsQuestions" {
                    self.questionArray.removeAll()
                    for i in 0..<(response["data"] as! NSArray).count {
                        let ques = Question()
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        ques.question_id = dict["question_id"] as? String
                        ques.question = dict["question"] as? String
                        ques.isactive = dict["isactive"] as? String
                        ques.answer = dict["answer"] as? String
                        self.questionArray.append(ques)
                    }
                    DispatchQueue.main.async {
                        self.tblAddRecord.delegate = self
                        self.tblAddRecord.dataSource = self
                        self.tblAddRecord.reloadData()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    // MARK:- Textview callback
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == self.txtViewConcern{
            if textView.text != ""{
                textView.text = ""
                textView.textColor = UIColor.black
                return true
            }
        }
        return true
    }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        let cell : QuestionCell! = tblAddRecord.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as! QuestionCell!
        cell.txtViewAnswer.text = textView.text
        let oldQues:Question = questionArray[textView.tag]
        let newQues = Question()
        newQues.answer = textView.text
        newQues.question_id = oldQues.question_id
        newQues.isactive = oldQues.question_id
        newQues.question = oldQues.question
        questionArray[textView.tag] = newQues
        
        if textView == self.txtViewConcern{
            if textView.text == ""{
                self.txtViewConcern.text = "Enter Concern"
                self.txtViewConcern.textColor = UIColor.lightGray
            }
        }
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : QuestionCell? = tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as? QuestionCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell") as? QuestionCell
        }
        cell?.btnQuestion.setTitle(questionArray[indexPath.row].question, for: .normal)
        cell?.btnQuestion.titleLabel?.numberOfLines = 0
        let heightOfQues:CGFloat = (cell?.btnQuestion.currentTitle?.stringHeight(with: (cell?.btnQuestion.frame.size.width)! - 20, font: UIFont(name: APP_FONT, size: 15.0)!))!
        cell?.heightQues.constant = heightOfQues + 15
        cell?.btnQuestion.tag = indexPath.row
        cell?.btnQuestion.addTarget(self, action: #selector(expand(_:)), for: .touchUpInside)
        cell?.txtViewAnswer.tag = indexPath.row
        cell?.txtViewAnswer.delegate = self
        cell?.txtViewAnswer.text = questionArray[indexPath.row].answer
        cell?.txtViewAnswer.isHidden = indexPath.row != expandedRow
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       // var height : CGFloat = 0
        if expandedRow != nil && indexPath.row == expandedRow {
            return 140
        } else {
            let ques = questionArray[indexPath.row].question
            let heightOfQues:CGFloat = (ques?.stringHeight(with: ScreenSize.SCREEN_WIDTH - 40, font: UIFont(name: APP_FONT, size: 15.0)!))! + 35
            return heightOfQues
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    // MARK:- IBActions
    @IBAction func submit(_ sender:UIButton){
        tblAddRecord.reloadData()
        var param = [String:AnyObject]()
        param["client_id"] = client_id as AnyObject?
        param["postcode"] = postcode as AnyObject?
        let question_answer = NSMutableArray()
        var isValid:Bool = true
        for i in 0..<questionArray.count - 2{
            if questionArray[i].answer == "" {
                isValid = false
                kAlertView(title: APPNAME, message: "First three questions are mandatory to answer.")
                break
            }
            var dict = [String:Any]()
            dict["question_id"] = questionArray[i].question_id
            dict["answer"] = questionArray[i].answer
            question_answer.add(dict)
        }
        let aData = try! JSONSerialization.data(withJSONObject: question_answer, options: [])
        let aString = String.init(data: aData, encoding: .utf8)
        param["question_answer"] = aString! as AnyObject?
//        if isValid && !isConcernPopupShown {
//            isConcernPopupShown = true
//            let alert = UIAlertController(title: APPNAME, message: Constants.Register.CONCERN_MESSAGE, preferredStyle: .alert)
//            let yes = UIAlertAction(title: "Yes", style: .default, handler: { (y) in
////                self.viewConcern.isHidden = false
//                // show another view here.
//                alert.dismiss(animated: false, completion: nil)
//                let newAlert =  UIAlertController(title: APPNAME, message: "Your Concern is?", preferredStyle: .alert)
//                let urgentConcern = UIAlertAction(title: "UrgentConcern" , style: .default, handler: { (urgent) in
//                     self.viewConcern.isHidden = false
//                    self.txtViewConcern.text = "Enter Concern"
//                    self.txtViewConcern.textColor = UIColor.lightGray
//                    self.concern_type = "1"
//                })
//                let regularConcern = UIAlertAction(title: "RegularConcern", style: .default, handler: { (regular) in
//                   self.viewConcern.isHidden = false
//                    self.txtViewConcern.text = "Enter Concern"
//                    self.txtViewConcern.textColor = UIColor.lightGray
//                    self.concern_type = "0"
//                })
//                newAlert.addAction(urgentConcern)
//                newAlert.addAction(regularConcern)
//                self.present(newAlert, animated: true, completion: nil)
//
//            })
//            let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
//            alert.addAction(yes)
//            alert.addAction(no)
//            self.present(alert, animated: true, completion: nil)
//
//        } else
            if isValid { //&& isConcernPopupShown 
            print(param)
            print(UrlConstants.BASE_URL+UrlConstants.add_DailyRecords)
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.add_DailyRecords)
            }
        }
    }
    @IBAction func expand(_ sender:UIButton){
        expandedRow = sender.tag
        let cell : QuestionCell! = tblAddRecord.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! QuestionCell!
        cell.txtViewAnswer.isHidden = false
        cell.txtViewAnswer.viewWithTag(sender.tag)?.becomeFirstResponder()
        tblAddRecord.reloadData()
    }
    @IBAction func submitPressed(_ sender: UIButton) {
        if txtViewConcern.text != "" && tfSubject.text != "" {
            self.dismissKeyboard()
            DispatchQueue.global(qos: .background).async {
                let param = ["subject":self.tfSubject.text!,"concern":self.txtViewConcern.text!,"concern_type":self.concern_type,"client_id":self.client_id]
                self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.add_NewConcern)
                DispatchQueue.main.async {
                    self.viewConcern.isHidden = true
                    self.btnSubmit.sendActions(for: .touchUpInside)
                }
            }
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        self.dismissKeyboard()
        viewConcern.isHidden = true
    }
    @IBAction func leftbarAction () {
        self.popView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
