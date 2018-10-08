//
//  ManagerNotificationCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/18/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ManagerNotificationCell: UITableViewCell {
 
    @IBOutlet weak var notificationTypeLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var carer_Msg_field: UILabel!
    @IBOutlet weak var time_field: UILabel!
    @IBOutlet weak var date_field: UILabel!
    @IBOutlet weak var employee_Id: UILabel!
    @IBOutlet weak var resolver_name: UILabel!
    @IBOutlet weak var resolver_id: UILabel!
    @IBOutlet weak var resolving_Msg: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var resolving_date: UILabel!
    @IBOutlet weak var supervisorBtn: UIButton!
    @IBOutlet weak var employee_id_click: UIButton!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
