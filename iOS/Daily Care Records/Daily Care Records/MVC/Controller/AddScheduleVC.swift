//
//  AddScheduleVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/17/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit
class CarerList:NSObject{
    var employee_name:String?
    var employee_number:String?
    var employeeid:String?
}
class AddScheduleVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    //MARK:- IBOutlet
    @IBOutlet weak var scrollAddSchedule: UIScrollView!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var btnStartTime: UIButton!
    @IBOutlet weak var btnEndTime: UIButton!
    @IBOutlet weak var btnClientName: UIButton!
    @IBOutlet weak var btnStaffName: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var pickerContainView: UIView!
    @IBOutlet weak var arrowStaffName: UIButton!
    @IBOutlet weak var arrowClientName: UIButton!
    @IBOutlet weak var datePickerSchedule: UIDatePicker!
    @IBOutlet weak var pickerSchedule: UIPickerView!
    @IBOutlet weak var viewPicker: UIView!
    
    //MARK:- Global Variables
    private var hiddenPicker=true
    private var hiddenPickerDate=true
    private var selected=UIButton()
    private var clientArray=[Client]()
    private var date=String()
    var startTime=String()
    var endTime=String()
    private var carerArray=[Employee]()
    var clientId=String()
    var employeeId=String()
    var previousSelectedDate:Date?
    var client_name:String?
    var staff_name:String?
    var schedule_id:String?
    
    //MARK:- View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSubmit.putShadow()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Add Schedule", controller: self, isReveal : false)
        datePickerSchedule.minimumDate = Date()
        if previousSelectedDate != nil {
            btnDate.setTitle(TimeManager.FormatDateString(strDate: String(describing:previousSelectedDate!), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"), for: .normal)
            print("date..\(date)")
            date=TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy")
            DispatchQueue.global(qos: .background).async {
                let link = UrlConstants.BASE_URL+UrlConstants.get_allClients+"1/"+self.date
                self.webserviceCall(param: nil, link: link)
            }
            hiddenPickerDate=true
        }
        if schedule_id != nil {
            print("date..\(date)")
            date = TimeManager.FormatDateString(strDate: startTime, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "dd-MM-yyyy")
             print("date after formatting..\(date)")
            startTime = TimeManager.FormatDateString(strDate: startTime, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "HH:mm:ss")
            endTime = TimeManager.FormatDateString(strDate: endTime, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "HH:mm:ss")
            btnDate.setTitle(date, for: .normal)
            btnStartTime.setTitle(startTime, for: .normal)
            btnEndTime.setTitle(endTime, for: .normal)
            btnClientName.setTitle(client_name, for: .normal)
            btnStaffName.setTitle(staff_name, for: .normal)
            DispatchQueue.global(qos: .background).async {
                let link = UrlConstants.BASE_URL+UrlConstants.get_allClients+"1/"+self.date
                self.webserviceCall(param: nil, link: link)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            let link = UrlConstants.BASE_URL+UrlConstants.get_allClients+"1/"+self.date
            self.webserviceCall(param: nil, link: link)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- PickerView Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if selected==btnDate || selected==arrowClientName{
            print(clientArray.count)
            return clientArray.count
        }else if selected==btnEndTime || selected==arrowStaffName{
            print(carerArray.count)
            return carerArray.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        if selected==btnDate || selected==arrowClientName {
            return("\(self.clientArray[row].firstname!) \(self.clientArray[row].lastname!)")
        }else if selected==btnEndTime || selected==arrowStaffName{
            return (carerArray[row].employee_name)
        }
        return nil
    }
    // MARK:- Server Calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "create_NewSchedule" {
                    print(response)
                    self.popView()
                    self.kAlertView(title: APPNAME, message: "Schedule Created")
                } else if methodName == "update_Schedule" {
                    print(response)
                    self.popView()
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                print(response)
                utilityMgr.hideIndicator()
                print(response)
                let methodName = response["method"] as! String
                if methodName == "get_allClients" {
                    let data=response["data"] as! NSArray
                    self.clientArray.removeAll()
                    for i in 0..<data.count{
                        let dict=data[i] as! NSDictionary
                        let schedule=Client()
                        schedule.address=dict["address"] as? String
                        schedule.client_id=dict["client_id"] as? String
                        schedule.client_picture=dict["client_picture"] as? String
                        schedule.comments=dict["comments"] as? String
                        schedule.company_id=dict["company_id"] as? String
                        schedule.created_at=dict["created_at"] as? String
                        schedule.dob=dict["dob"] as? String
                        schedule.emergency_contact=dict["emergency_contact"] as? String
                        schedule.firstname=dict["firstname"] as? String
                        schedule.gender=dict["gender"] as? String
                        schedule.lastname=dict["lastname"] as? String
                        schedule.latitude=dict["latitude"] as? String
                        schedule.longitude=dict["longitude"] as? String
                        schedule.personal_information=dict["personal_information"] as? String
                        schedule.postcode=dict["postcode"] as? String
                        schedule.status=dict["status"] as? String
                        schedule.updated_at=dict["updated_at"] as? String
                        self.clientArray.append(schedule)
                    }
                    print(self.clientArray.count)
                } else if methodName == "getListOfCarerAvailableForSchedule" {
                    print(response)
                    let data=response["data"] as! NSArray
                     self.carerArray.removeAll()
                    if data.count == 0{
                        self.kAlertView(title: APPNAME, message: "No client Available.")
                        return
                    }
                    for i in 0..<data.count{
                        let dict=data[i] as! NSDictionary
                        let emp=Employee()
                        emp.employee_name=dict["employee_name"] as? String
                        emp.employee_number=dict["employee_number"] as? String
                        emp.employeeid=dict["employeeid"] as? String
                        self.carerArray.append(emp)
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    //MARK:- IBAction
    @IBAction func btnOpenPicker(_ sender: UIButton) {
        if (sender.tag==3)||(sender.tag==5){
            guard btnStartTime.currentTitle != "Start Time"else{
                self.kAlertView(title: APPNAME, message: "Please fill Start Time fields")
                return
            }
            guard btnEndTime.currentTitle != "End Time"else{
            self.kAlertView(title: APPNAME, message: "Please fill End Time fields")
                return
            }
            guard clientArray.isEmpty != true else{
                return
                
            }
            selected = arrowClientName
            }
        else if (sender.tag==4)||(sender.tag==6){
            guard carerArray.isEmpty != true else{
                self.kAlertView(title: APPNAME, message: "Please fill above fields")
                return
                
            }
           selected = arrowStaffName
        }
        if hiddenPicker==true{
            if sender.tag == 5{
                selected = arrowClientName
            }else if sender.tag == 6{
              selected = arrowStaffName
            }else{
                selected=sender
            }
            viewPicker.isHidden=false
            view.bringSubview(toFront: viewPicker)
            dismissKeyboard()
            viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
            viewPicker.isHidden = false
            UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
                self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
            }, completion: nil)
            datePickerSchedule.isHidden = true
            pickerSchedule.isHidden = false
            hiddenPicker=false
            hiddenPickerDate=true
            pickerSchedule.reloadAllComponents()
            
        }else{
            if sender.tag == 3{
                selected = arrowClientName
            }else if sender.tag == 4{
                selected = arrowStaffName
            }else{
                selected=sender
            }
            viewPicker.isHidden=true
            hiddenPicker=true
        }
    }
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        if !datePickerSchedule.isHidden {
            if selected==btnDate{
                btnDate.setTitle(TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy"), for: .normal)
                date=TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "yyyy-MM-dd")
                DispatchQueue.global(qos: .background).async {
                    let link = UrlConstants.BASE_URL+UrlConstants.get_allClients+"1/"+self.date
                    self.webserviceCall(param: nil, link: link)
                }
                hiddenPickerDate=true
            }else {
                if selected==btnStartTime{
                    btnStartTime.setTitle(TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm:ss"), for: .normal)
                    startTime=TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm:ss")
                    hiddenPickerDate=true
                }else{
                    btnEndTime.setTitle(TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm:ss"), for: .normal)
                    endTime=TimeManager.FormatDateString(strDate: String(describing:datePickerSchedule.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "HH:mm:ss")
                    hiddenPickerDate=true
                }
            }
        } else {
            if selected==arrowClientName{
                btnClientName.setTitle("\(String(describing: clientArray[pickerSchedule.selectedRow(inComponent:0)].firstname!)) \(String(describing: clientArray[pickerSchedule.selectedRow(inComponent:0)].lastname!))", for: .normal)
                clientId=clientArray[pickerSchedule.selectedRow(inComponent:0)].client_id!
                DispatchQueue.global(qos: .background).async {
                    let date = TimeManager.FormatDateString(strDate: self.date, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd")
                    let link = UrlConstants.BASE_URL+UrlConstants.getListOfCarerAvailableForSchedule+date+"%20"+self.startTime+"/"+date+"%20\(self.endTime)"
                    print(link)
                    self.webserviceCall(param: nil, link: link)
                }
                viewPicker.isHidden=true
                hiddenPicker=true
                guard carerArray.isEmpty != true else{
                    return
                }
                selected=arrowStaffName
            }else{
                btnStaffName.setTitle(carerArray[pickerSchedule.selectedRow(inComponent:0)].employee_name, for: .normal)
                employeeId=carerArray[pickerSchedule.selectedRow(inComponent:0)].employeeid!
                viewPicker.isHidden=true
                hiddenPicker=true
            }
        }
    }
    
    @IBAction func btnDatePicker(_ sender: UIButton) {
        if  hiddenPickerDate==true{
            if sender.tag==1{
                selected=sender
                btnDateData(datePicker:datePickerSchedule, datePickerMode:.date)
            }
            else if sender.tag==2{
//                guard clientArray.isEmpty != true else{
//                    return
//                }
                selected=sender
                btnDateData(datePicker:datePickerSchedule, datePickerMode:.time)
            }else{
//                guard clientArray.isEmpty != true else{
//                    return
//                }
                selected=sender
                btnDateData(datePicker:datePickerSchedule, datePickerMode:.time)
            }
        }else{
            viewPicker.isHidden=true
            hiddenPickerDate=true
        }
    }
    private func btnDateData(datePicker:UIDatePicker,datePickerMode:UIDatePickerMode){
        datePicker.datePickerMode = datePickerMode
        viewPicker.isHidden=false
        view.bringSubview(toFront: viewPicker)
        dismissKeyboard()
        viewPicker.frame = CGRect.init(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect.init(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
        datePickerSchedule.isHidden = false
        pickerSchedule.isHidden = true
    }
    @IBAction func btnSubmitDone(_ sender: UIButton) {
        if schedule_id == nil {
            guard selected==arrowStaffName else{
                self.kAlertView(title: APPNAME, message: "Please fill all fields")
                return
            }
             let date = TimeManager.FormatDateString(strDate: self.date, fromFormat: "dd-MM-yyyy", toFormat: "yyyy-MM-dd")
            let parameter=["start_datetime":"\(date) \(startTime)","end_datetime":"\(date) \(endTime)","employeeid":employeeId,"client_id":clientId]
            print("Add ScheduleParameters:- \(parameter)")
            DispatchQueue.global(qos: .background).async {
                utilityMgr.showIndicator()
                self.webserviceCall(param: parameter, link: UrlConstants.BASE_URL+UrlConstants.create_NewSchedule)
            }
        } else {
            var param = [String:Any]()
            param["schedule_id"] = schedule_id!
            param["start_datetime"] = "\(date) \(startTime)"
            param["end_datetime"] = "\(date) \(endTime)"
            param["employeeid"] = employeeId
            param["client_id"] = clientId
            print(param)
            DispatchQueue.global(qos: .userInitiated).async {
                utilityMgr.showIndicator()
                self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.update_Schedule)
            }
        }
    }
    @IBAction func leftbarAction () {
        self.popView()
    }
}
