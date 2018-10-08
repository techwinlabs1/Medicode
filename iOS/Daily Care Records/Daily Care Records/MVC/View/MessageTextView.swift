//
//  MessageTextView.swift
//  CobraSportUser
//
//  Created by Techwin Labs on 8/28/17.
//  Copyright © 2017 techwin labs. All rights reserved.
//

import UIKit
import SDWebImage

class MessageTextView: UIView {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */ 
    var heightSuperView: CGFloat = 10.0
    var screenWidth = UIScreen.main.bounds.size.width
    
    init(messageData: Message) {
        super.init(frame: MessageTextView.framePrimary(type: messageData.type))
        let padding: CGFloat = 5.0
        let maxWidth = screenWidth - 20 /* This is a max width of message text */
        let backgroudView: UIView = UIView(frame: CGRect(x: padding, y: padding, width: maxWidth, height: heightSuperView))
        let backgroundViewForMessageLabel: UIView = self.setTextInMessageLabel(messageData      :   messageData,
                                                                               padding          :   padding,
                                                                               maxWidth         :   maxWidth-80)
        heightSuperView += backgroundViewForMessageLabel.frame.size.height < 60 ? 60 : backgroundViewForMessageLabel.frame.size.height
        backgroundViewForMessageLabel.layer.cornerRadius = 8.0
        backgroundViewForMessageLabel.layer.borderColor = UIColor.init(red: 241/255, green: 242/255, blue: 240/255, alpha: 1).withAlphaComponent(0.7).cgColor
        backgroundViewForMessageLabel.layer.borderWidth = 1.0
        backgroudView.addSubview(backgroundViewForMessageLabel)
        let senderProfilePic: UIImageView = self.setProfilePicOfSender(messageData              :   messageData,
                                                                       messageTextLabelHeight   :   heightSuperView,
                                                                       padding                  :   maxWidth - 60,
                                                                       maxWidth                 :   60)
        backgroudView.addSubview(senderProfilePic)
        backgroudView.frame = CGRect(x: 10, y: padding, width: maxWidth, height: heightSuperView)
        
        //        let trianglePic = UIImageView(frame : messageData.type == .Sent ? CGRect(x: backgroundViewForMessageLabel.frame.size.width-1, y: 25, width: 10 , height: 10) : CGRect(x: backgroundViewForMessageLabel.frame.origin.x-9, y: 25, width: 10 , height: 10))
        //
        //        trianglePic.image = messageData.type == .Sent ? UIImage(named : "pointRight") : UIImage(named : "pointLeft")
        //
        //        backgroudView.addSubview(trianglePic)
        
        let dateLabel = UILabel(frame : messageData.type == .sent ? CGRect(x: backgroundViewForMessageLabel.frame.size.width-150, y: backgroundViewForMessageLabel.frame.size.height - 20, width: 150 , height: 25) : CGRect(x: backgroundViewForMessageLabel.frame.size.width-80, y: backgroundViewForMessageLabel.frame.size.height - 20, width: 150 , height: 25))
        dateLabel.textColor = UIColor.lightGray
        dateLabel.font = UIFont.init(name: APP_FONT, size: 12.0)
        dateLabel.textAlignment = .right
        let dateStr = messageData.sent_date
        let rem = TimeManager.elapsedTimeSinceNow(fromDate: TimeManager.dateFromString(strDate: dateStr!, fromFormat: "yyyy-MM-dd HH:mm:ss"))
        dateLabel.text = rem as String == "" ? "just now" : (rem as String) + " ago"
        self.addSubview(dateLabel)
        self.addSubview(backgroudView)
        self.backgroundColor  = UIColor.clear
        self.frame.size.height = heightSuperView + padding
    }
    // 2. Initialization coder
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK:- FRAME CALCULATION
    class func framePrimary(type: messageSentType) -> CGRect {
        return CGRect(x: 0, y: 1, width: UIScreen.main.bounds.size.width, height: 40)
    }
    private func setTextInMessageLabel(messageData: Message, padding: CGFloat, maxWidth: CGFloat) -> UIView {
        let messageTextLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        // Set text in label.
        backView.frame = messageData.type == .sent ? CGRect(x: 0, y: 0, width: maxWidth+10 , height: 20) : CGRect(x: padding+80, y: 0, width: maxWidth , height: 20)
        messageData.type == .sent ? (backView.backgroundColor = APP_COLOR_GREEN) : (backView.backgroundColor = APP_COLOR_BLUE)
        messageTextLabel.frame = messageData.type == .sent ? CGRect(x: padding, y: padding, width: maxWidth, height: 20) : CGRect(x: padding+80, y: padding, width: maxWidth , height: 20)
        messageTextLabel.textAlignment = .left
        messageTextLabel.font = UIFont.init(name: APP_FONT, size: 15.0)
        messageTextLabel.numberOfLines = 0
        messageTextLabel.textColor = UIColor.darkGray
        messageTextLabel.text = messageData.message
        messageTextLabel.sizeToFit()
        messageTextLabel.frame = CGRect(x: padding, y: padding, width: maxWidth, height: messageTextLabel.frame.size.height)
        let textHeight = messageTextLabel.text?.stringHeight(with: maxWidth, font: UIFont.init(name: APP_FONT, size: 15.0)!)
        var heightToReturn : CGFloat
        if Int(textHeight!) + 10 > 60 {
            heightToReturn = textHeight! + 45
        } else {
            heightToReturn = 60
        }
        //            let heightToReturn = messageTextLabel.frame.size.height < 60 ? 60 : messageTextLabel.text?.stringHeight(with: maxWidth, font: UIFont.init(name: "Proxima Nova", size: 15.0)!)
        
        messageTextLabel.frame = CGRect(x: padding+5, y: padding, width: maxWidth, height: heightToReturn-10)
        backView.frame = messageData.type == .sent ? CGRect(x: 0, y: 0, width: maxWidth+10 , height: heightToReturn) : CGRect(x: padding+70, y: padding, width: maxWidth+10 , height: heightToReturn)
        backView.addSubview(messageTextLabel)
        return backView
    }
    //set Profile Picture
    private func setProfilePicOfSender(messageData: Message, messageTextLabelHeight: CGFloat, padding: CGFloat, maxWidth: CGFloat) -> UIImageView {
        let senderDp: UIImageView = UIImageView(frame: CGRect(x: 0, y: messageTextLabelHeight, width: 20, height: 20))
        senderDp.frame = messageData.type == .sent ? CGRect(x: padding, y: (messageTextLabelHeight/2) - 25  , width: 50, height: 50) : CGRect(x: 5, y: (messageTextLabelHeight/2) - 25, width: 50, height: 50)
        if messageData.type == .sent {
            // set sender image
            senderDp.sd_setImage(with: URL(string: UserDefaults.standard.value(forKey: "employee_picture") as! String), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        } else {
            senderDp.sd_setImage(with: URL(string: messageData.receiver_image!), placeholderImage: profilePlaceholderImage, options: [], completed: nil)
        }
        senderDp.layer.cornerRadius = senderDp.layer.frame.size.height/2
        senderDp.clipsToBounds = true
        return senderDp
    }
    
}
