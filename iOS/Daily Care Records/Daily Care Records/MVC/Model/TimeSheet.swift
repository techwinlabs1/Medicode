//
//  TimeSheet.swift
//  Medication
//
//  Created by Techwin Labs on 4/5/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import Foundation

class TimeSheet: NSObject {
    var date:String?
    var employee_name:String?
    var employee_number:String?
    var schedule = [Schedule]()
    var totalhours:String?
    var workedhours:String?
}
