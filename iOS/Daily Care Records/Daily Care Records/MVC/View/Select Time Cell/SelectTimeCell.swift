//
//  SelectTimeCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/9/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class SelectTimeCell: UITableViewCell {
    @IBOutlet weak var btnFrom: MButton!
    @IBOutlet weak var btnTo: MButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnSubmit.putShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
