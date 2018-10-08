//
//  MyDataUsageVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/25/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class MyDataUsageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tblDataUsage: UITableView!
    private var expandedRow:Int?
    private var expandedArr:NSArray?
    private var data_usagesArr = NSMutableArray()
    var isNotification = false
    private var notificationArr = NSMutableArray()
    private var notificationArray:[NotificationList] = [NotificationList]()
    private var height:CGFloat = 0.0
    private var detailLblHeight:CGFloat = 0.0
    
    // MARK:- View life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: isNotification ? "Notifications" : "Data Usage", controller: self, isReveal : true)
        if !isNotification {
            pageNo = 1
            getDataUsage()
        }
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            let link = UrlConstants.BASE_URL+UrlConstants.get_CarerNotifications+"\(pageNo)"
            self.webserviceCall(link: link)
        }
        // Do any additional setup after loading the view.
    }
   
    // MARK:- Server Calls
    func getDataUsage(){
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            let link = UrlConstants.BASE_URL+UrlConstants.get_MyDataUsages+"\(pageNo)"
            self.webserviceCall(link: link)
        }
    }
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_MyDataUsages" {
                DispatchQueue.main.async {
                    if pageNo == 1 {
                        self.data_usagesArr.removeAllObjects()
                    }
                    for i in 0..<(response["data"] as! NSArray).count {
                        self.data_usagesArr.add((response["data"] as! NSArray)[i])
                    }
                    self.tblDataUsage.reloadData()
                }
            } else if methodName == "get_CarerNotifications"{
                  print(response)
                if pageNo == 1 {
                    self.notificationArray.removeAll()
                }
                let data = response["data"] as! NSArray
                print(data.count)
                
                for i in 0..<data.count{
                    let dict = data[i] as! NSDictionary
                   
                    let notificationObj = NotificationList()
                    notificationObj.authority_id = dict["authority_id"] as? String
                    notificationObj.carer_id = dict["carer_id"] as? String
                    notificationObj.notifcation_id = dict["carer_notification_id"] as? String
                    notificationObj.created_at = dict["created_at"] as? String
                    notificationObj.status = dict["is_read"] as? String
                    notificationObj.main_id = dict["main_id"] as? String
                    notificationObj.notification_type = dict["notification_type"] as? String
                    notificationObj.table_id = dict["table_id"] as? String
                    if let innerDict = dict["notification"] as? NSDictionary{
                        notificationObj.notification.client_id = innerDict["client_id"] as? String
                        notificationObj.notification.client_name = innerDict["client_name"] as? String
                        notificationObj.notification.created_at = innerDict["created_at"] as? String
                        notificationObj.notification.employee_name = innerDict["employee_name"] as? String
                        notificationObj.notification.employee_number = innerDict["employee_number"] as? String
                        notificationObj.notification.employeeid = innerDict["employeeid"] as? String
                        notificationObj.notification.end_datetime = innerDict["end_datetime"] as? String
                        notificationObj.notification.schedule_id = innerDict["schedule_id"] as? String
                        notificationObj.notification.start_datetime = innerDict["start_datetime"] as? String
                        notificationObj.notification.firstname = innerDict["firstname"] as? String
                        notificationObj.notification.lastname = innerDict["lastname"] as? String
                        notificationObj.notification.postcode = innerDict["postcode"] as? String
                        notificationObj.notification.message = innerDict["message"] as? String
                        notificationObj.notification.reply = innerDict["reply"] as? String
                        self.notificationArray.append(notificationObj)
                    }
                    
                }
                 print("array count..\(self.notificationArray.count)")
                DispatchQueue.main.async {
                    self.tblDataUsage.reloadData()
                    
                }
                
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func dataTransformedValue(_ value: Any?) -> String {
        var convertedValue: Double = value as! Double
        var multiplyFactor: Int = 0
        let tokens = ["KB", "MB", "GB", "TB"] //"bytes",
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return "\(convertedValue.rounded(toPlaces: 2)) \(tokens[multiplyFactor])"
    }
    // MARK:- Tableview delegate and datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return isNotification ? 1 : data_usagesArr.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isNotification {
            if notificationArray.count > 0{
                return notificationArray.count
            }else{
                return 0
            }
        }
        if expandedRow != nil && expandedRow == section {
            return (expandedArr?.count)!
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isNotification {
            return nil
        }
        let header = Bundle.main.loadNibNamed(String(describing: "DataUsageHeader"), owner: self, options: nil)?[0] as! UIView
        let supV : UIView = header.viewWithTag(1000)!
        let dateLbl = supV.viewWithTag(100) as! UILabel
        let totalTime = supV.viewWithTag(203) as! UILabel
        totalTime.isHidden = true
       let date = (data_usagesArr[section] as AnyObject)["date"] as? String
        if date != "0000-00-00"{
            let formattedDate = TimeManager.FormatDateString(strDate: date!, fromFormat: "yyyy-MM-dd", toFormat: "dd-MM-yyyy")
            dateLbl.text = formattedDate
        }else{
            dateLbl.text = "00-00-0000"
        }
        let actualData = dataTransformedValue(Double((data_usagesArr[section] as AnyObject)["total_data"] as! String))
        let actualDataLbl = supV.viewWithTag(101) as! UILabel
        actualDataLbl.text = actualData
        let tapG : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tapG.numberOfTapsRequired = 1
        header.tag = section
        header.addGestureRecognizer(tapG)
        return header
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyDataUsageCell") as! MyDataUsageCell
//        if cell == nil {
//            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//            cell = tableView.dequeueReusableCell(withIdentifier: "cell")
//        }
        if isNotification {
            if notificationArray.count > 0{
                cell.subjectLabel.isHidden = false
                cell.subjectHeader.isHidden = false
                let status = notificationArray[indexPath.row].status
                let type = notificationArray[indexPath.row].notification_type!
                if( type == "5"){
                    cell.subjectLabel.isHidden = false
                    cell.subjectHeader.isHidden = false
                }else{
                    cell.subjectLabel.isHidden = true
                    cell.subjectHeader.isHidden = true
                }
                if status == "0"{
                    cell.detailLabel?.textColor = APP_COLOR_BLUE
                    cell.replyText?.textColor = APP_COLOR_BLUE
                    cell.dateLabel?.textColor = APP_COLOR_BLUE
                    cell.subjectLabel.textColor = APP_COLOR_BLUE
                }else if status == "1"{
                    cell.detailLabel?.textColor = UIColor.black
                    cell.replyText?.textColor = UIColor.black
                    cell.dateLabel?.textColor = UIColor.black
                    cell.subjectLabel.textColor = UIColor.black
                }
                cell.detailLabel?.text = notificationArray[indexPath.row].notification.message
//                print(detailLblHeight)
                cell.replyText.text = notificationArray[indexPath.row].notification.reply
                if let message = cell.replyText.text{
                    detailLblHeight = (message.stringHeight(with: (cell.replyText?.frame.size.width)!, font: UIFont(name: "OpenSans", size: 13.0)!))
                }
                cell.dateLabel?.text = TimeManager.FormatDateString(strDate: notificationArray[indexPath.row].created_at!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "dd-MM-yyyy hh:mm a")//notificationArray[indexPath.row].created_at
                cell.separator.backgroundColor = UIColor.lightGray
            }
            } else {
            if expandedRow == indexPath.section {
                if indexPath.row == 0{
                    cell.dateLabel?.text = "Time\t\t\tDataUsage"
                    cell.dateLabel?.font = UIFont(name: APP_FONT, size: 14.0)
                    cell.dateLabel?.textAlignment = .center
                    cell.dateLabel.textColor = UIColor.black
                    cell.subjectLabel.isHidden = true
                    cell.subjectHeader.isHidden = true
                    return cell
                }
                let date = (expandedArr?[indexPath.row] as AnyObject)["date"] as! String
                let time = "\(TimeManager.FormatDateString(strDate: date, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm a"))"
                let dataU = "\(dataTransformedValue(Double((expandedArr?[indexPath.row] as AnyObject)["data"] as! String)))"
                //            let attributedStr = NSMutableAttributedString(string:time+"\t\(dataU)")
                //            attributedStr.addAttributes([NSFontAttributeName : UIFont.init(name: APP_SEMIBOLD_FONT, size: 13)! , NSForegroundColorAttributeName : UIColor.lightGray], range: NSRange.init(location: 0, length: 7))
                //            attributedStr.addAttributes([NSFontAttributeName : UIFont.init(name: APP_SEMIBOLD_FONT, size: 15)! , NSForegroundColorAttributeName : UIColor.lightGray], range: NSRange.init(location: 17, length: 13))
                cell.dateLabel?.text = time+"\t\t\t\(dataU)"
                cell.dateLabel?.font = UIFont(name: APP_FONT, size: 14.0)
                cell.dateLabel.textColor = UIColor.lightGray
                cell.dateLabel?.textAlignment = .center
                cell.subjectLabel.isHidden = true
                cell.subjectHeader.isHidden = true
                //cell?.textLabel?.attributedText = attributedStr
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isNotification ? .leastNormalMagnitude : 70
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       print(indexPath.row)
        if isNotification{
            if let notificationType = notificationArray[indexPath.row].notification_type{
                if notificationType == "5"{
                    return 90+detailLblHeight
                }else{
                    return 60
                }
            }
        }
        return 40
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        if isNotification{
            let para = ["carer_notification_id":notificationArray[indexPath.row].notifcation_id!]
            print(para)
            DispatchQueue.global(qos: .userInitiated).async {
                    self.sendIsReadStatus(link: UrlConstants.BASE_URL+UrlConstants.Set_CarerNotificationRead, param: para)
            }
            if let notificationtype = notificationArray[indexPath.row].notification_type{
                switch notificationtype{
                    
                case "1": //Add new schedule
                 print(notificationtype)
                    let vc = mainStoryBoard.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
                 let dateConverted = TimeManager.FormatDateString(strDate: notificationArray[indexPath.row].notification.start_datetime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "yyyy-MM-dd")

                 vc.selectedDate = dateConverted
                    self.pushview(objtype: vc)
                    
                case "2": // update schedule
                     print(notificationtype)
                    let vc = mainStoryBoard.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
                    self.pushview(objtype: vc)
                    
                case "3": //client profile update
                     print(notificationtype)
                     let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                     let vc = Storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                     vc.client_id = notificationArray[indexPath.row].notification.client_id!
                     self.pushview(objtype: vc)
                case "4": //program of care update
                     print(notificationtype)
                     let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                     let vc = Storyboard.instantiateViewController(withIdentifier: "ProgramCareVC") as! ProgramCareVC
                     vc.client_id = notificationArray[indexPath.row].notification.client_id!
                     self.pushview(objtype: vc)
                case "5":
                    //MARK:- screens are not available for that type yet.
                     print(notificationtype)
                default : break
                }
            }
            
        }
    }
    //MARK:- provide custom height for row
    func stringHeight(width: CGFloat , font : UIFont , post : String) -> CGFloat {
        // let font = UIFont(name: "Helvetica", size: 14)!
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = post.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- tap gesture selector
    func headerTapped(_ sender : UITapGestureRecognizer){
        expandedRow = sender.view?.tag
        expandedArr = (data_usagesArr[sender.view!.tag] as AnyObject)["data_usages"] as? NSArray
        tblDataUsage.reloadData()
    }
    //MARK:- call Notification is read Api.
    private func sendIsReadStatus(link:String,param:[String:Any]){
        apiMgr.PostApi(param, webserviceURL: link, success: { (response) in
            print(response)
            self.viewDidLoad()
        }) { (error) in
            print(error)
        }
    }
    
}
