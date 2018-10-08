//
//  InboxCell.swift
//  MEDICATION
//
//  Created by Macmini on 4/5/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class InboxCell: UITableViewCell {
    
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var spaceLbl: UILabel!
    @IBOutlet weak var messageCountView: UIView!
    @IBOutlet weak var messageCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
