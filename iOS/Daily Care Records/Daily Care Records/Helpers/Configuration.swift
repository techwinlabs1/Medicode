//
//  Configuration.swift
//  Medication
//
//  Created by Techwin Labs on 4/4/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
// Constants
// info.plist $(PRODUCT_NAME)
let APPNAME = "Daily Care Records"//"Medication"
let appWindow = UIApplication.shared.keyWindow
let utilityMgr = UtilityClass()
let APP_COLOR_GREEN = UIColor(red: 95/255, green: 196/255, blue: 198/255, alpha: 1)
let APP_COLOR_BLUE = UIColor(red: 74/255, green: 164/255, blue: 225/255, alpha: 1)
let APP_FONT = "OpenSans"
let APP_SEMIBOLD_FONT = "OpenSans-Semibold"
let APP_BOLD_FONT = "OpenSans-Bold"
let SERVER_AUTH_KEY = "@1&he128477*-3-h22!-|}{dk$120$C!o@*#_o|@" // techwinlabs
let apiMgr = ApiClass()
let DEFAULT_DATE_FROM = "yyyy-MM-dd HH:mm:ss +zzzz"
let mainStoryBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
let managerStoryBoard = UIStoryboard(name: "Manager", bundle: Bundle.main)
let appDel = UIApplication.shared.delegate as! AppDelegate
let profilePlaceholderImage = UIImage(named:"profile-placeholder")
var player:AVAudioPlayer?
// vars
var currentLatitude : Double = 0
var currentLongitude : Double = 0
var pageNo = 1
var searchBarDummy:UISearchBar?

//MARK:- variables for push Notification data usage
var message_Count  = "0"
var reciever_Id = ""
var Main_Id = ""
var Schedule_Id = ""
var Client_Id = ""
var POCclient_Id = ""
var IsScheduleVCOpen = false
var isInboxScreen = false
var medicineCompleted = false
struct ScreenSize {
    
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct UrlConstants {
    
    
    static let BASE_URL = "https://dailycarerecords.com/api/app/"
   
    // test url = http://techwinlabs.com/medication/api/app/
    ///"http://217.160.92.155/api/app/" //Demo Url "http://18.188.194.41/demo/api/app/"// LiveUrl:-"http://18.188.194.41/medication/api/app/"
    
    static let search_company = "search_company"
    static let employee_login = "employee_login"
    static let forgot_password = "forgot_password"
    static let change_password = "change_password"
    static let get_MyDayWiseScheduleCount = "get_MyDayWiseScheduleCount/"
    static let get_MyDayWiseSchedule = "get_MyDayWiseSchedule/"
    static let updateScheduleStatus = "updateScheduleStatus"
    static let get_suggestedClients = "get_suggestedClients"
    static let search_clients = "search_clients"
    static let logout = "logout"
    static let get_TimeSheetRecords = "get_TimeSheetRecords/"
    static let get_MessageInbox = "get_MessageInbox"
    static let view_profile = "view_profile/"
    static let update_profile = "update_profile"
    static let view_ClientProfile = "view_ClientProfile/"
    static let get_ClientCareProgram = "get_ClientCareProgram/"
    static let enter_newMedication = "enter_newMedication"
    static let view_DailyRecords = "view_DailyRecordsData"
    static let get_dailyRecordsQuestions = "get_dailyRecordsQuestions"
    static let add_DailyRecords = "add_DailyRecords"
    static let view_Messages = "view_Messages/"
    static let clear_Chat = "clear_Chat"
    static let delete_SingleMessage = "delete_SingleMessage"
    static let refreshChat = "refreshChat/"
    static let send_newMessage = "send_newMessage"
    static let add_NewConcern = "add_NewConcern"
    static let view_ClientsMedications = "view_ClientsMedications/"
    static let get_activityHistoryOfCarer = "get_activityHistoryOfCarer/"
    static let get_allClients = "get_allClients/"
    static let view_DailyRecordsManagerSctionData = "view_DailyRecordsManagerSctionData/"
    static let update_ClientProfile = "update_ClientProfile"
    static let add_newClient = "add_newClient"
    static let get_UserByUserTypes = "get_UserByUserTypes/"
    static let get_DayWiseScheduleCount = "get_DayWiseScheduleCount/"
    static let get_DayWiseSchedule = "get_DayWiseSchedule/"
    static let get_ManagerMessageInbox = "get_ManagerMessageInbox/"
    static let get_ManagerNotifications = "get_ManagerNotifications/"
    static let get_designationsList = "get_designationsList"
    static let get_CountryCode = "get_CountryCode"
    static let add_newStaffMember = "add_newStaffMember"
    static let get_staffMemberInfo = "get_staffMemberInfo/"
    static let udate_statusOrReplyConcern = "udate_statusOrReplyConcern"
    static let get_allStaffMembers = "get_allStaffMembers/"
    static let get_DayScheduleOfCarer = "get_DayScheduleOfCarer/"
    static let update_staffMemberInfo = "update_staffMemberInfo"
    static let getListOfCarerAvailableForSchedule = "getListOfCarerAvailableForSchedule/"
    static let create_NewSchedule = "create_NewSchedule"
    static let get_dataUsagesByStaffMember = "get_dataUsagesByStaffMember"
    static let checkEmailIsFree = "checkEmailIsFree"
    static let checkEmployeeNumberIsFree = "checkEmployeeNumberIsFree"
    static let get_MyDataUsages = "get_MyDataUsages/"
    static let update_Schedule = "update_Schedule"
    static let delete_Schedule = "delete_Schedule/"
    static let insert_dataUsage = "insert_dataUsage"
    static let update_ClientCareProgram = "update_ClientCareProgram"
    static let get_company_accesses = "get_company_accesses"
    static let update_section_access = "update_section_access"
    static let archive_User = "archive_User"
    static let supervisor_Access = "get_supervisor_accesses"
    static let unread_notification_count = "unread_notification_count"
    static let get_section_accesses = "get_section_accesses"
    static let get_CarerNotifications = "get_CarerNotifications/"
    static let Set_CarerNotificationRead = "Set_CarerNotificationRead"
    static let unread_message_count = "unread_message_count"
}

struct UserType {
    static let carer = 1
    static let manager = 2
    static let supervisor = 3
}

struct Constants {
    
