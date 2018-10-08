//
//  HistoryVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/11/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit
import Alamofire

class HistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate {
    @IBOutlet weak var tblHistory: UITableView!
    private var width=CGFloat()
    private var sizeHeight=Int()
    private var historyArray : [History] = [History]()
    
    //MARK:- View lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "My History", controller: self, isReveal : true)
        width=UIScreen.main.bounds.width-113
        pageNo = 1
        getHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    // MARK:- Server Calls
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            let methodName = response["method"] as! String
            if methodName == "get_activityHistoryOfCarer" {
                if pageNo == 1 {
                    self.historyArray.removeAll()
                }
                let data=response["data"] as! NSArray
                print(data)
                for i in 0..<data.count{
                    let dic=data[i] as! NSDictionary
                    let history=History()
                    history.activity=dic["activity"] as? String
                    history.activity_at=dic["activity_at"] as? String
                    history.employeeid=dic["employeeid"] as? String
                    history.history_id=dic["history_id"] as? String
                    history.inserted_id=dic["inserted_id"] as? String
                    history.main_id=dic["main_id"] as? String
                    history.section=dic["section"] as? String
                    history.name=dic["name"] as? String
                    self.historyArray.append(history)
                }
                DispatchQueue.main.async {
                    self.tblHistory.delegate=self
                    self.tblHistory.dataSource=self
                    self.tblHistory.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    private func getHistory(){
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            let link = UrlConstants.BASE_URL+UrlConstants.get_activityHistoryOfCarer+"\(pageNo)"
            self.webserviceCall(link: link)
        }
    }
    // MARK:- Scrollview delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
            pageNo += 1
            getHistory()
        }
    }
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return historyArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        cell.lblDateTime.text=historyArray[indexPath.row].activity_at
        DispatchQueue.main.async {
            cell.imageCarer.layer.cornerRadius=cell.imageCarer.frame.width/2
            cell.imageCarer.clipsToBounds=true
        }
        cell.lblRecord.text=historyArray[indexPath.row].activity
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let constraint = CGSize(width:width, height: CGFloat.greatestFiniteMagnitude)
        var size = CGSize.zero
        let boundingBox: CGSize = (historyArray[indexPath.row].activity?.boundingRect (with: constraint, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15)], context: NSStringDrawingContext()).size)!
        size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        sizeHeight=Int(size.height)
        let height=60
        let totalHeight=height+sizeHeight
        return CGFloat(totalHeight)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch historyArray[indexPath.row].section! {
        case "1":
            // give medication
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterMedicationVC") as! EnterMedicationVC
            vc.titleName = historyArray[indexPath.row].name!
            vc.client_id = historyArray[indexPath.row].main_id!
            self.pushview(objtype: vc)
        case "2":
            // add daily record
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DailyRecordsVC") as! DailyRecordsVC
            vc.client_id = historyArray[indexPath.row].main_id!
            self.pushview(objtype: vc)
        case "3":
            // add a new concern
            break
        case "4":
            print("Chat section has removed.")
            // start chat
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
//            vc.receiver_id = historyArray[indexPath.row].main_id!
//            self.pushview(objtype: vc)
        case "5":
            // profile updation
            break
        case "6":
            // schedule section
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
            vc.selectedDate = TimeManager.FormatDateString(strDate: historyArray[indexPath.row].activity_at!, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "yyyy-MM")
            self.pushview(objtype: vc)
        default:
            break
        }

    }
}
