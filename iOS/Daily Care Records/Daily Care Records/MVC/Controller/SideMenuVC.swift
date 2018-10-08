//
//  SideMenuVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/4/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    private var menuArray = [String]()
    private var menuImagesArray = [String]()
    @IBOutlet weak var imgProfilePic: MImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var tblMenu: UITableView!
    
    
    var notificationCount = "0"
    var notificationClicked = false
    var messageCount:String?
    // MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tblMenu.register(UINib.init(nibName: "SidemenuCell", bundle: nil), forCellReuseIdentifier: "SidemenuCell")
        self.imgProfilePic.layer.cornerRadius = imgProfilePic.frame.size.height/2
        self.imgProfilePic.clipsToBounds = true
        
        if let company = utilityMgr.getUDVal(forKey: "employee_company") as? String {
            lblUsername.text = utilityMgr.getUDVal(forKey: "employee_name")! as! String + "\n\(company)"
        } else {
           lblUsername.text = utilityMgr.getUDVal(forKey: "employee_name") as? String
        }
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         imgProfilePic.sd_setImage(with: URL(string: utilityMgr.getUDVal(forKey: "employee_picture")! as! String), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        checkUserType()
        searchBarDummy?.isUserInteractionEnabled = false
        if (utilityMgr.getUDVal(forKey: "employee_type")! as! String) == "1"{
             self.webserviceCall(param: nil, link:UrlConstants.BASE_URL+UrlConstants.unread_notification_count)
        }
    }
    private func checkUserType(){
        let type = utilityMgr.getUDVal(forKey: "employee_type")! as! String
        if type == "1" {
            // carer
            if appDel.access == 1 {
                menuArray = ["Search","Schedule","Data Usage","Notifications","Time Sheet","View My History","Profile","Change password","Logout"] //,"Messages" at 2
                menuImagesArray = ["search-med","schedule","data-usage","notification","time-sheet","history","profile","password","logout"] //,"message"
            } else {
                // restriced access
                menuArray = ["Search","Schedule","Profile","Change password","Logout"]
                menuImagesArray = ["clock","schedule","profile","password","logout"]
            }
        } else if type == "2" { //|| type == "3"
            if appDel.access == 1 {
                menuArray = ["Manage Client","Manage User","Schedule","Time Sheet","Data Usage","Access Rights","Profile","Change password","Logout"]//,"Messages" at 4, ,"Notifications" at 6
                menuImagesArray = ["company","employee","schedule","time-sheet","data-usage","collaboration","profile","password","logout"] //,"message", ,"notification"
            } else {
                // restriced access
                menuArray = ["Manage Client","Manage User","Schedule","Profile","Change password","Logout"]
                menuImagesArray = ["company","employee","schedule","profile","password","logout"]
            }
        } else if type == "3"{         // no access for supervisor to Role section
            if appDel.access == 1 {
                menuArray = ["Manage Client","Manage User","Schedule","Time Sheet","Data Usage","Profile","Change password","Logout"] //,"Messages", ,"Notifications" at 6
                menuImagesArray = ["company","employee","schedule","time-sheet","data-usage","profile","password","logout"] //,"message", ,"notification"
            } else {
                // restriced access
                menuArray = ["Manage Client","Manage User","Schedule","Profile","Change password","Logout"]
                menuImagesArray = ["company","employee","schedule","profile","password","logout"]
            }
        }
        tblMenu.reloadData()
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil{
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "logout" {
                DispatchQueue.main.async {
                    utilityMgr.emptyDefaults()
                    NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
            
        }else{
             //Call getApi
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                print(response)
                let methodName = response["method"] as! String
                if methodName == "unread_notification_count"{
//                    self.webserviceCall(param: nil, link:UrlConstants.BASE_URL+UrlConstants.unread_message_count)
                    if let responseData = response["data"] as? [[String: Any]]{
                        for index in 0...responseData.count - 1{
                            let innerDict = responseData[index]
                            let count = innerDict["count"] as! String
                            if self.notificationClicked == false{
                                if count == "" {
                                    self.notificationCount = "0"
                                }else{
                                     self.notificationCount = count
                                }
                            }
                            print(self.notificationCount)
                            DispatchQueue.main.async {
                                self.tblMenu.reloadData()
                            }
                        }
                    }
                } else if methodName == "unread_message_count"{
                    print(response)
                    if let responseData = response["data"] as? [[String: Any]]{
                        for index in 0...responseData.count - 1{
                            let innerDict = responseData[index]
                            let count = innerDict["count"] as! String
                                if count == "" {
                                    self.messageCount = "0"
                                }else{
                                    self.messageCount = count
                                    message_Count = count
                                }
                            DispatchQueue.main.async {
                                self.tblMenu.reloadData()
                            }
                        }
                    }
                }
            }, failure: { (error) in
                
                print("Error..\(String(describing: error?.localizedDescription))")
            })
        }
    }
    // MARK:- Tableview delegate and datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SidemenuCell"
        let cell : SidemenuCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as! SidemenuCell!
        let imgView = cell.viewWithTag(102) as? UIImageView
        let name = cell.viewWithTag(101) as? UILabel
        imgView?.image = UIImage(named: menuImagesArray[indexPath.row])
        name?.text = menuArray[indexPath.row]
        
        if menuArray[indexPath.row] == "Notifications" {
            addBadgeIcon(cell: cell, name: name, notificationCount: notificationCount)
        }else if menuArray[indexPath.row] == "Messages"{
//        addBadgeIcon(cell: cell, name: name, notificationCount: messageCount ?? "0")
        }else{
            addBadgeIcon(cell: cell, name: name, notificationCount: "0")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let revealViewController = self.revealViewController()
        switch menuArray[indexPath.row] {
        case "Search":
           let search = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
           let navVc = UINavigationController(rootViewController: search)
           revealViewController?.pushFrontViewController(navVc, animated: true)
        case "Logout":
            let alert = UIAlertController(title: APPNAME, message: Constants.Register.LOGOUT_MESSAGE, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (y) in
                DispatchQueue.global(qos: .background).async {
                    utilityMgr.showIndicator()
                    self.webserviceCall(param: [:], link: UrlConstants.BASE_URL+UrlConstants.logout)
                    NotificationCenter.default.post(name: Notification.Name("removeTap"), object: nil)
                }
            })
            let can = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(can)
            present(alert, animated: true, completion: nil)
        case "Schedule":
            let sch = self.storyboard?.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
            let navVc = UINavigationController(rootViewController: sch)
            revealViewController?.pushFrontViewController(navVc, animated: true)
        case "Time Sheet":
            if utilityMgr.getUDVal(forKey: "employee_type") as! String == "1" {
                let sch = self.storyboard?.instantiateViewController(withIdentifier: "TimeSheetVC") as! TimeSheetVC
                let navVc = UINavigationController(rootViewController: sch)
                revealViewController?.pushFrontViewController(navVc, animated: true)
            } else if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3") {
                let sch = managerStoryBoard.instantiateViewController(withIdentifier: "ManagerTimeSheet") as! ManagerTimeSheet
                let navVc = UINavigationController(rootViewController: sch)
                revealViewController?.pushFrontViewController(navVc, animated: true)
            }
        case "Messages":
            let sch = self.storyboard?.instantiateViewController(withIdentifier: "InboxVC") as! InboxVC
            let navVc = UINavigationController(rootViewController: sch)
            revealViewController?.pushFrontViewController(navVc, animated: true)
        case "View My History":
            let sch = self.storyboard?.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
            let navVc = UINavigationController(rootViewController: sch)
            revealViewController?.pushFrontViewController(navVc, animated: true)
        case "Manage User":
            let mng = managerStoryBoard.instantiateViewController(withIdentifier: "ManageUserVC") as! ManageUserVC
            let navVc = UINavigationController(rootViewController: mng)
            revealViewController?.pushFrontViewController(navVc, animated: true)
        case "Manage Client" :
            let mng = managerStoryBoard.instantiateViewController(withIdentifier: "ManagerHomeVC") as! ManagerHomeVC
            mng.isHome = true
            let navVc = UINavigationController(rootViewController: mng)
            revealViewController?.pushFrontViewController(navVc, animated: true)
        case "Notifications":
            if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3") {
                let mng = managerStoryBoard.instantiateViewController(withIdentifier: "ManagerNotificationVC") as! ManagerNotificationVC
                notificationCount = "0"
                notificationClicked = true
                let navVc = UINavigationController(rootViewController: mng)
                revealViewController?.pushFrontViewController(navVc, animated: true)
            }else if utilityMgr.getUDVal(forKey: "employee_type") as! String == "1" {
                let dU = managerStoryBoard.instantiateViewController(withIdentifier: "MyDataUsageVC") as! MyDataUsageVC
                dU.isNotification = true
 //               notificationCount = "0"
                let nv = UINavigationController(rootViewController: dU)
                revealViewController?.pushFrontViewController(nv, animated: true)
            }
        case "Data Usage":
            if (utilityMgr.getUDVal(forKey: "employee_type")! as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type")! as! String == "3"){
                let dU = managerStoryBoard.instantiateViewController(withIdentifier: "ManagerDataUsageVC") as! ManagerDataUsageVC//DataUsageVC
                let nv = UINavigationController(rootViewController: dU)
                revealViewController?.pushFrontViewController(nv, animated: true)
            } else if utilityMgr.getUDVal(forKey: "employee_type")! as! String == "1" {
                let dU = managerStoryBoard.instantiateViewController(withIdentifier: "MyDataUsageVC") as! MyDataUsageVC
                dU.isNotification = false
                let nv = UINavigationController(rootViewController: dU)
                revealViewController?.pushFrontViewController(nv, animated: true)
            }
        case "Access Rights":
                let dU = managerStoryBoard.instantiateViewController(withIdentifier: "AccessRightsVC") as! AccessRightsVC
                let nv = UINavigationController(rootViewController: dU)
                revealViewController?.pushFrontViewController(nv, animated: true)
        case "Change password":
            let dU = self.storyboard?.instantiateViewController(withIdentifier: "ChangePassword") as! ChangePassword
            let nv = UINavigationController(rootViewController: dU)
            revealViewController?.pushFrontViewController(nv, animated: true)
        case "Profile":
            let VC = managerStoryBoard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC //CarerProfileVC
