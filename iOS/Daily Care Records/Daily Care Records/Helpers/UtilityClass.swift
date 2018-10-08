//
//  UtilityClass.swift
//  Habesha
//
//  Created by Techwin Labs on 12/1/17.
//  Copyright © 2017 techwin labs. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
class UtilityClass: NSObject {

    // MARK:- Add navigation bar
    public func addNavigationBar (leftImage : UIImage? , rightImage : UIImage? , titleText : String, controller : UIViewController , isReveal : Bool) {
        
        let leftBarButton = UIBarButtonItem(image: leftImage ?? nil, style: .plain, target: controller, action: "leftbarAction")
        let rightBarButton = UIBarButtonItem(image: rightImage ?? nil, style: .plain, target: controller, action: rightImage == nil ? nil : "rightbarAction")
        controller.navigationController?.navigationBar.barTintColor = APP_COLOR_BLUE
        controller.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: APP_BOLD_FONT, size: 20)! , NSForegroundColorAttributeName : UIColor.white]
        controller.navigationItem.leftBarButtonItem = leftBarButton
        controller.navigationItem.rightBarButtonItem = rightBarButton
        controller.navigationItem.title = titleText
        if controller is ChangePassword{
            leftBarButton.target = controller
            leftBarButton.action = Selector(("hideKeyboard"))
        }else if controller is EditProfileVC{
            leftBarButton.target = controller
            leftBarButton.action = Selector(("sideMenuAction"))
        }else{
            if isReveal {
                let revealViewController = controller.revealViewController()
                if revealViewController != nil {
                    leftBarButton.target = controller.revealViewController()
                    leftBarButton.action = #selector((SWRevealViewController.revealToggle) as (SWRevealViewController) -> (Void) -> Void) // Swift 3 fix
                }
            }
        }
        
    }
    // MARK:- NavigationTitle Font
    public func setNavigationTitleFont(fontname : String) -> UILabel {
        // Set navigation title string
        var attributedString            = NSMutableAttributedString()
        let navigationTitle:NSString    = APPNAME as NSString
        attributedString = NSMutableAttributedString(string: navigationTitle as String, attributes: [NSFontAttributeName:UIFont(name: fontname, size: 20.0)!])
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGray, range: NSRange(location:0, length:5))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 250.0/255.0, green: 168.0/255.0, blue: 30.0/255.0, alpha: 1.0), range: NSRange(location:5, length: 3))
        // Set navigation title label
        let titleLabel = UILabel()
        titleLabel.attributedText = attributedString
        titleLabel.sizeToFit()
        return titleLabel
    }
    // MARK:- Print all font names
    public func logAllFonts () {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }
    // MARK:- Animation
    enum Direction
    {
        case leftToRight, rightToLeft, topToBottom, bottomToTop, flyViewIn
    }
    public func presentVC (dir: Direction, originalVC: UIViewController, newVC: UIViewController, completion: (() -> Void)? = nil)
    {
        let firstVCView = originalVC.view as UIView!
        let secondVCView = newVC.view as UIView!
        animateViewIn(dir: dir, originalView: firstVCView!, newView: secondVCView!, completion:
            {
                originalVC.present(newVC, animated: false, completion: {
                    if completion != nil {completion!()}
                })
        })
    }
    private func animateViewIn (dir: Direction, originalView: UIView, newView: UIView?, completion: (() -> Void)? = nil)
    {
        guard let newView = newView else
        {
            print("Error: newView is nil")
            return
        }
        // Get the screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        // Resize view
        newView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        // Insert the destination view above the current one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(newView, aboveSubview: originalView)
        // execute flyIn Animation
        if (dir == .flyViewIn)
        {
            flyViewIn(view: newView, completion: completion)
            return
        }
        
        // execute sliding animations
        var frameOffsetX: CGFloat
        var frameOffsetY: CGFloat
        
        switch dir
        {
        case .rightToLeft:
            frameOffsetX = -screenWidth
            frameOffsetY = 0
            
        case .leftToRight:
            frameOffsetX = screenWidth
            frameOffsetY = 0
            
        case .topToBottom:
            frameOffsetX = 0
            frameOffsetY = screenHeight
            
        case .bottomToTop:
            frameOffsetX = 0
            frameOffsetY = -screenHeight
        default:
            frameOffsetX = 0
            frameOffsetY = 0
        }
        
        // Specify the initial position of the destination view.
        newView.frame = CGRect(x: -frameOffsetX, y: -frameOffsetY, width: screenWidth, height: screenHeight)
        
        UIView.animate(withDuration: 0.25, animations:
            { () -> Void in
                originalView.frame = (originalView.frame.offsetBy(dx: frameOffsetX, dy: frameOffsetY))
                newView.frame = (newView.frame.offsetBy(dx: frameOffsetX, dy: frameOffsetY))
        },
                       completion:
            { (Finished) -> Void in
                // reset originalView position
                originalView.frame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight)
                if completion != nil {completion!()}
        })
    }
    
    private func flyViewIn (view: UIView, completion: (() -> Void)? = nil)
    {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.25, animations:
            { () -> Void in
                view.alpha = 1
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
        },
                       completion:
            { (Finished) -> Void in
                if completion != nil {completion!()}
        })
    }
    
    // MARK:- Color with hex
    public func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

        public func convertHTMLString(str:String) -> NSAttributedString {
        let htmlData = NSString(string: str).data(using: String.Encoding.unicode.rawValue)
        
        let attributedString = try! NSAttributedString(data: htmlData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        
        return attributedString
    }
    
    // MARK:- user defaults fxns
    public func setUDVal( val : Any , forKey : String) {
        UserDefaults.standard.set(val, forKey: forKey)
    }
    
    public func getUDVal( forKey : String) -> Any? {
        return UserDefaults.standard.value(forKey: forKey)
    }
    
    public func emptyDefaults() {
//        let appDomain = Bundle.main.bundleIdentifier
//        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        UserDefaults.standard.removeObject(forKey: "company_id")
         UserDefaults.standard.removeObject(forKey: "employee_country_code")
         UserDefaults.standard.removeObject(forKey: "employee_designation")
//         UserDefaults.standard.removeObject(forKey: "employee_email")
         UserDefaults.standard.removeObject(forKey: "employee_mobile")
         UserDefaults.standard.removeObject(forKey: "employee_name")
         UserDefaults.standard.removeObject(forKey: "employee_number")
         UserDefaults.standard.removeObject(forKey: "employee_picture")
//         UserDefaults.standard.removeObject(forKey: "employee_type")
         UserDefaults.standard.removeObject(forKey: "employeeid")
         UserDefaults.standard.removeObject(forKey: "employee_company")
         UserDefaults.standard.removeObject(forKey: "token")
         UserDefaults.standard.removeObject(forKey: "isLogin")
        UserDefaults.standard.removeObject(forKey: "sectionAccess")
         UserDefaults.standard.synchronize()
    }
    // check simulator
    struct Platform {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
        }()
    }
    // MARK:- Show indicator
    public func showIndicator() {
        DispatchQueue.main.async {
            let v = NVActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60), type: .ballRotateChase, color: APP_COLOR_GREEN, padding: nil)
            v.tag = 999
            v.center = (UIApplication.shared.keyWindow?.rootViewController?.view.center)!
            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(v)
            v.startAnimating()
        }
    }
    
    // MARK:- Hide indicator
    public func hideIndicator() {
        DispatchQueue.main.async {
            for v in (UIApplication.shared.keyWindow?.rootViewController?.view.subviews)! {
                if v.tag == 999 {
                    v.removeFromSuperview()
                }
            }
        }
    }
    
    // MARK:- Check animator loading 
    public func isIndicatorVisible() -> Bool? {
        for v in (UIApplication.shared.keyWindow?.rootViewController?.view.subviews)! {
            if v.tag == 999 {
               return (v as? NVActivityIndicatorView)?.isAnimating
            }
            return  nil
        }
        return nil
    }
    
    
    func Alertmsg(_ message: String) {
        
        let alertView = UIAlertController(title: APPNAME, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        
    }
    
    public func ClearTextField(textField: UITextField) {
        textField.text = ""
    }
    
    
}

