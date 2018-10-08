//
//  DataUsageCell1.swift
//  MEDICATION
//
//  Created by Macmini on 4/20/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class DataUsageCell1: UITableViewCell {
    
@IBOutlet weak var btnFromDate: UIButton!
@IBOutlet weak var btnToDate: UIButton!
@IBOutlet weak var btnSelectCarer: UIButton!
@IBOutlet weak var btnSubmit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnSubmit.putShadow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
