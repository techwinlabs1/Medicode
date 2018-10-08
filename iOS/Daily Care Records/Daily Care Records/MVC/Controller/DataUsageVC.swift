//
//  DataUsageVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/20/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class DataUsageVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource{
    //MARK:- IBOutlet
    @IBOutlet weak var tblDataUsage: UITableView!
    @IBOutlet weak var datePickerDataUsage: UIDatePicker!
    @IBOutlet weak var pickerDataUsage: UIPickerView!
    @IBOutlet weak var viewPicker: UIView!
    //MARK:- Global Variable
    private var selectedtag = 0
    private var carerArray=[Employee]()
    private var carer=String()
    private var dataUsageArray=[Employee]()
    private var employee_id : String?
    private var dateWiseUsageArray = NSArray()
    var btn = UIButton()
    
    //MARK:- View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Data Usage", controller: self, isReveal : true)
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_UserByUserTypes+"1/1"
            self.webserviceCall(param:nil,link: link)
        }
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
                        self.pickerDataUsage.reloadAllComponents()
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
                        self.tblDataUsage.reloadData()
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dateWiseUsageArray.count > 0 ? 3:2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0{
            return 217
        } else if indexPath.section == 1 {
            return 90
        }
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            return 1
        } else if section == 1 {
            return dataUsageArray.count
        } else {
            return self.dateWiseUsageArray.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.section==0{
            let cell=tableView.dequeueReusableCell(withIdentifier:"DataUsageCell1", for: indexPath) as! DataUsageCell1
            self.btn = cell.btnSubmit
            return cell
        }else if indexPath.section == 1 {
            let cell=tableView.dequeueReusableCell(withIdentifier:"DataUsageCell2", for: indexPath) as! DataUsageCell2
            let url=dataUsageArray[indexPath.row].employee_picture!
            cell.imgCarer.sd_setImage(with: URL(string: url), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
            cell.imgCarer.layer.cornerRadius=cell.imgCarer.frame.size.width/2
            cell.imgCarer.clipsToBounds=true
            cell.lblCarer.text=dataUsageArray[indexPath.row].employee_name
            cell.lblShowDataUsage.text = dataTransformedValue(Double(dataUsageArray[indexPath.row].data!))
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
                cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            }
            for case let lbl as UILabel in (cell?.subviews)! {
                lbl.removeFromSuperview()
            }
            let font = UIFont(name: APP_FONT, size: 13.0)
            let fontColor = UIColor.darkGray
            let alignM = NSTextAlignment.left
            let lblDate = UILabel(frame: CGRect(x: 30, y: 5, width: ScreenSize.SCREEN_WIDTH-60, height: 30))
            lblDate.font = font
            lblDate.textColor = fontColor
            lblDate.textAlignment = alignM
            lblDate.text = "Date - " + ((dateWiseUsageArray[indexPath.row] as AnyObject)["date"] as! String)
            let lblUsage = UILabel(frame: CGRect(x: 30, y: 30, width: ScreenSize.SCREEN_WIDTH-60, height: 30))
            lblUsage.font = font
            lblUsage.textColor = fontColor
            lblUsage.textAlignment = alignM
            lblUsage.text = "Data Usage - " + dataTransformedValue(Double((dateWiseUsageArray[indexPath.row] as AnyObject)["data"] as! String))
            cell?.addSubview(lblDate)
            cell?.addSubview(lblUsage)
            let sep = UILabel(frame: CGRect(x: 30, y: 59, width: ScreenSize.SCREEN_WIDTH-60, height: 1))
            sep.backgroundColor = UIColor(red: 241.0/255.0, green: 242.0/255.0, blue: 240.0/255.0, alpha: 1)
            cell?.addSubview(sep)
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    private func dataTransformedValue(_ value: Any?) -> String {
        var convertedValue: Double = value as! Double
        var multiplyFactor: Int = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return "\(convertedValue.rounded(toPlaces: 2)) \(tokens[multiplyFactor])"
    }
    //MARK:- PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return  carerArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return carerArray[row].employee_name
    }
    //MARK:- IBActions
    @IBAction func btnOpenDatePicker(_ sender: UIButton){
        selectedtag=sender.tag
        datePickerDataUsage.datePickerMode = .date
        datePickerDataUsage.isHidden=false
        pickerDataUsage.isHidden=true
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
    }
    @IBAction func btnDoneSelectedDates(_ sender: UIButton) {
        
    }
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if !datePickerDataUsage.isHidden {
            if sender.tag == 101 {
                let cell : DataUsageCell1? = tblDataUsage.cellForRow(at: IndexPath(row: 0, section: 0)) as! DataUsageCell1?
                if selectedtag == 100 {
                   cell?.btnFromDate.setTitle(TimeManager.FormatDateString(strDate: String(describing:datePickerDataUsage.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"), for: .normal)
                } else {
                    cell?.btnToDate.setTitle(TimeManager.FormatDateString(strDate: String(describing:datePickerDataUsage.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"), for: .normal)
                }
            }
        } else {
            if sender.tag == 101 {
                let cell : DataUsageCell1? = tblDataUsage.cellForRow(at: IndexPath(row: 0, section: 0)) as! DataUsageCell1?
                cell?.btnSelectCarer.setTitle(carerArray[pickerDataUsage.selectedRow(inComponent: 0)].employee_name!, for: .normal)
                employee_id = carerArray[pickerDataUsage.selectedRow(inComponent: 0)].employeeid!
            }
        }
    }
    @IBAction func btnSubmit(_ sender: UIButton) {
            if let cell = tblDataUsage.cellForRow(at: IndexPath(row: 0, section: 0)) as? DataUsageCell1 {
                if cell.btnFromDate.currentTitle! != "DD-MM-YYYY" && cell.btnToDate.currentTitle! != "DD-MM-YYYY" && cell.btnSelectCarer.currentTitle! != "Select Carer" {
                    if btn.isEnabled == true{
                        print("SubmitButton pressed...")
                        btn.isEnabled = false
                    DispatchQueue.global(qos: .userInitiated).async {
                        utilityMgr.showIndicator()
                        let parameter=["page":"1","start":cell.btnFromDate.currentTitle!,"end":cell.btnToDate.currentTitle!,"staffids":self.employee_id!] as [String:Any]
                        self.webserviceCall(param: parameter, link: UrlConstants.BASE_URL+UrlConstants.get_dataUsagesByStaffMember)
                    }
                    }
                }else {
                    kAlertView(title: APPNAME, message: Constants.Register.ALL_REQUIRED_FIELD_MESSAGE)
                }
        }
       
    
    }
    @IBAction func btnOpenPicker(_ sender: UIButton) {
        guard carerArray.isEmpty != true else{return}
        selectedtag=sender.tag
        viewPicker.isHidden=false
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
        datePickerDataUsage.isHidden = true
        pickerDataUsage.isHidden = false
        pickerDataUsage.reloadAllComponents()
    }
}
