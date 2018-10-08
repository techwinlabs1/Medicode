//
//  InboxVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/5/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class InboxVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblInbox: UITableView!
    private var inboxArray : [Inbox] = [Inbox]()
     var messageCount = "0"
    
   // Mark:- View lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = utilityMgr.getUDVal(forKey: "employee_type") as! String
        if (currentUser == "2")||(currentUser == "3") {
             utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: UIImage(named:"plus-white"),titleText: "Inbox", controller: self, isReveal : true)
        }else if (currentUser == "1"){//||(currentUser == "3")
           utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil ,titleText: "Inbox", controller: self, isReveal : true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        isInboxScreen = true   // just for checking is user on inbox screen or not, for handling APNS
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            var link = UrlConstants.BASE_URL+UrlConstants.get_MessageInbox
            if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3") {
                link = UrlConstants.BASE_URL+UrlConstants.get_ManagerMessageInbox+"1"
            }
            self.webserviceCall(link: link)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
       isInboxScreen = false
    }
    // MARK:- Server Calls
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            print(response)
            utilityMgr.hideIndicator()
            print(response)
            let methodName = response["method"] as! String
            if methodName == "get_MessageInbox" {
                DispatchQueue.main.async {
                    self.inboxArray.removeAll()
                    for i in 0..<(response["data"] as! NSArray).count {
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let inb = Inbox()
                        inb.message = dict["message"] as? String
                        inb.sent_date = dict["sent_date"] as? String
                        inb.new_messages = dict["new_messages"] as? String
                        inb.employee_name = dict["employee_name"] as? String
                        inb.receiver_id = dict["receiver_id"] as? String
                        inb.employee_picture = dict["employee_picture"] as? String
                        self.inboxArray.append(inb)
                    }
                    self.tblInbox.reloadData()
                }
            } else if methodName == "get_ManagerMessageInbox" {
                DispatchQueue.main.async {
                    self.inboxArray.removeAll()
                    for i in 0..<(response["data"] as! NSArray).count {
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let inb = Inbox()
                        inb.message = dict["message"] as? String
                        inb.sent_date = dict["sent_date"] as? String
                        inb.new_messages = dict["new_messages"] as? String
                        inb.employee_name = dict["employee_name"] as? String
                        inb.receiver_id = dict["receiver_id"] as? String
                        inb.employee_picture = dict["employee_picture"] as? String
                        self.inboxArray.append(inb)
                    }
                    self.tblInbox.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }

    // Mark:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return inboxArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxCell
        cell.nameLbl.text=inboxArray[indexPath.row].employee_name!
        cell.statusLbl.text=inboxArray[indexPath.row].message!
        cell.messageCountView.tag = indexPath.row
        cell.personImage.sd_setImage(with: URL(string: inboxArray[indexPath.row].employee_picture!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        let messageCount = inboxArray[indexPath.row].new_messages
        if messageCount != "0"{
            cell.messageCountView.viewWithTag(indexPath.row)?.isHidden = false
            cell.messageCountLabel.text = messageCount
            cell.messageCountLabel.textColor = UIColor.white
            cell.messageCountView.backgroundColor = APP_COLOR_BLUE
            cell.messageCountView.layer.cornerRadius = cell.messageCountView.frame.size.height / 2
            cell.messageCountView.clipsToBounds = true
        }else{
            cell.messageCountView.viewWithTag(indexPath.row)?.isHidden = true
        }
        if inboxArray[indexPath.row].sent_date!.characters.count > 0 {
          cell.dateLbl.text=TimeManager.FormatDateString(strDate: inboxArray[indexPath.row].sent_date!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "MMM,d")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         let main_Id = inboxArray[indexPath.row].receiver_id!
        print(main_Id)
        if main_Id == reciever_Id {
           message_Count = "0"
            let cell = tableView.cellForRow(at: indexPath) as! InboxCell
            cell.messageCountView.isHidden = true
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.receiver_id = inboxArray[indexPath.row].receiver_id!
        self.pushview(objtype: vc)
    }
    // MARK:- IBActions
    @IBAction func rightbarAction(){
        let listStaffVC = self.storyboard?.instantiateViewController(withIdentifier: "ListStaffMember") as! ListStaffMember
        self.pushview(objtype: listStaffVC)
    }
    
}
