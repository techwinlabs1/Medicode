//
//  CompletedMedicationCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/9/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class CompletedMedicationCell: UITableViewCell {
    @IBOutlet weak var lblMedname: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var dose: UILabel!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var noteHeaderLbl: UILabel!
    @IBOutlet weak var noteTextLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
