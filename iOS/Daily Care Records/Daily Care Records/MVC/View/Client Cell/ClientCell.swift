//
//  ClientCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/5/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ClientCell: UITableViewCell {
    @IBOutlet weak var imgProfile: MImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
