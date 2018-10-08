//
//  Notification.swift
//  Medication
//
//  Created by Techwin Labs on 4/18/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import Foundation

class NotificationList : NSObject {
    var notifcation_id:String?
    var notification_type:String?
    var authority_id:String?
    var carer_id:String?
    var table_id:String?
    var status:String?
    var forworded_by:String?
    var created_at:String?
    var notification : NotificationData = NotificationData()
    var main_id:String?
}

class NotificationData: NSObject {
    var concern_id:String?
    var employeeid:String?
    var subject:String?
    var concern:String?
    var closed_by:String?
    var closed_by_emp_number:String?
    var closed_by_id:String?
    var open_at:String?
    var closed_at:String?
    var status:String?
    var employee_name:String?
    var employee_number:String?
    var message:String?
    var reply:String?
    
     var client_id:String?
     var client_name:String?
     var created_at:String?
     var end_datetime:String?
     var schedule_id:String?
     var start_datetime:String?
     var firstname:String?
     var lastname:String?
     var postcode:String?
    
    
    
    
}
