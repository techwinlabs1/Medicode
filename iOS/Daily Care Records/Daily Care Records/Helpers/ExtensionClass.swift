//
//  ExtensionClass.swift
//  Habesha
//
//  Created by Techwin Labs on 12/1/17.
//  Copyright © 2017 techwin labs. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func isValidEmail() -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
    
    // Mobile number validation
    func isValidPhoneNumber() -> Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = self.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  self == filtered
    }
    
    // new verification test
    func validatePhone() -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    // is only numeric string
    func isNumeric() -> Bool {
        // if count = 0 , true
        guard self.characters.count > 0 else { return true }
        //
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
    
    // Get String Height.
    func stringHeight(with width: CGFloat , font : UIFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }
    
    // Get string width
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size.width
    }
    
    // Remove decimal
    func removeDecimal() -> String {
        return self.replacingOccurrences(of: "\\.0+$", with: "", options: .regularExpression)
    }
    
    func dateFromString() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss +zzzz"
        
        let dateObj = dateFormatter.date(from: self)
        return dateObj!
        //        dateFormatter.dateFormat = "MM-dd-yyyy"
        //        print("Dateobj: \(dateFormatter.string(from: dateObj!))")
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    func getBase64() -> String? {
        let data = self.data(using: .utf8)
        let encodedStr = data?.base64EncodedString(options: [])
        return encodedStr
    }
    
    func decodeBase64() -> String {
        let decodedData = Data(base64Encoded: self)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        return decodedString
    }
    
    
}

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}


extension UIImageView {
    
    func downloadImageFrom(link:String, contentMode: UIViewContentMode) {
        print("link..\(link)")
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data {
                  //  print(data)
                    if let image = UIImage(data: data){
                        self.image = image
                    }
                }
            }
        }).resume()
    }
    
    func cornerImage(cornerRadius : CGFloat)  {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
}

extension UIButton {
    
    func cornerButton(cornerRadius : CGFloat)  {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    func layoutDesign(cornerRadius : CGFloat , bgColor : UIColor , borderColor : UIColor , borderWidth : CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.backgroundColor = bgColor
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func setCurrentImageFromUrl ( url : String) {
        URLSession.shared.dataTask( with: NSURL(string:url)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.setImage(UIImage(data: data), for: .normal)
                }
            }
        }).resume()
    }
    
}

extension UITableViewCell {
    
    func setDisclosure(toColour: UIColor) -> () {
        for view in self.subviews {
            if let disclosure = view as? UIButton {
                if let image = disclosure.backgroundImage(for: .normal) {
                    let colouredImage = image.withRenderingMode(.alwaysTemplate);
                    disclosure.setImage(colouredImage, for: .normal)
                    disclosure.tintColor = toColour
                }
            }
        }
    }
}

extension UIImage{
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
} 

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension NSMutableData {
    
    func append (_ string : String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


extension UIView {
    
    func plusGradient() {
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 3.0)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func putShadow(){
        self.layer.cornerRadius = 5.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
    }
    
}


extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func animateTextField(textField: UITextField, up: Bool, withOffset offset:CGFloat) {
        
        let movementDistance : Int = -Int(offset)
        let movementDuration : Double = 0.4
        let movement : Int = (up ? movementDistance : -movementDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement))
        UIView.commitAnimations()
    }
    
    public func animateTextView(textView: UITextView, up: Bool, withOffset offset:CGFloat) {
        
        let movementDistance : Int = -Int(offset)
        let movementDuration : Double = 0.4
        let movement : Int = (up ? movementDistance : -movementDistance)
        
        UIView.beginAnimations("animateTextView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: CGFloat(movement) )
        UIView.commitAnimations()
    }
    
    public func kAlertView(title:String , message:String?)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func shakeView(viewToShake : UIView) {
        viewToShake.layer.borderWidth = 1.0
        viewToShake.layer.borderColor = UIColor.red.cgColor
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x : viewToShake.center.x - 10, y : viewToShake.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x : viewToShake.center.x + 10, y : viewToShake.center.y))
        viewToShake.layer.add(animation, forKey: "position")
    }
    
    
    // URLRequest to NSMutableURLRequest
    func urlToMutableUrlRequest(urlReq : URLRequest) -> NSMutableURLRequest? {
        guard let mutableRequest = (urlReq as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            // Handle the error
            return nil
        }
        return mutableRequest
    }
    
    /* back to previous controller */
    func popView()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /* Push to next controller */
    
    func pushview(objtype: UIViewController)
    {
        navigationController?.pushViewController(objtype, animated: true)
    }
    
    /* Pop to specific controller */
//        func popTo(vc : UIViewController) {
//            for controller in navigationController!.viewControllers as Array {
//                if controller.isKind(of: vc.self) {
//                    self.navigationController!.popToViewController(controller, animated: true)
//                    break
//                }
//            }
//        }
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
    
    func kSelfDismissingAlertView(title:String , message:String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK:- Alert Show
    func windowAlertView(_ message: String) {
        
        let alertView = UIAlertController(title: APPNAME, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        
    }
    
    
    
    
    
}