//MARK:- handle push notification through these model classes
enum SectionType {
    case messages
    case scheduleAdded
    case scheduleUpdated
    case profileUpdated
    case programOfCare
    case notificationPage
}
class MyButton: UIButton {
    fileprivate var titleColorNormal: UIColor = .white
    fileprivate var titleColorHighlighted: UIColor = .blue
    fileprivate var backgroundColorNormal: UIColor = .blue
    fileprivate var backgroundColorHighlighted: UIColor = .white
    override var isHighlighted: Bool {
        willSet(newValue){
            if newValue {
                self.setTitleColor(titleColorHighlighted, for: UIControlState.focused)
                self.backgroundColor = backgroundColorHighlighted
                self.setTitleColor(titleColorHighlighted, for: UIControlState.normal)
                self.backgroundColor = backgroundColorHighlighted
            }else {
                self.setTitleColor(titleColorNormal, for: state)
                self.backgroundColor = backgroundColorNormal
            }
        }
    }
}

class CheckSection {
    fileprivate init() {}
    //MARK:- Function to check section type comes in payload.
    class func checkSectionType(userInfo: [AnyHashable:Any]) {
        if let aps = userInfo["aps"] as? [String: Any]{
            print("Aps Dict - \(aps)")
            if let section = aps["section"] as? Int{
             let KeysDict = aps["keys"] as! [String: Any]
                switch section{
                case 1,3:
        // if current user is Carer..
                    if utilityMgr.getUDVal(forKey: "employee_type") as! String == "1" {
                    Main_Id = KeysDict["main_id"] as! String
//                    Main_Id = TimeManager.FormatDateString(strDate: Main_Id, fromFormat: "yyyy-MM-dd HH:mm:ss", toFormat: "yyyy-MM-dd")
//                    Schedule_Id = String(KeysDict["schedule_id"] as! Int)
//                    SectionNavigator.shared.proceedToScreen(.scheduleAdded)
                    }else if( utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3"){ // if current user is Manager..
                        print("Notification page..")
                        if section == 1{ //if section is 1 only (not for 3)
//                            SectionNavigator.shared.proceedToScreen(.notificationPage)
                        }else if section == 3{
                            //emergency
                            if aps["emergency"] as! Int == 1{
                                     self.playSound()
                            }
                        }
                    }
                case 2:
                    print("Message section removed.")
                    // if current user is Carer..
//                    if utilityMgr.getUDVal(forKey: "employee_type") as! String == "1" {
//                        var count = KeysDict["unread_sender"] as! Int
//                    message_Count = String(count)
////                    UIApplication.shared.applicationIconBadgeNumber = Int(message_Count)!
//                    reciever_Id = KeysDict["main_id"] as! String
//                    }else if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3"){// if current user is Manager..
//                        let count = KeysDict["unread_sender"] as! Int
//                        message_Count = String(count)
////                        UIApplication.shared.applicationIconBadgeNumber = Int(message_Count)!
//                        reciever_Id = KeysDict["main_id"] as! String   // set up for notification with Content available key.......
//                    }
                case 4:
                    Client_Id = KeysDict["client_id"] as! String
//                    SectionNavigator.shared.proceedToScreen(.profileUpdated)
                case 5:
                    if (utilityMgr.getUDVal(forKey: "employee_type") as! String == "2")||(utilityMgr.getUDVal(forKey: "employee_type") as! String == "3"){ // if current user is Manager..
//                    SectionNavigator.shared.proceedToScreen(.notificationPage)
                    }
                case 6:
                    POCclient_Id = KeysDict["client_id"] as! String
//                    SectionNavigator.shared.proceedToScreen(.programOfCare)
                case 7: // This case is Just for Supervisor..
                   
                    print("Get Access Api get called for Supervisor..")
                    if utilityMgr.getUDVal(forKey: "employee_type") as! String == "3"{
                        apiMgr.GetApi(webserviceURL: UrlConstants.BASE_URL+UrlConstants.get_section_accesses, success: { (response) in
                            utilityMgr.hideIndicator()
                            let methodName = response["method"] as! String
                            if methodName == "get_section_accesses"{
                                print("response for (get_section_accesses) api .\(response)")
                                if let innerDict = response["access"] as? [String: Any]{
                                    if let stringData = innerDict["section_roles"] as? String{
                                        print("inner string is \(stringData)")
                                        let defaults = UserDefaults.standard
                                        defaults.set(stringData, forKey: "sectionAccess")
                                        if IsScheduleVCOpen{ // only for scenario when user push app to background and manager update section access on that time
                                            IsScheduleVCOpen  = false
//                                           SectionNavigator.shared.proceedToScreen(.scheduleAdded)
                                        }
                                     }
                                }
                            }
                        }, failure: { (error) in
                            utilityMgr.hideIndicator()
                            print(error ?? 0)
                            UIApplication.shared.keyWindow?.rootViewController?.kAlertView(title: APPNAME, message:Constants.Register.ERROR_MESSAGE)
                        })
                    }
                default:break
                    
                }
            }
        }
    }
    //MARK:- Play emergency sound.
   class func playSound() {
//    var player:AVAudioPlayer?
//        guard let url = Bundle.main.url(forResource: "sound", withExtension: "mp3") else {
//        print("Not Get url..")
//            return
//    }
    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
    var sound: SystemSoundID = 0
    if let soundURL = Bundle.main.url(forAuxiliaryExecutable: "sound.mp3") {
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
        AudioServicesPlaySystemSound(sound)
    }
//        do {
//            var player = AVAudioPlayer()
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
//            try AVAudioSession.sharedInstance().setActive(true)
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) // AVFileType.mp3.rawValue
//            /* iOS 10 and earlier require the following line:
//             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
////            guard let player = player else {
////                print("Player is nil")
////                return
////            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: {
//            player.prepareToPlay()
//                  player.play()
//            })
//        } catch let error {
//            print(error.localizedDescription)
//        }
    })
}

