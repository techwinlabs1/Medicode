//
//  SearchVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/5/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit
import CoreLocation

class SearchVC: UIViewController, UITableViewDataSource,UITableViewDelegate, LocationProtocol, UISearchBarDelegate,SWRevealViewControllerDelegate , UIScrollViewDelegate {
    @IBOutlet weak var tblSearch: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var clientArray : [Client] = [Client]()
    
    // MARK:- Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarDummy = self.searchBar
        let revealViewController = self.revealViewController()
        revealViewController?.delegate = self
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Search", controller: self, isReveal : true)
//        tblSearch.register(UINib.init(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
        tblSearch.register(UINib.init(nibName: "ClientCell", bundle: nil), forCellReuseIdentifier: "ClientCell")
        LocationManager.sharedMgr.request()
        LocationManager.sharedMgr.locDelegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        searchBarDummy?.isUserInteractionEnabled = true
        self.searchBar.isUserInteractionEnabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        super.viewWillDisappear(true)
        LocationManager.sharedMgr.locDelegate = nil
    }
    // MARK:- Server calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "search_clients" {
                    print(response)
                    DispatchQueue.main.async {
                        self.clientArray.removeAll()
                        for i in 0..<(response["data"] as! NSArray).count {
                            let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                            let d = Client()
                            d.client_id = dict["client_id"] as? String
                            d.firstname = dict["firstname"] as? String
                            d.lastname = dict["lastname"] as? String
                            d.dob = dict["dob"] as? String
                            d.gender = dict["gender"] as? String
                            d.address = dict["address"] as? String
                            d.postcode = dict["postcode"] as? String
                            d.client_picture = dict["client_picture"] as? String
                            d.emergency_contact = dict["emergency_contact"] as? String
                            d.personal_information = dict["personal_information"] as? String
                            d.latitude = dict["latitude"] as? String
                            d.longitude = dict["longitude"] as? String
                            d.distance = dict["distance"] as? String
                            self.clientArray.append(d)
                        }
                        self.tblSearch.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
//                            let cell : SearchCell = self.tblSearch.cellForRow(at: IndexPath(row: 0, section: 0)) as! SearchCell
//                            cell.searchField.becomeFirstResponder()
                            self.searchBar.becomeFirstResponder()
                        })
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "get_suggestedClients" {
                    DispatchQueue.main.async {
                        self.clientArray.removeAll()
                        for i in 0..<(response["data"] as! NSArray).count {
                            let dict = (response["data"] as! NSArray)[i] as! NSDictionary
                            let d = Client()
                            d.client_id = dict["client_id"] as? String
                            d.firstname = dict["firstname"] as? String
                            d.lastname = dict["lastname"] as? String
                            d.dob = dict["dob"] as? String
                            d.gender = dict["gender"] as? String
                            d.address = dict["address"] as? String
                            d.postcode = dict["postcode"] as? String
                            d.client_picture = dict["client_picture"] as? String
                            d.emergency_contact = dict["emergency_contact"] as? String
                            d.personal_information = dict["personal_information"] as? String
                            d.latitude = dict["latitude"] as? String
                            d.longitude = dict["longitude"] as? String
                            d.distance = dict["distance"] as? String
                            self.clientArray.append(d)
                        }
                        self.tblSearch.reloadData()
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    private func getSuggestedClients(){
        DispatchQueue.global(qos: .background).async {
            utilityMgr.showIndicator()
            self.webserviceCall(param: nil, link: UrlConstants.BASE_URL+UrlConstants.get_suggestedClients+"/\(currentLatitude)"+"/"+"/\(currentLongitude)")
        }
    }
    private func searchClients(key:String){
        DispatchQueue.global(qos: .background).async {
            self.webserviceCall(param: ["search_keyword":key], link: UrlConstants.BASE_URL+UrlConstants.search_clients)
        }
    }
    // MARK:- Scrollview delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {
            self.dismissKeyboard()
        }
    }
    // MARK:- Searchbar callback
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            searchClients(key: searchText)
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        if searchBar.text != ""{
            searchClients(key: searchBar.text!)
        }
        
    }
    // MARK:- Location callbacks
    func success(locations: [CLLocation], manager: CLLocationManager) {
        if locations.count > 0 {
            manager.stopUpdatingLocation()
            currentLatitude = (locations.last?.coordinate.latitude)!
            currentLongitude = (locations.last?.coordinate.longitude)!
            getSuggestedClients()
        }
    }
    func failed(error: Error, manager: CLLocationManager) {
        print("failed to get location")
        if Platform.isSimulator {
            currentLatitude = 30.708622499999997   // 30.7312 // 33.9249
            currentLongitude = 76.69200769999999
            getSuggestedClients() // 76.7182 // 18.4241
        }
    }
    // MARK:- SWRevealViewController Delegates
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if position == .right {
            self.dismissKeyboard()
        }
    }
    // MARK:- Tableview delegate and datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  clientArray.count //section == 0 ? 1 : clientArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell : SearchCell! = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell!
//            cell.searchField.becomeFirstResponder()
//            cell.searchField.delegate = self
//            return cell
//        } else {
            let cell : ClientCell! = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as! ClientCell!
            cell.imgProfile.sd_setImage(with: URL(string: clientArray[indexPath.row].client_picture!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
            cell.lblName.text = clientArray[indexPath.row].firstname! + " " + clientArray[indexPath.row].lastname!
            cell.lblAddress.text = clientArray[indexPath.row].address!
            return cell
//        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 //indexPath.section == 0 ? 44 : 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CarerDetailVC") as! CarerDetailVC
        vc.client_id = clientArray[indexPath.row].client_id!
        vc.titleString = clientArray[indexPath.row].firstname! + " " + clientArray[indexPath.row].lastname!
        vc.postCode = clientArray[indexPath.row].postcode!
        self.pushview(objtype: vc)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Suggested Clients" //section == 1 ? "Suggested Clients" : nil
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44 //section == 1 ? 44 : .leastNormalMagnitude
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        let geocoder = CLGeocoder()
        let userLocation :CLLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            utilityMgr.hideIndicator()
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                print(placemark.postalCode!)
                print(placemark.subLocality!)
                self.searchBar.text = "\(placemark.postalCode!)"+" "+"\(placemark.subLocality!)"
                
            }
        }
    }
    
    
 
}
