//
//  ScheduleCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/4/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ScheduleCell: UITableViewCell {
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblStarttime: UILabel!
    @IBOutlet weak var lblEndtime: UILabel!
    @IBOutlet weak var btnChangeSchedule: UIButton!

    @IBOutlet weak var client_name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
