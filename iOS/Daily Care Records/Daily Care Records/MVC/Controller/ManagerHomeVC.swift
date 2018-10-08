//
//  ManagerHomeVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/16/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ManagerHomeVC: UIViewController, UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var tblClients: UITableView!
    private var clientArray:[Client]=[Client]()
    private var employeeArray:[Employee]=[Employee]()
    var isHome = true
    var editHide = false
    var profileUpdation = false
    var usertype = 0
    @IBOutlet weak var searchBar: UISearchBar!
    private var designation_id : String?
    private var designation : String?
    private var selectedRow:IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        tblClients.register(UINib.init(nibName: "ManageClientCell", bundle: nil), forCellReuseIdentifier: "ManageClientCell")
        if isHome {
            if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
                print("currentLoginUser..\(user)")
                if user == "2"{
                    utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: UIImage(named:"plus-white"),titleText: "Manage Clients", controller: self, isReveal : true)
                }else if user == "3"{
                    if let val = UserDefaults.standard.value(forKey: "sectionAccess") as? String{
                        let convertedArray = val.components(separatedBy: ",")
                        if (convertedArray.contains("3")){
                            editHide = false
                            utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: UIImage(named:"plus-white"),titleText: "Manage Clients", controller: self, isReveal : true)
                        }else{
                            editHide = true
                            utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Manage Clients", controller: self, isReveal : true)
                        }
                     
                    }
                }
            }//            utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: UIImage(named:"plus-white"),titleText: "Manage Clients", controller: self, isReveal : true)
            pageNo = 1
            searchBar.isHidden = false
    
//            getClients(searchText: nil)
        } else {
            // ( 1 for Carer, 2 for manager, 3 for supervisor, 4 for Family, 0 for Outside user)
            var titleStr = ""
            switch usertype {
            case 0:
                titleStr = "Manage Outside Users"
            case 1:
                titleStr = "Manage Carers"
            case 2:
                titleStr = "Manage Managers"
            case 3:
                titleStr = "Manage Supervisors"
            case 4:
                titleStr = "Manage Family"
            default:
                break
            }
            tblClients.translatesAutoresizingMaskIntoConstraints = true
            tblClients.frame = CGRect(x: tblClients.frame.origin.x, y: 0, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT)
            if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
                if user == "2"{
                  utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: UIImage(named:"plus-white"),titleText: titleStr, controller: self, isReveal : false)
                }else if user == "3"{
                    if let val = UserDefaults.standard.value(forKey: "sectionAccess") as? String{
                        let convertedArray = val.components(separatedBy: ",")
                        if (convertedArray.contains("3")){
                            editHide = false
                            utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: UIImage(named:"plus-white"),titleText: titleStr, controller: self, isReveal : false)
                        }else{
                            editHide = true
                            utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: titleStr, controller: self, isReveal : false)
                        }
                    }
                }
            }
            //            utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: UIImage(named:"plus-white"),titleText: titleStr, controller: self, isReveal : false)
            searchBar.isHidden = true
            pageNo = 1
//            getUsers()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                self.getDesignations()
//            })
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //MARK:- check if current login user has access to edit individuals or not
//        if isHome == false {
        if let user = utilityMgr.getUDVal(forKey: "employee_type") as? String{
            print("currentLoginUser..\(user)")
            if user == "3"{
            if let accessTo = UserDefaults.standard.value(forKey: "sectionAccess") as? String{
                let convertedArray = accessTo.components(separatedBy: ",")
                if convertedArray.contains("4"){
                    profileUpdation = false
                }else{
                    profileUpdation = true
                }
            }
        }
        }
        if isHome{
            getClients(searchText: nil)
            if selectedRow != nil{
                self.presentAlert(indexPath: selectedRow!)
            }
        }else{
            getUsers()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.getDesignations()
            })
        }
