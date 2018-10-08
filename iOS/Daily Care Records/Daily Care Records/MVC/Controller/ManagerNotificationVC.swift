//
//  ManagerNotificationVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/18/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ManagerNotificationVC: UIViewController, UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate, UITextViewDelegate {
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var btnFilter: MButton!
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var popUpHeight: NSLayoutConstraint!
    private var notificationArray:[NotificationList] = [NotificationList]()
    private var filter = 1//3
    @IBOutlet weak var notificationPopup: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var txtViewMessage: UITextView!
    private var concern_id:String?
    var lableHeight:CGFloat = 0.0
    var resolveMessageHeight:CGFloat = 0.0
    
    
    // MARK:- View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Notifications", controller: self, isReveal : true)
        tblNotification.register(UINib.init(nibName: "ManagerNotificationCell", bundle: nil), forCellReuseIdentifier: "ManagerNotificationCell")
        pageNo = 1
        // filter (0 for all, 1.open concerns 2.resolved concerns 3. all concerns open and closed, 4.medication not given and 5 care records not done.)
//        getNotifications()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
         getNotifications()
        popUpHeight.constant = 0
    }
    // MARK:- Server calls
    private func getNotifications(){
        DispatchQueue.global(qos: pageNo == 1 ? .userInitiated : .background).async {
            utilityMgr.showIndicator()
            let link = UrlConstants.BASE_URL+UrlConstants.get_ManagerNotifications+"\(pageNo)/\(self.filter)/1"
            self.webserviceCall(link: link)
        }
    }
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_ManagerNotifications" {
                if pageNo == 1 {
                    self.notificationArray.removeAll()
                }
                let data = response["data"] as! NSArray
                print(data)
                for i in 0..<data.count {
                    let dict = data[i] as! NSDictionary
                    let n = NotificationList()
                    n.notifcation_id = dict["notifcation_id"] as? String
                    n.notification_type = dict["notification_type"] as? String
                    n.authority_id = dict["authority_id"] as? String
                    n.carer_id = dict["carer_id"] as? String
                    n.table_id = dict["table_id"] as? String
                    n.status = dict["status"] as? String
                    n.forworded_by = dict["forworded_by"] as? String
                    n.created_at = dict["created_at"] as? String
                    n.notification = NotificationData()
                    n.notification.concern_id = (dict["notification"] as! NSDictionary)["concern_id"] as? String
                    n.notification.employeeid = (dict["notification"] as! NSDictionary)["employeeid"] as? String
                    n.notification.subject = (dict["notification"] as! NSDictionary)["subject"] as? String
                    n.notification.concern = (dict["notification"] as! NSDictionary)["concern"] as? String
                    n.notification.closed_by = (dict["notification"] as! NSDictionary)["closed_by"] as? String
                    n.notification.open_at = (dict["notification"] as! NSDictionary)["open_at"] as? String
                    
                    n.notification.employee_name = (dict["notification"] as! NSDictionary)["employee_name"] as? String
                    n.notification.closed_by_emp_number = (dict["notification"] as! NSDictionary)["closed_by_emp_number"] as? String
                    let closedById = (dict["notification"] as! NSDictionary)["closed_by_id"] as? String
                    if closedById != "0"{
                        n.notification.closed_by_id = (dict["notification"] as! NSDictionary)["closed_by_id"] as? String
                    }
                    let message = (dict["notification"] as! NSDictionary)["message"] as? String
                    if message != "0"{
                         n.notification.message = (dict["notification"] as! NSDictionary)["message"] as? String
                    }
                    let status = (dict["notification"] as! NSDictionary)["status"] as? String
                    if status != "0"{
                        n.notification.status = (dict["notification"] as! NSDictionary)["status"] as? String
                    }
                    let date = (dict["notification"] as! NSDictionary)["closed_at"] as? String
                    if date != ""{
                        n.notification.closed_at = TimeManager.FormatDateString(strDate: date!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "dd-MM-yyyy")
                    }
                    n.notification.employee_number = (dict["notification"] as! NSDictionary)["employee_number"] as? String
                    self.notificationArray.append(n)
                }
                DispatchQueue.main.async {
                    self.tblNotification.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func updateNotification(_ param : [String:Any]){
      apiMgr.PostApi(param, webserviceURL: UrlConstants.BASE_URL+UrlConstants.udate_statusOrReplyConcern, success: { (response) in
        utilityMgr.hideIndicator()
        print(response)
        self.viewWillAppear(false)
      }) { (error) in
        print(error?.localizedDescription)
        utilityMgr.hideIndicator()
        print(error ?? 0)
        self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            pageNo += 1
            getNotifications()
        }
    }
    // MARK:- Textview delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "type a message..." {
            textView.text = ""
        }
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : ManagerNotificationCell? = tableView.dequeueReusableCell(withIdentifier: "ManagerNotificationCell") as! ManagerNotificationCell?
        if cell == nil {
            tableView.register(UINib.init(nibName: "ManagerNotificationCell", bundle: nil), forCellReuseIdentifier: "ManagerNotificationCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "ManagerNotificationCell") as! ManagerNotificationCell!
        }
        let date = TimeManager.FormatDateString(strDate: notificationArray[indexPath.row].created_at!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "dd-MM-yyyy")
        let time1 = TimeManager.onlyUTCDatetoLocal(strDate: notificationArray[indexPath.row].created_at!)
//        let time = TimeManager.FormatDateString(strDate: notificationArray[indexPath.row].created_at!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a")
        cell?.time_field.text = time1
        cell?.date_field.text = date
    
        let status = getValue(optional: notificationArray[indexPath.row].notification.status)
        if status == "0"{
            cell?.statusLbl.text = "Open"
        }else if status == "1"{
            cell?.statusLbl.text = "Closed"
             cell?.resolver_name.textColor = APP_COLOR_BLUE
            cell?.supervisorBtn.tag = indexPath.row
            cell?.supervisorBtn.addTarget(self, action: #selector(supervisorBtnClicked(sender:)), for: .touchUpInside)
        }else{
            cell?.statusLbl.text = "---"
        }
        switch filter {
        case 1,2:
            cell?.notificationTypeLbl.text = "Concern"
            cell?.carer_Msg_field.text = notificationArray[indexPath.row].notification.concern//getValue(optional: notificationArray[indexPath.row].notification.employee_name)
        case 3:
            cell?.notificationTypeLbl.text = "Concern"
            cell?.carer_Msg_field.text = notificationArray[indexPath.row].notification.concern// getValue(optional: notificationArray[indexPath.row].notification.employee_name)
        case 4:
            cell?.notificationTypeLbl.text = "Medication not given"
            cell?.carer_Msg_field.text = notificationArray[indexPath.row].notification.concern
        case 5:
            cell?.notificationTypeLbl.text = "Carer record not done"
             cell?.carer_Msg_field.text = "carer record is not done by \(getValue(optional: notificationArray[indexPath.row].notification.employee_name))"
        default:
            break
        }
        cell?.nameLbl.text = getValue(optional: notificationArray[indexPath.row].notification.employee_name)
        cell?.subjectLbl.text = getValue(optional: notificationArray[indexPath.row].notification.subject)
    
        cell?.resolving_Msg.text = notificationArray[indexPath.row].notification.message ?? "--"

        lableHeight = stringHeight(width: (cell?.carer_Msg_field.frame.width)!, font: UIFont(name: "OpenSans", size:11.0)!, post: (getValue(optional: notificationArray[indexPath.row].notification.concern)))
        resolveMessageHeight = stringHeight(width:  (cell?.resolving_Msg.frame.width)!, font: UIFont(name: "OpenSans", size:11.0)!, post: (getValue(optional: notificationArray[indexPath.row].notification.concern)))
        cell?.messageHeight.constant = lableHeight
        cell?.employee_Id.text = notificationArray[indexPath.row].notification.employee_number
        cell?.resolver_id.text = notificationArray[indexPath.row].notification.closed_by_id ?? "--"
      cell?.resolving_date.text = notificationArray[indexPath.row].notification.closed_at ?? "--"
        cell?.resolver_name.text = notificationArray[indexPath.row].notification.closed_by ?? "--"
     cell?.employee_id_click.tag = indexPath.row
        cell?.employee_id_click.addTarget(self, action: #selector(openProfile(sender:)),for: .touchUpInside)
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 310+lableHeight+resolveMessageHeight //165+lableHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        if filter == 1{
//            concern_id = notificationArray[indexPath.row].notification.concern_id
//            notificationPopup.isHidden = false
//        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let resolve = UITableViewRowAction(style: .normal, title: "Resolve") { (action, index) in
            tableView.setEditing(false, animated: true)
            if self.filter == 1{
                self.concern_id = self.notificationArray[indexPath.row].notification.concern_id
                self.notificationPopup.isHidden = false
                self.txtViewMessage.text = "type a message..."
            }
            
        }
        resolve.backgroundColor = APP_COLOR_GREEN
        return [resolve]
    }
    //MARK:- provide custom height for row
    func stringHeight(width: CGFloat , font : UIFont , post : String) -> CGFloat {
        // let font = UIFont(name: "Helvetica", size: 14)!
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = post.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }

    func getValue(optional:String?)-> String{ // Handle nil value and produce appropriate string
        if let value = optional{
            return value
        }
        return "---"
    }
    
   @IBAction func openProfile(sender:UIButton){
        let VC = managerStoryBoard.instantiateViewController(withIdentifier: "CarerProfileVC") as! CarerProfileVC
        VC.titleString = notificationArray[sender.tag].notification.employee_name!
        VC.client_id = notificationArray[sender.tag].notification.employeeid!
        VC.editingEnabled = false
        self.pushview(objtype: VC)
    }
    
    @IBAction func supervisorBtnClicked(sender:UIButton){
         let VC = managerStoryBoard.instantiateViewController(withIdentifier: "CarerProfileVC") as! CarerProfileVC
        VC.titleString = notificationArray[sender.tag].notification.closed_by!
        VC.client_id = notificationArray[sender.tag].notification.closed_by_id!
        VC.editingEnabled = false
        self.pushview(objtype: VC)
        
    }
    // MARK:- IBActions
    @IBAction func filterPressed(_ sender: MButton) {
        viewFilter.isHidden = !viewFilter.isHidden
        popUpHeight.constant == 70 ? (popUpHeight.constant = 0) : (popUpHeight.constant = 70)
    }
    @IBAction func concernChosen(_ sender: UIButton) {
        // 100 for open, 101 for closes, 102 for all
        viewFilter.isHidden = true
        popUpHeight.constant = 0
        pageNo = 1
        switch sender.tag {
        case 100:
            filter = 1
            btnFilter.setTitle("Open Concerns", for: .normal)
            getNotifications()
        case 101:
            filter = 2
            btnFilter.setTitle("Resolved Concerns", for: .normal) //Closed Concerns
            getNotifications()
        case 102:
            filter = 3//0
            btnFilter.setTitle("All", for: .normal) 
            getNotifications()
        case 103:
            filter = 4
            btnFilter.setTitle("Medication Not Given", for: .normal)
            getNotifications()
        case 104:
            filter = 5
            btnFilter.setTitle("Carer record Not Done", for: .normal)
            getNotifications()
        default:
            break
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        self.dismissKeyboard()
        DispatchQueue.global(qos: .background).async {
            var text = self.txtViewMessage.text
            if (text == "type a message...")||(text == "") {
//                text = ""
                self.kAlertView(title: APPNAME, message: "Please enter message.")
            }else{
                DispatchQueue.main.async {
                    self.notificationPopup.isHidden = true
                    utilityMgr.showIndicator()
                }
                let param = ["concern_id":self.concern_id!,"reply":text!,"status":"1"] as [String : Any]
                print(param)
                self.updateNotification(param)
            }
            
        }
        
    }
    @IBAction func cancel(_ sender: UIButton) {
        notificationPopup.isHidden = true
        self.dismissKeyboard()
    }

}