//Mark:- for navigating user to screen as per section type.
class SectionNavigator {
    static let shared = SectionNavigator()
    private init() { }
     var viewController = SWRevealViewController()
    func proceedToScreen(_ type: SectionType) {
       
        _ = UIViewController()
        switch type {
        case .scheduleAdded,.scheduleUpdated:  //MARK:- Move to CarerHomeVC screen
              print("schedule added..")
            //            removeRootVC()
             NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
//            let vc1 = mainStoryBoard.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
//            vc1.selectedDate = Main_Id
//            let refr = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let sideMenuVC = refr.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
//            let frontNavVC = UINavigationController.init(rootViewController: vc1)
//            let rearNavVC = UINavigationController.init(rootViewController: sideMenuVC)
//            rearNavVC.navigationBar.isHidden = true
//            let revealController : SWRevealViewController = SWRevealViewController.init(rearViewController: rearNavVC, frontViewController: frontNavVC)
//            viewController = revealController
//            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: false, completion: nil)
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
        case .messages:   //MARK:- Move to InboxVC screen
 
            print("schedule added..")
            //            removeRootVC()
             NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
//             vc = mainStoryBoard.instantiateViewController(withIdentifier: "InboxVC") as! InboxVC
//            let refr = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let sideMenuVC = refr.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
//            let frontNavVC = UINavigationController.init(rootViewController: vc)
//            let rearNavVC = UINavigationController.init(rootViewController: sideMenuVC)
//            rearNavVC.navigationBar.isHidden = true
//            let revealController : SWRevealViewController = SWRevealViewController.init(rearViewController: rearNavVC, frontViewController: frontNavVC)
//            viewController = revealController
//       UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: false, completion: nil)
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
        case .profileUpdated: //MARK:- Move to ProfileVC screen
            print("schedule added..")
            //      removeRootVC()
             NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
//            let vc1 = mainStoryBoard.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
//            vc1.selectedDate = Main_Id
//            let refr = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let sideMenuVC = refr.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
//            let frontNavVC = UINavigationController.init(rootViewController: vc1)
//            let rearNavVC = UINavigationController.init(rootViewController: sideMenuVC)
//            rearNavVC.navigationBar.isHidden = true
//            let revealController : SWRevealViewController = SWRevealViewController.init(rearViewController: rearNavVC, frontViewController: frontNavVC)
//            viewController = revealController
//            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: false, completion: {
//                 let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
//                vc.client_id = Client_Id
//                vc1.pushview(objtype: vc)
//            })
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
        case .programOfCare:  //MARK:- Move to ProgramCareVC screen

            print("schedule added..")
            //            removeRootVC()
             NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
//            let vc1 = mainStoryBoard.instantiateViewController(withIdentifier: "CarerHomeVC") as! CarerHomeVC
//            vc1.selectedDate = Main_Id
//            let refr = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let sideMenuVC = refr.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
//            let frontNavVC = UINavigationController.init(rootViewController: vc1)
//            let rearNavVC = UINavigationController.init(rootViewController: sideMenuVC)
//            rearNavVC.navigationBar.isHidden = true
//            let revealController : SWRevealViewController = SWRevealViewController.init(rearViewController: rearNavVC, frontViewController: frontNavVC)
//            viewController = revealController
//            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: false, completion: {
//                let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ProgramCareVC") as! ProgramCareVC
//                    vc.client_id = POCclient_Id
//                vc1.pushview(objtype: vc)
//            })
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        case .notificationPage:  //MARK:- Move to Notification screen for Manager
            print("Notification page..")
//            removeRootVC()
             NotificationCenter.default.post(name: Notification.Name("ShowAppWindow"), object: nil)
//            let VC = managerStoryBoard.instantiateViewController(withIdentifier: "ManagerNotificationVC") as! ManagerNotificationVC
//            let refr = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let sideMenuVC = refr.instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
//            let frontNavVC = UINavigationController.init(rootViewController: VC)
//            let rearNavVC = UINavigationController.init(rootViewController: sideMenuVC)
//            rearNavVC.navigationBar.isHidden = true
//            let revealController : SWRevealViewController = SWRevealViewController.init(rearViewController: rearNavVC, frontViewController: frontNavVC)
//            viewController = revealController
//            UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: false, completion: nil)
//            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        
        }
    }
    
    //MARK:- Remove rootViewController if any is present on window
    func removeRootVC(){
        if UIApplication.shared.keyWindow?.rootViewController != nil{
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
        }
    }
}
}
