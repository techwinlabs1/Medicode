//
//  ListStaffMember.swift
//  Medication
//
//  Created by Techwin Labs Mac-3 on 22/06/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ListStaffMember: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {

    @IBOutlet weak var staffListTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
   
    var staffList:[Inbox] = [Inbox]()
    var searchWord:String = ""
    var totalPage = 0
  
    //MARK:- Lifecycle..
    override func viewDidLoad() {
        super.viewDidLoad()
        
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white"), rightImage: nil, titleText: "Contact List", controller: self, isReveal: false)
     }
  
    override func viewWillAppear(_ animated: Bool) {
        // api call here for get list of all staff.
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            pageNo = 1
            let link = UrlConstants.BASE_URL+UrlConstants.get_allStaffMembers+"\(pageNo)"+"/"+self.searchWord
            self.webserviceCall(link: link)
        }
    }
   
    // MARK:- Table view delegate and datasource method.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListStaffCell", for: indexPath) as! ListStaffCell
        cell.nameLbl.text = staffList[indexPath.row].employee_name
        let imageLink = staffList[indexPath.row].employee_picture
        cell.profilePic.sd_setImage(with: URL(string: imageLink!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Move to chatVC.
        let Vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
         Vc.receiver_id = staffList[indexPath.row].receiver_id!
        self.pushview(objtype: Vc)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height {
        pageNo += 1
            if pageNo <= totalPage{
        utilityMgr.showIndicator()
        let link = UrlConstants.BASE_URL+UrlConstants.get_allStaffMembers+"\(pageNo)"+"/"+self.searchWord
        self.webserviceCall(link: link)
            }
        }
    }
    //MARK:- Search Bar Delegate method.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search for contact.
        self.searchForContact(contactName: searchText)
    }
    //MARK:- function for searching contact.
    func searchForContact(contactName:String){
            pageNo = 1
            let link = UrlConstants.BASE_URL+UrlConstants.get_allStaffMembers+"\(pageNo)"+"/"+contactName
            webserviceCall(link: link)
    }
    //MARK:- Webservice call..
    private func webserviceCall(link:String){
        apiMgr.GetApi(webserviceURL: link, success: { (response) in
            utilityMgr.hideIndicator()
            print("get_allStaffresponse...\(response)")
            let methodName = response["method"] as! String
            if methodName == "get_allStaffMembers" {
                DispatchQueue.main.async {
                    self.totalPage = Int(response["totalpage"] as! String)!
                    if pageNo == 1{
                        self.staffList.removeAll()
                    }
                    for i in 0..<(response["data"] as! NSArray).count {
                        let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                        let inb = Inbox()
                        inb.employee_name = dict["employee_name"] as? String
                        inb.receiver_id = dict["employeeid"] as? String
                        inb.employee_picture = dict["employee_picture"] as? String
                        self.staffList.append(inb)
                    }
                    self.staffListTable.reloadData()
                }
            }
        }, failure: { (error) in
            utilityMgr.hideIndicator()
            print(error ?? 0)
            self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
        })
    }
    
    //MARK:- Left bar action.
    @IBAction func leftbarAction(){
        self.popView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}