    // Message Strings
    struct Register {
        static let ALL_REQUIRED_FIELD_MESSAGE = "Please fill in all fields."
        static let ENTER_FULL_NAME_MESSAGE = "Please enter name."
        static let ENTER_AGE_MESSAGE = "Please enter age"
        static let EMAIL_VALIDATION_MESSAGE = "Please enter valid email."
        static let PASSWORD_VALIDATION = "Password must contain one uppercase letter, one lowercase letter and one number"
        static let EMAIL_EMPTY_MESSAGE = "Please enter email address."
        static let MOBILE_VALIDATION_MESSAGE = "Please enter a valid mobile number"
        static let MOBILE_EMPTY_MESSAGE = "Please enter a mobile number"
        static let VALID_AGE = "Please enter valid age"
        static let VALID_WEIGHT = "Please enter valid weight"
        static let PASSWORD_EMPTY_MESSAGE = "Please enter password."
        static let PASSWORD_LENGTH_MESSAGE = "Password must have at least 6 characters."
        static let CHOOSE_GENDER = "Please choose a gender."
        static let CHOOSE_BIRTHDAY = "Please choose a birthdate."
        static let UPLOAD_PROFILE_PIC = "Please upload a profile picture."
        static let INCORRECT_PASSWORD = "Incorrect password."
        static let serverError = "We're having trouble with server. Please try again later."
        static let networkConnection = "Please Check your Internet connection!"
        static let PASSWORD_MISMATCH = "Passwords do not match."
        static let ERROR_MESSAGE = "Something went wrong"
        static let LOGOUT_MESSAGE = "Are you sure you want to logout?"
        static let ERROR_CAMERA = "Error in opening camera"
        static let NO_SUPPORT = "Not supported"
        static let UPDATE_MESSAGE = "Updated successfully"
        static let ENABLE_PHONE_LOCATION = "Please enable device location for \(APPNAME)."
        static let ENABLE_APP_LOCATION = "Please allow \(APPNAME) to access location."
        static let VALID_COMPANY = "Please choose a valid company."
        static let NO_SCHEDULE = "No schedule"
        static let TASK_OPTIONS = "Is this job complete?"
        static let CLEAR_CHAT = "Clear chat"
        static let DELETE_MESSAGE = "Delete message?"
        static let CONCERN_MESSAGE = "Do you have a concern?"
        static let EMAIL_UNAVAILABLE = "Email id unavailable.\nPlease enter a different email id."
        static let EMPLOYEE_NUMBER_UNAVAILABLE = "Employee number unavailable.\nPlease enter a different employee number."
        static let CAN_NOT_CREATE_EVENT = "You can not create events for past date."
    }
    
}
