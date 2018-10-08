//
//  HistoryCell.swift
//  MEDICATION
//
//  Created by Macmini on 4/11/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var imageCarer: UIImageView!
    @IBOutlet weak var lblRecord: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     // imageCarer.layer.cornerRadius=imageCarer.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
