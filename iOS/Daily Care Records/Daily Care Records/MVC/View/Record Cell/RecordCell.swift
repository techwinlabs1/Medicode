//
//  RecordCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/9/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRecord: UILabel!
    @IBOutlet weak var nameBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
