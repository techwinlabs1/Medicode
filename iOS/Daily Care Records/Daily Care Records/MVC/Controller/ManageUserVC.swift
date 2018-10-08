//
//  ManageUserVC.swift
//  MEDICATION
//
//  Created by Techwin Labs iMac on 16/04/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class ManageUserVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var tblManageUser: UITableView!
    private var dataArray=[String]()
    
    //MARK:- View lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        dataArray=["Manager","Supervisor","Carer"]
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"menu-button") , rightImage: nil,titleText: "Manage Users", controller: self, isReveal : true)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
         dataArray=["Manager","Supervisor","Carer"]
        tblManageUser.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        }
        cell?.textLabel?.text=dataArray[indexPath.row]
        cell?.textLabel?.font=UIFont(name:"OpenSans", size: 15)
        let lbl = UILabel(frame: CGRect(x: 20, y: 45, width: ScreenSize.SCREEN_WIDTH - 40, height: 1))
        lbl.backgroundColor = UIColor.lightGray
        cell?.accessoryType = .disclosureIndicator
        cell?.addSubview(lbl)
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath.row == 4{
//
//        }else{
            let vc = managerStoryBoard.instantiateViewController(withIdentifier: "ManagerHomeVC") as! ManagerHomeVC
            vc.isHome = false
            switch indexPath.row{
            case 0:
                vc.usertype = 2
            case 1:
                vc.usertype = 3
            case 2:
                vc.usertype = 1
//            case 3:
//                vc.usertype = 4
//            case 4:
//                vc.usertype = 0
            default:
                break
            }
            self.pushview(objtype: vc)
//        }

    }
    // MARK:- IBActions
    
//    @IBAction func rightbarAction(){
//        print("Right bar button clicked..")
//    }
    @IBAction func leftbarAction () {
        self.popView()
    }
}
