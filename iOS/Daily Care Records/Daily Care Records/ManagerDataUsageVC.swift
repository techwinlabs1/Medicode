//
//  ManagerDataUsageVC.swift
//  Medication
//
//  Created by Techwin Labs Mac-3 on 24/08/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ManagerDataUsageVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    //MARK:- Outlets.
    @IBOutlet weak var dropDownMenuView: UIView!
    @IBOutlet weak var dropDownTbl: UITableView!
    @IBOutlet weak var dropDownTblHeight: NSLayoutConstraint!
    @IBOutlet weak var dataTbl: UITableView!
    
    //MARK:- Properties.
    private var selectedtag = 0
    private var carerArray=[Employee]()
    private var carer=String()
    private var dataUsageArray=[Employee]()
    private var employee_id : String?
    private var expandedSection : Int?
    private var dateWiseUsageArray = NSArray()
    var btn = UIButton()
    
    
    
    
    
    //MARK:-  ViewController LifeCycle.
    override func viewDidLoad() {
        super.viewDidLoad()
    dropDownTblHeight.constant = 0
 utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Data Usage", controller: self, isReveal : true)
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_UserByUserTypes+"1/1"
            self.webserviceCall(param:nil,link: link)
        }
        
        
    }

    //MARK:- TableView Delegate and DataSource Methods.
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == dataTbl{
            if dataUsageArray.count == 0{
                return 0
            }else{
                return dataUsageArray.count
            }
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == dropDownTbl{
        return carerArray.count
        }else if (expandedSection != nil && expandedSection == section){
         return dateWiseUsageArray.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == dropDownTbl{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
            cell.textLabel?.text = carerArray[indexPath.row].employee_name
            cell.textLabel?.textAlignment = .center
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManagerDataUsageCell") as! ManagerDataUsageCell
            if indexPath.row == 0{
                cell.dateLbl.text = "Date"
                cell.dataUsageLbl.text = "DataUsage"
                cell.dateLbl.textColor = UIColor.black
                cell.dataUsageLbl.textColor = UIColor.black
                return cell
            }else{
                let indexPath = indexPath.row - 1
                let date = TimeManager.FormatDateString(strDate: (dateWiseUsageArray[indexPath] as AnyObject)["date"] as! String, fromFormat: "yyyy-MM-dd", toFormat: "dd-MM-yyyy")
                cell.dateLbl.text = date
                cell.dataUsageLbl.text = dataTransformedValue(Double((dateWiseUsageArray[indexPath] as AnyObject)["data"] as! String))
                cell.dateLbl.textColor = UIColor.lightGray
                cell.dataUsageLbl.textColor = UIColor.lightGray
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == dataTbl{
            let header = Bundle.main.loadNibNamed(String(describing: "ManagerDataUsageHeader"), owner: self, options: nil)?[0] as! UIView
            let supView:UIView = header.viewWithTag(2000) as! UIView
            let profileImg:UIImageView = supView.viewWithTag(2001) as! UIImageView
            print(dataUsageArray.count)
            profileImg.sd_setImage(with: URL(string: dataUsageArray[section].employee_picture!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
            profileImg.layer.cornerRadius=profileImg.frame.size.width/2
            profileImg.clipsToBounds=true
            let nameLbl:UILabel = supView.viewWithTag(2002) as! UILabel
            nameLbl.text = dataUsageArray[section].employee_name!
            let dataLbl:UILabel = supView.viewWithTag(2003) as! UILabel
//            dataLbl.text = calculateSize(size: Double(dataUsageArray[section].data!)!)
            dataLbl.text = dataTransformedValue(Double(dataUsageArray[section].data!))
            //      let arrowImg:UIImageView = supView.viewWithTag(2004) as! UIImageView
            let tapG : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
            tapG.numberOfTapsRequired = 1
            header.tag = section
            header.addGestureRecognizer(tapG)
            return header
        }
       return nil
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView  == dropDownTbl{
            return 0.0
        }else{
         return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == dropDownTbl{
            employee_id = carerArray[indexPath.row].employeeid
            dropDownTblHeight.constant = 0
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
        let parameter=["page":"1","start":"all","end":"all","staffids":self.employee_id!] as [String:Any]
                self.webserviceCall(param: parameter, link: UrlConstants.BASE_URL+UrlConstants.get_dataUsagesByStaffMember)
            }
        }
    }
    
    
    //MARK:- DropDown button Action.
    @IBAction func dropDownBtn(_ sender: UIButton) {
        dropDownTblHeight.constant = (dropDownTblHeight.constant == 130) ? 0 : 130
    }
    
    // MARK:- Server Calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param == nil {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                print(response)
                let methodName = response["method"] as! String
                if methodName == "get_UserByUserTypes" {
                    let data = response["data"] as! NSArray
                    self.carerArray.removeAll()
                    for i in 0..<data.count{
                        let dict=data[i] as! NSDictionary
                        let addData=Employee()
                        addData.company_id=dict["company_id"] as? String
                        addData.designation=dict["designation"] as? String
                        addData.employee_country_code=dict["employee_country_code"] as? String
                        addData.employee_designation=dict["employee_designation"] as? String
                        addData.employee_email=dict["employee_email"] as? String
                        addData.employee_mobile=dict["employee_mobile"] as? String
                        addData.employee_name=dict["employee_name"] as? String
                        addData.employee_number=dict["employee_number"] as? String
                        addData.employee_picture=dict["employee_picture"] as? String
                        addData.employee_type=dict["employee_type"] as? String
                        addData.employeeid=dict["employeeid"] as? String
                        self.carerArray.append(addData)
                    }
                    DispatchQueue.main.async {
                        self.dropDownTbl.reloadData()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                print(response)
                self.btn.isEnabled = true
                let methodName = response["method"] as! String
                if methodName == "get_dataUsagesByStaffMember"{
                    let data=response["data"] as! NSArray
                    self.dataUsageArray.removeAll()
                    for i in 0..<data.count{
                        let dic=data[i] as! NSDictionary
                        let usedData=Employee()
                        usedData.data=dic["data"] as? String
                        usedData.employee_name=dic["employee_name"] as? String
                        usedData.employee_number=dic["employee_number"] as? String
                        usedData.employee_picture=dic["employee_picture"]as? String
                        usedData.employeeid=dic["employeeid"] as? String
                        self.dataUsageArray.append(usedData)
                    }
                    self.dateWiseUsageArray = (data[0] as AnyObject)["data_usages"] as! NSArray
                    DispatchQueue.main.async {
                        self.dataTbl.reloadData()
                    }
                }
            }, failure: { (error) in
                self.btn.isEnabled = true
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    
    //MARK:- Header Tapped Action.
    func headerTapped(_ sender : UITapGestureRecognizer){
        expandedSection = sender.view?.tag
        dataTbl.reloadData()
    }
    //MARK:- Data Converter Function.
    private func dataTransformedValue(_ value: Any?) -> String {
        var convertedValue: Double = value as! Double  // Double
        print(convertedValue)
        var multiplyFactor: Int = 0
        let tokens = ["KB", "MB", "GB", "TB"] //"bytes",
        while convertedValue >= 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return "\(convertedValue.rounded(toPlaces: 3)) \(tokens[multiplyFactor])"
    }

//    func calculateSize(size:Double)-> String{
//        var str = ""
//        if size >= 1024{
//            let size2:Double = size/1024
//            if size2 >= 1024{
//                let abc = size2/1024
//                let bcd = size2.remainder(dividingBy: 1024)
//                str = "\(abc)"+"."+"\(bcd)"+" GB"
//            }else{
//                let remi = size.remainder(dividingBy: 1024)
//                str = "\(size2)"+"."+"\(remi)"+" MB"
//            }
//        }else{
//           str = String(size)+" KB"
//        }
//       return str
//    }

}
