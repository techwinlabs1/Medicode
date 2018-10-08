//
//  viewMedicationCell.swift
//  MEDICATION
//
//  Created by Macmini on 4/10/18.
//  Copyright © 2018 Macmini. All rights reserved.
//

import UIKit

class viewMedicationCell: UITableViewCell {

    @IBOutlet weak var imageCarer: UIImageView!
    @IBOutlet weak var lblCarer: UILabel!
    @IBOutlet weak var lblMedicineName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageCarer.layer.cornerRadius=imageCarer.frame.size.width/2
        imageCarer.clipsToBounds=true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
