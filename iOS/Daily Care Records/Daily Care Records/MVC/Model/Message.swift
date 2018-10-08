//
//  MessageDataClass.swift
//  CobraSportUser
//
//  Created by Techwin Labs on 8/28/17.
//  Copyright © 2017 techwin labs. All rights reserved.
//

import Foundation

// 1. Type Enum

/**
 Enum specifing the type
 
 - SenderID  : Chat message is outgoing
 - ReceiverID : Chat message is incoming
 
 */
enum messageSentType: Int {
    case sent = 0
    case received = 1
}

enum messageClassType : Int {
    case text = 0
    case image = 1
}


// Message Data model Class.
class Message {
    
    // 2.Properties
    var message_id    : String?
    var sender_id : String?
    var thread_id   : String?
    var message    : String?
    var sent_date    : String?
    var is_read : String?
    var receiver_image : String?
    var type : messageSentType
    
    // 3. Initialization
    init(message_id: String?, sender_id: String?, thread_id: String? , message: String?, sent_date : String? , is_read : String? , receiver_image:String, type : messageSentType) {
        
        // Default type is Mine
        self.message_id = message_id
        self.sender_id = sender_id
        self.thread_id = thread_id
        self.message = message
        self.sent_date = sent_date
        self.is_read = is_read
        self.receiver_image = receiver_image
        self.type = type
    }
    
}
