//
//  Client.swift
//  Medication
//
//  Created by Techwin Labs on 4/5/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import Foundation

class Client: NSObject {
    var client_id:String?
    var firstname:String?
    var lastname:String?
    var dob:String?
    var gender:String?
    var address:String?
    var postcode:String?
    var client_picture:String?
    var emergency_contact:String?
    var emergency_name:String?
    var emergency_relation:String?
    var client_phnNo:String?
    var client_email:String?
    var personal_information:String?
    var latitude:String?
    var longitude:String?
    var distance:String?
    var company_id:String?
    var comments:String? //Instructions.
    var created_at:String?
    var updated_at:String?
    var status:String?
    var additionalInfo:String?
    var gp_contact:String?
    var gp_address:String?
    var gp_name:String?
    var allergies:String?
    var am_time_care_program:[Program]?
    var noon_time_care_program:[Program]?
    var tea_time_care_program:[Program]?
    var night_time_care_program:[Program]?
    var program_id:String?
    var program_startdate:String?
    var completed_programs:[Program]?
    var completed_am_time_program:[Program]?
    var completed_noon_time_program:[Program]?
    var completed_tea_time_program:[Program]?
    var completed_night_time_program:[Program]?
}
