//
//  ManageClientCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/16/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ManageClientCell: UITableViewCell {
    @IBOutlet weak var imgUser: MImageView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblzipcode: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var addressPlaceholder: UILabel!
    @IBOutlet weak var zipcodePlaceholder: UILabel!
    @IBOutlet weak var dobPlaceholder: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