//            let titleName = utilityMgr.getUDVal(forKey: "employee_name") as? String
            let id = utilityMgr.getUDVal(forKey: "employeeid") as? String
            VC.employee_id = id
//            VC.client_id = id!
//            VC.editingEnabled = false
//            VC.openedFromSideMenu = true
//            VC.titleString = titleName!
            let nv = UINavigationController(rootViewController: VC)
            revealViewController?.pushFrontViewController(nv, animated: true)
        default:
            break
        }
    }
    //MARK:- Function for adding badgeCountLabel for Notifications & Messages
    func addBadgeIcon(cell: UITableViewCell, name: UILabel?, notificationCount: String?){
       let count = UILabel(frame: CGRect(x: 160, y: (name?.frame.origin.y)!, width: 30, height: 30))
        if notificationCount != "0"{
            print(self.notificationCount)
        count.backgroundColor = APP_COLOR_GREEN //APP_COLOR_BLUE
        count.text = notificationCount    //"1" // static for now
        count.font = UIFont(name: APP_FONT, size: 14.0)
        count.layer.cornerRadius = count.frame.size.width/2
        count.clipsToBounds = true
        count.textColor = UIColor.white
        count.textAlignment = .center
            count.tag = 9999
//        if count.text == "0"{
//            count.isHidden = true
//        }else{
//            count.isHidden = false
//        }
        cell.contentView.addSubview(count)
        }else{
//            cell.contentView.viewWithTag(9999)?.removeFromSuperview()
    for view in cell.contentView.subviews{// remove view with tag 9999, if it added multiple times.
                if view.tag == 9999{
                 cell.contentView.viewWithTag(9999)?.removeFromSuperview()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
