//
//  AccessCell.swift
//  Medication
//
//  Created by Techwin Labs on 5/11/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class AccessCell: UITableViewCell {
    @IBOutlet weak var btnCheckbox: UIButton!
    @IBOutlet weak var btnName: UIButton!
    @IBOutlet weak var btnView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
