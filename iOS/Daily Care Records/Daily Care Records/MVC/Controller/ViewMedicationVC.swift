//
//  ViewMedicationVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/9/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit
class ViewMedicationVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var scrollMedicationView: UIScrollView!
    @IBOutlet weak var outFrom: UIButton!
    @IBOutlet weak var outTo: UIButton!
    @IBOutlet weak var client_name: UILabel!
    @IBOutlet weak var tblViewMedication: UITableView!
    @IBOutlet weak var btnSubmit: UIButton!
    private var selected=UIButton()
    private var medicationArray:[Medication]=[Medication]()
    var client_id = ""
    var titleString = ""
    @IBOutlet weak var medicationDatePicker: UIDatePicker!
    @IBOutlet weak var viewPicker: UIView!
    var totalPage = 0
    
    //MARK:- View lifeCycles
    override func viewDidLoad(){
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Medication", controller: self, isReveal : false)
        tblViewMedication.register(UINib(nibName: "viewMedicationCell", bundle: nil),forCellReuseIdentifier: "viewMedicationCell")
        outTo.layer.cornerRadius=5
        outFrom.layer.cornerRadius=5
        btnSubmit.layer.cornerRadius=5
        btnSubmit.putShadow()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        client_name.text = titleString
        pageNo = 1
        getClientMedications(startDate: "all", endDate: "all")
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                print(response)
                let methodName = response["method"] as! String
                if methodName == "view_ClientsMedications" {
                    print("page no..\(pageNo)")
                    self.totalPage = Int((response["totalpage"] as? String)!)!
                    print("total page..\(String(describing: self.totalPage))")
                    if pageNo == 1 {
                        self.medicationArray.removeAll()
                    }else {
                        print("Response Data is empty..\(String(describing: response["data"]))")
                    }
                    let data = response["data"] as! NSArray
                    for i in 0..<data.count{
                        let med = Medication()
                        let dict = data[i] as! NSDictionary
                        med.care_time = dict["care_time"] as? String
                        med.client_id=dict["client_id"] as? String
                        med.client_picture=dict["client_picture"] as? String
                        med.detail=dict["detail"] as? String
                        med.dose=dict["dose"] as? String
                        med.employee_name=dict["employee_name"] as? String
                        med.employee_number=dict["employee_number"] as? String
                        med.employee_picture=dict["employee_picture"] as? String
                        med.employeeid=dict["employeeid"] as? String
                        med.firstname=dict["firstname"] as? String
                        med.lastname=dict["lastname"] as? String
                        med.medication_chart_id=dict["medication_chart_id"] as? String
                        med.medication_datetime=dict["medication_datetime"] as? String
                        med.medicine=dict["medicine"] as? String
                        med.message=dict["message"] as? String
                        med.program_id=dict["program_id"] as? String
                        med.status=dict["status"] as? String
                        med.time=dict["time"] as? String
                        med.type=dict["type"] as? String
                        self.medicationArray.append(med)
                    }
                    DispatchQueue.main.async {
                        self.tblViewMedication.reloadData()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    private func getClientMedications(startDate:String,endDate:String){
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            let link = UrlConstants.BASE_URL+UrlConstants.view_ClientsMedications+self.client_id+"/\(pageNo)/\(startDate)/\(endDate)"
            self.webserviceCall(param: nil, link: link)
        }
    }
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        
    }
    //MARK:- tableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return medicationArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "viewMedicationCell", for: indexPath) as! viewMedicationCell
        let urlstring=medicationArray[indexPath.row].employee_picture
        if urlstring == "" {
            let image=UIImage(named:"profile-placeholder")
            cell.imageCarer.image=image
        }else{
            cell.imageCarer.sd_setImage(with: URL(string: urlstring!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        }
        cell.lblCarer.text=medicationArray[indexPath.row].employee_name
        cell.lblMedicineName.text=medicationArray[indexPath.row].medicine
        cell.message.text = medicationArray[indexPath.row].message
        let Status=medicationArray[indexPath.row].status
        switch Status{
        case "1"?:
            cell.lblStatus.text="Administer" //given
        case "2"?:
            cell.lblStatus.text="Prepared"//"refused"
        case "3"?:
            cell.lblStatus.text="prompt"
        case "4"?:
            cell.lblStatus.text="Other"//"damaged/lost"
        default:break
        }
        
        let dateAndTime=medicationArray[indexPath.row].medication_datetime
        print(dateAndTime)
        if dateAndTime != "0000-00-00 00:00:00"{
            cell.lblDate.text=TimeManager.FormatDateString(strDate: dateAndTime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "dd-MM-yyyy") //yyyy-MM-dd in all places
            let time=TimeManager.FormatDateString(strDate: dateAndTime!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "hh:mm:ss a")
            cell.lblTime.text=time
            
            return cell
        }else{
            cell.lblDate.text = "00:00:00"
            cell.lblTime.text = "00:00:00"
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let vc = managerStoryBoard.instantiateViewController(withIdentifier: "CarerProfileVC") as! CarerProfileVC
//        vc.titleString = medicationArray[indexPath.row].employee_name!
//        vc.client_id = medicationArray[indexPath.row].employeeid!
//        self.pushview(objtype: vc)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 //75
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            pageNo += 1
            var start = "all"
            var end = "all"
            if outTo.currentTitle != "dd-mm-yyyy" && outFrom.currentTitle != "dd-mm-yyyy" {
                start = outFrom.currentTitle!
                end = outTo.currentTitle!
            }
            getClientMedications(startDate: start, endDate: end)
        }
    }
    // MARK:- IBActions
    @IBAction func submitPressed(_ sender: UIButton) {
        if outTo.currentTitle != "dd-mm-yyyy" && outFrom.currentTitle != "dd-mm-yyyy" {
            print("page no..\(pageNo)")
            print("total page..\(String(describing: totalPage))")
            if pageNo > totalPage{
                pageNo = 1
            }
            getClientMedications(startDate: outFrom.currentTitle!, endDate: outTo.currentTitle!)
        }
    }
    @IBAction func leftbarAction () {
        self.popView()
    }
    @IBAction func fromDate(_ sender: UIButton) {
        self.selected=sender
        view.bringSubview(toFront: medicationDatePicker)
        dismissKeyboard()
        viewPicker.frame = CGRect(x: viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT, width: viewPicker.frame.size.width, height: viewPicker.frame.size.height)
        viewPicker.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.viewPicker.frame = CGRect(x: self.viewPicker.frame.origin.x, y: ScreenSize.SCREEN_HEIGHT - self.viewPicker.frame.size.height, width: self.viewPicker.frame.size.width, height: self.viewPicker.frame.size.height)
        }, completion: nil)
    }
    @IBAction func dismissPicker(_ sender: UIButton) {
        viewPicker.isHidden = true
        let strDate = TimeManager.FormatDateString(strDate: String(describing:medicationDatePicker.date), fromFormat: DEFAULT_DATE_FROM, toFormat: "dd-MM-yyyy")
        if selected == outFrom{
            outFrom.setTitle(strDate, for: .normal)
        }else{
            outTo.setTitle(strDate, for: .normal)
        }
    }
}

