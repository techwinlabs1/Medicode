//
//  MyDataUsageCell.swift
//  Medication
//
//  Created by Techwin Labs Mac-3 on 22/05/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class MyDataUsageCell: UITableViewCell {
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var replyText: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var subjectHeader: UILabel!
    @IBOutlet weak var separator: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
