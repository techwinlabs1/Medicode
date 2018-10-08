//
//  MedicationChartVC.swift
//  MEDICATION
//
//  Created by Macmini on 4/4/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class MedicationChartVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblMedicationChart: UITableView!
    private var medicationChart=[String]()
    var client_id = ""
    var titleString = ""
    // MARK:- View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: nil,titleText: "Medication Chart", controller: self, isReveal : false)
//        medicationChart=["View Medication","Enter Medication"]
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
         medicationChart=["View Medication","Enter Medication"]
        tblMedicationChart.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return medicationChart.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell=tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text=medicationChart[indexPath.row]
        cell.textLabel?.font=UIFont(name:"OpenSans", size: 15)
        cell.layer.borderWidth=1
        cell.layer.borderColor=UIColor.groupTableViewBackground.cgColor
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewMedicationVC") as! ViewMedicationVC
            vc.titleString = titleString
            vc.client_id = client_id
            self.pushview(objtype: vc)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EnterMedicationVC") as! EnterMedicationVC
            vc.client_id = client_id
            vc.titleName = titleString
            self.pushview(objtype: vc)
        }
    }
    // MARK:- IBActions
    @IBAction func leftbarAction () {
        self.popView()
    }
}