//        if isHome == false{
//            getUsers()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                self.getDesignations()
//            })
//        }
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    // MARK:- Server calls
    private func getClients(searchText:String?){
        DispatchQueue.global(qos: .userInitiated).async {
            if searchText == nil {
                utilityMgr.showIndicator()
            }
            var link = UrlConstants.BASE_URL+UrlConstants.get_allClients+"\(pageNo)/1"
            if searchText != nil {
                link = UrlConstants.BASE_URL+UrlConstants.get_allClients+"\(pageNo)/1/\(searchText!)"
            }
            self.webserviceCall(param: nil, link: link)
        }
    }
    private func getUsers(){
        DispatchQueue.global(qos: .userInitiated).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_UserByUserTypes+"\(self.usertype)/\(pageNo)"
            self.webserviceCall(param: nil, link: link)
        }
    }
    private func getDesignations(){
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_designationsList
            self.webserviceCall(param: nil, link: link)
        }
    }
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil{
            // Call post api here
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                let methodName = response["method"] as! String
                if methodName == "archive_User"{
                    self.getUsers()
                   
                }
                print("Archive_User response.. \(response)")
            }, failure: { (error) in
                print("Archive_user error.. \(String(describing: error?.localizedDescription))")
                utilityMgr.hideIndicator()
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
            
        }else{
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "get_allClients" {
                    let dataA = response["data"] as! NSArray
                    if pageNo == 1 {
                        self.clientArray.removeAll()
                    }
                    for i in 0..<dataA.count{
                        let dict = dataA[i] as! NSDictionary
                        let cli = Client()
                        cli.client_id = dict["client_id"] as? String
                        cli.company_id = dict["company_id"] as? String
                        cli.firstname = dict["firstname"] as? String
                        cli.lastname = dict["lastname"] as? String
                        cli.dob = dict["dob"] as? String
                        cli.gender = dict["gender"] as? String
                        cli.address = dict["address"] as? String
                        cli.postcode = dict["postcode"] as? String
                        cli.client_picture = dict["client_picture"] as? String
                        cli.emergency_contact = dict["emergency_contact"] as? String
                        cli.personal_information = dict["personal_information"] as? String
                        cli.comments = dict["comments"] as? String
                        cli.latitude = dict["latitude"] as? String
                        cli.longitude = dict["longitude"] as? String
                        cli.created_at = dict["created_at"] as? String
                        cli.updated_at = dict["updated_at"] as? String
                        cli.status = dict["status"] as? String
                        self.clientArray.append(cli)
                    }
                    DispatchQueue.main.async {
                        self.tblClients.reloadData()
                    }
                } else if methodName == "get_UserByUserTypes" {
                    let dataA = response["data"] as! NSArray
                    if pageNo == 1 {
                        self.employeeArray.removeAll()
                    }
                    for i in 0..<dataA.count{
                        let dict = dataA[i] as! NSDictionary
                        let cli = Employee()
                        cli.company_id = dict["company_id"] as? String
                        cli.designation = dict["designation"] as? String
                        cli.employee_country_code = dict["employee_country_code"] as? String
                        cli.employee_designation = dict["employee_designation"] as? String
                        cli.employee_email = dict["employee_email"] as? String
                        cli.employee_mobile = dict["employee_mobile"] as? String
                        cli.employee_name = dict["employee_name"] as? String
                        cli.employee_number = dict["employee_number"] as? String
                        cli.employee_picture = dict["employee_picture"] as? String
                        cli.employee_type = dict["employee_type"] as? String
                        cli.employeeid = dict["employeeid"] as? String
                        self.employeeArray.append(cli)
                    }
                    DispatchQueue.main.async {
                        self.tblClients.reloadData()
                    }
                } else if methodName == "get_designationsList" {
                    switch self.usertype {
                    case 1:
                        self.designation = "carer"
                        for j in 0..<(response["data"] as! NSArray).count {
                            let type = (response["data"] as! NSArray)[j] as! NSDictionary
                            if type["designation"] as! String == "Carer" {
                                self.designation_id = type["designation_id"] as? String
                            }
                        }
                    case 2:
                        self.designation = "Manager"
                        for j in 0..<(response["data"] as! NSArray).count {
                            let type = (response["data"] as! NSArray)[j] as! NSDictionary
                            if type["designation"] as! String == "Manager" {
                                self.designation_id = type["designation_id"] as? String
                            }
                        }
                    case 3:
                        self.designation = "Supervisor"
                        for j in 0..<(response["data"] as! NSArray).count {
                            let type = (response["data"] as! NSArray)[j] as! NSDictionary
                            if type["designation"] as! String == "Supervisor" {
                                self.designation_id = type["designation_id"] as? String
                            }
                        }
                    default:
                        break
                    }
                } else if methodName == "get_section_accesses"{
                    // 1....medication creation or modification 2...schedule creation or modification 3..user creation or modification 4..profile creation or modification.
                    print("response for (get_section_accesses) api .\(response)")
                    if let innerDict = response["access"] as? [String: Any]{
                        if let stringData = innerDict["section_roles"] as? String{
                            print("inner string is \(stringData)")
                            let defaults = UserDefaults.standard
                            defaults.set(stringData, forKey: "sectionAccess")
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isHome {
           return clientArray.count
        }
        return employeeArray.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ManageClientCell! = tableView.dequeueReusableCell(withIdentifier: "ManageClientCell") as! ManageClientCell!
        if isHome {
            cell.imgUser.sd_setImage(with: URL(string: clientArray[indexPath.row].client_picture!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
            cell.lblname.text = clientArray[indexPath.row].firstname! + " " + clientArray[indexPath.row].lastname!
            cell.lblAddress.text = clientArray[indexPath.row].address
            cell.lblzipcode.text = clientArray[indexPath.row].postcode
            cell.lblDob.text = clientArray[indexPath.row].dob
        } else {
            cell.imgUser.sd_setImage(with: URL(string: employeeArray[indexPath.row].employee_picture!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
            cell.lblname.text = employeeArray[indexPath.row].employee_name!
            cell.lblAddress.text = employeeArray[indexPath.row].employee_mobile
            cell.lblzipcode.text = employeeArray[indexPath.row].employeeid
            cell.zipcodePlaceholder.text = "Employee id"
            cell.dobPlaceholder.text = "Email"
            cell.addressPlaceholder.text = "Phone"
            cell.lblDob.text = employeeArray[indexPath.row].employee_email
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if isHome {
            self.selectedRow = indexPath
            self.presentAlert(indexPath:indexPath)
        }
//        else {
//            
//        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isHome
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
       
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            tableView.setEditing(false, animated: true)
            let vc = managerStoryBoard.instantiateViewController(withIdentifier: "CarerProfileVC") as! CarerProfileVC
            vc.titleString = self.employeeArray[editActionsForRowAt.row].employee_name!
            vc.client_id = self.employeeArray[editActionsForRowAt.row].employeeid!
            vc.editingEnabled = true
            self.pushview(objtype: vc)
        }
        edit.backgroundColor = APP_COLOR_BLUE
        let del = UITableViewRowAction(style: .normal, title: "Archive") { action, index in
            print("delete tapped")
            // userid , company_id
            let userid = self.employeeArray[editActionsForRowAt.row].employeeid
            let companyid = self.employeeArray[editActionsForRowAt.row].company_id
            let link = UrlConstants.BASE_URL+UrlConstants.archive_User
            if let userid = userid , let company_id = companyid{
                self.webserviceCall(param: ["userid":userid,"company_id":company_id], link: link)
            }
            
        }
        del.backgroundColor = APP_COLOR_GREEN
            if editHide{
                return [del]
            }else{
                return [del,edit]
            }
//        return [del,edit]
    }
    // MARK:- Searchbar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            pageNo = 1
            getClients(searchText: searchText)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    // MARK:- IBActions
    @IBAction func rightbarAction(){
        if isHome {
            let vc = managerStoryBoard.instantiateViewController(withIdentifier: "AddClientVC") as! AddClientVC
            self.pushview(objtype: vc)
        } else {
            if designation != nil {
                let vc = managerStoryBoard.instantiateViewController(withIdentifier: "AddManagerVC") as! AddManagerVC
                vc.designation = designation!
                vc.designation_id = designation_id!
                vc.userType = String(usertype)
                switch usertype {
                case 0:
                    vc.titleStr = "Add Outside User"
                case 1:
                    vc.titleStr = "Add Carer"
                case 2:
                    vc.titleStr = "Add Manager"
                case 3:
                    vc.titleStr = "Add Supervisor"
                case 4:
                    break
                default:
                    break
                }
                self.pushview(objtype: vc)
            }
            
        }
        
    }
    
    private func presentAlert(indexPath:IndexPath){
        
        let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let marchart = UIAlertAction(title: "MAR Chart", style: .default) { (mar) in
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ViewMedicationVC") as! ViewMedicationVC
            vc.client_id = self.clientArray[indexPath.row].client_id!
            self.pushview(objtype: vc)
        }
        let prog = UIAlertAction(title: "Program of Care", style: .default) { (progr) in
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ProgramCareVC") as! ProgramCareVC
            vc.client_id = self.clientArray[indexPath.row].client_id!
            vc.isManager = true
            self.pushview(objtype: vc)
            
        }
        let daily = UIAlertAction(title: "Daily Records", style: .default) { (dR) in
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "DailyRecordsVC") as! DailyRecordsVC
            vc.client_id = self.clientArray[indexPath.row].client_id!
            vc.client_name =  self.clientArray[indexPath.row].firstname!+""+self.clientArray[indexPath.row].lastname!
            self.pushview(objtype: vc)
        }
        let profile = UIAlertAction(title: "Update Client Profile", style: .default) { (profi) in
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            vc.titleString = self.clientArray[indexPath.row].firstname! + " " + self.clientArray[indexPath.row].lastname!
            vc.editingEnabled = true
            vc.client_id = self.clientArray[indexPath.row].client_id!
            self.pushview(objtype: vc)
        }
        alert.addAction(marchart)
        alert.addAction(prog)
        alert.addAction(daily)
        if profileUpdation == false{
            alert.addAction(profile)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: false, completion: nil)
    }
    
    
    @IBAction func leftbarAction () {
        self.popView()
    }

}
