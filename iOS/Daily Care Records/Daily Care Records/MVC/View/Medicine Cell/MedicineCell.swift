//
//  MedicineCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/6/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class MedicineCell: UITableViewCell {
    @IBOutlet weak var lblMedname: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDos: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var heightDetails: NSLayoutConstraint!
    @IBOutlet weak var heightViewDetails: NSLayoutConstraint!
    @IBOutlet weak var viewDetails: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
