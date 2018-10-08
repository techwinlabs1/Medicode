//
//  CarerDetailVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/4/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class CarerDetailVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    private var detailsOfperson=[String]()
    @IBOutlet weak var tblMedication: UITableView!
    var titleString = ""
    var postCode = ""
    var client_id = ""
    
    // MARK:- View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: titleString, controller: self, isReveal : false)
        detailsOfperson=["Profile","Program of Care","Medication Chart","Daily Records"]
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- TableView methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return section == 0 ? 1 : detailsOfperson.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 55 : 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        }
        for case let lbl as UILabel in (cell?.subviews)!{
            lbl.removeFromSuperview()
        }
        if indexPath.section == 0 {
            let imgV = UIImageView(frame: CGRect(x: 15, y: 15, width: 30, height: 30))
            imgV.image = UIImage(named: "location")
            let lblT = UILabel(frame: CGRect(x: imgV.frame.origin.x + imgV.frame.size.width+10, y: 10, width: ScreenSize.SCREEN_WIDTH-((imgV.frame.origin.x + imgV.frame.size.width+10)*2), height: 37))
            lblT.text = postCode
            lblT.font = UIFont(name:"OpenSans", size: 15)
            cell?.backgroundColor = UIColor.groupTableViewBackground
            cell?.addSubview(lblT)
            cell?.addSubview(imgV)
        } else{
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = detailsOfperson[indexPath.row]
            cell?.textLabel?.font = UIFont(name:"OpenSans", size: 15)
            cell?.layer.borderWidth = 1
            cell?.layer.borderColor = UIColor.groupTableViewBackground.cgColor
            cell?.backgroundColor = UIColor.clear
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                vc.titleString = titleString
                vc.client_id = client_id
                self.pushview(objtype: vc)
            case 1:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProgramCareVC") as! ProgramCareVC
                vc.client_id = client_id
                self.pushview(objtype: vc)
            case 2:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MedicationChartVC") as! MedicationChartVC
                vc.titleString = titleString
                vc.client_id = client_id
                self.pushview(objtype: vc)
            case 3:
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DailyRecordsVC") as! DailyRecordsVC
                vc.postcode = postCode
                vc.client_id = client_id
                vc.client_name = titleString
                self.pushview(objtype: vc)
            default:
                break
            }
        }
    }
    // MARK:- IBActions
    @IBAction func leftbarAction () {
        self.popView()
    }
}
