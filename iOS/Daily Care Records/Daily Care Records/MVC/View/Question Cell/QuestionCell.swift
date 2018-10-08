//
//  QuestionCell.swift
//  Medication
//
//  Created by Techwin Labs on 4/11/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    @IBOutlet weak var btnQuestion: MButton!
    @IBOutlet weak var rightArrow: UIImageView!
    @IBOutlet weak var txtViewAnswer: MTextView!
    @IBOutlet weak var heightQues: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
