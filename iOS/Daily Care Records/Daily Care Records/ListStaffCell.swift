//
//  ListStaffCell.swift
//  Medication
//
//  Created by Techwin Labs Mac-3 on 22/06/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ListStaffCell: UITableViewCell {

    @IBOutlet weak var profilePic: MImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
