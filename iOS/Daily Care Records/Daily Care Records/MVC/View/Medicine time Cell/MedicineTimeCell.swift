//
//  MedicineTimeCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/6/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class MedicineTimeCell: UITableViewCell {
    @IBOutlet weak var txtViewInstruction: MTextView!
    @IBOutlet weak var heightInstruction: NSLayoutConstraint!
    @IBOutlet weak var segmentTime: UISegmentedControl!
    @IBOutlet weak var heightInsView: NSLayoutConstraint!
    @IBOutlet weak var viewInstruction: UIView!
    @IBOutlet weak var lblMedCount: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewMed: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
