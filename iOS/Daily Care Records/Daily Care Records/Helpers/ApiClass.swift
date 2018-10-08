//
//  ApiClass.swift
//  Med2Rec
//
//  Created by osvinuser on 6/28/16.
//  Copyright © 2016 osvinuser. All rights reserved.
//

import Foundation
import Alamofire
import UIKit


class ApiClass: NSObject {

    
    ///////////////////////////////                   UPLOAD IMAGE ALAMOFIRE                     /////////////////////////////////////
    
    func alamoUploadImage(_ apiUrl:String , paramDict : [String:Any] ,imageToUpload:UIImage , imageName : String ,success: @escaping (_ response : [String: AnyObject]) -> Void, failure : @escaping (_ error : NSError?) -> Void) {
        
        if self.hasConnectivity() {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.dataConsumptionCount += 1
            var headers = [
                "Auth-Key": SERVER_AUTH_KEY,
                ]
            if let token = utilityMgr.getUDVal(forKey: "token") as? String {
                headers["token"] = token
            }
            if let employeeid = utilityMgr.getUDVal(forKey: "employeeid") as? String {
                headers["employeeid"] = employeeid
            }
            Alamofire.upload(
            
                        multipartFormData: { multipartFormData in
                            if  let imageData = UIImageJPEGRepresentation(imageToUpload, 0.5) {
            
                                let r = RAND_MAX
            
                                let str = "file"+String(r)+".JPG"
            
                                multipartFormData.append(imageData, withName:imageName , fileName: str, mimeType: "image/jpg")
            
                                for (key, value) in paramDict {
            
                                  //   multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                                    if value is String || value is Int {
                                        multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                                    }
            
                                }
            
                            }
            
                    },
            
                        to: apiUrl ,
            
                        encodingCompletion: { encodingResult in
            
                            switch encodingResult {
            
                            case .success(let upload, _, _):
            
                                upload.responseJSON { response in
            
                                    debugPrint(response)
                                    utilityMgr.hideIndicator()
                                    let JSON:[String:AnyObject] = response.result.value as! [String : AnyObject]
                                    //let data = response.data.bye
            
                                    if let httpStatus = response.response , httpStatus.statusCode == 200 {
            
                                        if response.result.isSuccess {
            
                                            success(JSON)
            
                                        } else {
            
                                            failure(response.result.error! as NSError?)
                                        }
                                        
                                    } else {
                                        utilityMgr.hideIndicator()
                                        self.Alertmsg(Constants.Register.serverError)
                                    }
                                }
                                
                            case .failure(let encodingError):
                                print(encodingError)
                                utilityMgr.hideIndicator()
                                self.Alertmsg(Constants.Register.ERROR_MESSAGE)
                                
                            }
                    }
                        
                    )

        } else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
    }
    
    func alamoMultipleImageUpload(apiUrl:String , paramDict : [String:Any] ,imageArray:[UIImage] , imageName : String ,success: @escaping (_ response : [String: AnyObject]) -> Void, failure : @escaping (_ error : NSError?) -> Void) {
        
        if self.hasConnectivity() {
            Alamofire.upload(
                
                multipartFormData: { multipartFormData in
                    for i in 0..<imageArray.count {
                        if  let imageData = UIImageJPEGRepresentation(imageArray[i], 0.5) {
                            
                            let r = RAND_MAX
                            
                            let str = "file"+String(r)+".JPG"
                            
                            multipartFormData.append(imageData, withName:imageName , fileName: str, mimeType: "image/jpg")
                            
                            for (key, value) in paramDict {
                                
                                //   multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                                if value is String || value is Int {
                                    multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                                }
                                
                            }
                            
                        }
                    }
                    
            },
                
                to: apiUrl ,
                
                encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        
                        upload.responseJSON { response in
                            
                            utilityMgr.hideIndicator()
                            let JSON:[String:AnyObject] = response.result.value as! [String : AnyObject]
                            
                            if let httpStatus = response.response , httpStatus.statusCode == 200 {
                                
                                if response.result.isSuccess {
                                    
                                    success(JSON)
                                    
                                } else {
                                    
                                    failure(response.result.error! as NSError?)
                                }
                                
                            } else {
                                self.Alertmsg(Constants.Register.serverError)
                            }
                        }
                        
                    case .failure(let encodingError):
                        utilityMgr.hideIndicator()
                        print(encodingError)
                        self.Alertmsg(Constants.Register.ERROR_MESSAGE)
                        
                    }
            }
                
            )
            
        } else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
    }

    
    
    
    //////////////////////////              UPLOAD IMAGE METHOD USING AFNETWORKING          ///////////////////////////////////////
    
    func uploadImage(_ param : NSMutableDictionary , url : String , imageName : String ,  image : UIImage , success: @escaping (_ response : [String : AnyObject]) -> Void , failure : @escaping (_ error : String) -> Void ) {
        
        if self.hasConnectivity() {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.dataConsumptionCount += 1
            
            let manager = AFHTTPSessionManager()
            let dataImage = UIImageJPEGRepresentation(image, 0.5)
            manager.requestSerializer.setValue(SERVER_AUTH_KEY, forHTTPHeaderField: "Auth-Key")
            if let token = utilityMgr.getUDVal(forKey: "token") as? String {
                manager.requestSerializer.setValue(token, forHTTPHeaderField: "token")
            }
            if let employeeid = utilityMgr.getUDVal(forKey: "employeeid") as? String {
                manager.requestSerializer.setValue(employeeid, forHTTPHeaderField: "employeeid")
            }
            
            manager.post(url, parameters: param, constructingBodyWith: { (formData) in
               let image = formData.appendPart(withFileData: dataImage!, name: imageName, fileName: "photo.png", mimeType: "image/jpg") //let image
                
            }, progress: nil, success: { (operation, responseObject) in
                if let dic = responseObject as? [String: AnyObject] {
                    success(dic)
                }
            }, failure: { (operation, error) in
                failure(error.localizedDescription)
                print("image upload error is -> \(error.localizedDescription)")
            })
            
       } else {
            self.Alertmsg(Constants.Register.networkConnection)
        }
    }
    

    
    //MARK:- Data task
    func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        // NSMutableURLRequest Methods
        request.httpMethod = method
        
        request.timeoutInterval = 60
        
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
       //  request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
         request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        // Create url session
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // Call session data task.
        session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            /*
             print(data)
             print(response)
             print(error)
             print(error?.localizedDescription)
             */
            
            // Check Data
            if let data = data {
                
                // Json Response
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                // response.
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    
                    completion(true, json as AnyObject?)
                    
                } else {
                    
                    completion(false, json as AnyObject?)
                    
                }
                
            } else {
                
                completion(false, error?.localizedDescription as AnyObject?)
                
            }
            
            }.resume()
        
    }
    
    
    ///////////////////////////////////    IMAGE UPLOAD USING URLSESSION     //////////////////////////////////////////
    
    func uploadImageRequest(image: UIImage? , urlString: String, imageName : String ,param: [String:String]? , completion:@escaping(_ success:Bool , _ object : AnyObject?) -> ())
    {
        let url = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if (image == nil)
        {
            return
        }
        
        let image_data = UIImageJPEGRepresentation(image!, 0.5)
        
        
        if(image_data == nil)
        {
            return
        }
 
        let body = NSMutableData()
        
        let fname = "photo.png"
        let mimetype = "image/png"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(imageName)\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        if param != nil {
            for (key, value) in param! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        request.httpBody = body as Data
        
        _ = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                // Json Response
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                // response.
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    
                    completion(true, json as AnyObject?)
                    
                } else {
                    
                    completion(false, json as AnyObject?)
                    
                }
                
            } else {
                
                completion(false, error?.localizedDescription as AnyObject?)
                
            }
            
        }.resume()
        
        
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    //MARK:- POST Methods
    
    ////////////////////////                     AFNETWORKING POST REQUEST                  //////////////////////////////////
    
    func postRequest(_ param : NSMutableDictionary , url : String , success: @escaping (_ response : [String:AnyObject]) -> Void , failure :@escaping (_ error: [String:AnyObject]) -> Void ) {
        
        if self.hasConnectivity() {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.dataConsumptionCount += 1
            
            let manager = AFHTTPSessionManager()
            manager.requestSerializer.setValue(SERVER_AUTH_KEY, forHTTPHeaderField: "Auth-Key")
            if let token = utilityMgr.getUDVal(forKey: "token") as? String {
                manager.requestSerializer.setValue(token, forHTTPHeaderField: "token")

            }
            if let employeeid = utilityMgr.getUDVal(forKey: "employeeid") as? String {
                manager.requestSerializer.setValue(employeeid, forHTTPHeaderField: "employeeid")
            }
            manager.post(
                url,
                parameters: param,
                success:
                {
                    (operation, responseObject) in
                    
                    if let dic = responseObject as? [String: AnyObject] {
                        success(dic)
                        
                    }
                    
            },
                failure:
                {
                    (operation, error) in 
                    utilityMgr.hideIndicator()
                    print("Error: " + error.localizedDescription)
                    self.Alertmsg(Constants.Register.serverError)
            })
        }
        else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
        
    }
    
    ////////////////////////////// Post Api For Webservice to fetch the data from server //////////////////
    
    
    func PostApi(_ paramDict: [String : Any], webserviceURL:String, success: @escaping (_ response: [String:AnyObject]) -> Void, failure: @escaping (_ error: NSError?) -> Void) {
        
        if self.hasConnectivity() {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.dataConsumptionCount += 1
            // Show Loader.
            var headers = [
                "Auth-Key": SERVER_AUTH_KEY,
            ]
            
            if let token = utilityMgr.getUDVal(forKey: "token") as? String {
                headers["token"] = token
                print(token)

            }
            if let employeeid = utilityMgr.getUDVal(forKey: "employeeid") as? String {
                headers["employeeid"] = employeeid
                print(employeeid)
            }
            print(headers)
            
            Alamofire.request(webserviceURL, method: .post, parameters: paramDict, encoding: URLEncoding.default, headers:headers).responseJSON { (response) in
                if let httpStatus = response.response , httpStatus.statusCode == 200 {
                    
                    if response.result.isSuccess {
                        let JSON:[String:AnyObject] = response.result.value as! [String : AnyObject]
                        success(JSON)
                    } else {
                        print("Status Code:- \(response.response?.statusCode)")
                        print(response.result.value)
                        print(response.result.error?.localizedDescription)
                        failure(response.result.error! as NSError?)
                    }
                } else {
                    print(response.error?.localizedDescription)
                    print(response.response?.statusCode)
                     utilityMgr.hideIndicator()
                    if let JSON:[String:AnyObject] = response.result.value as? [String : AnyObject]{
                        print(JSON)
                        print(response.response?.statusCode)
                       NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClearPassword"), object: nil)
                        
                        self.Alertmsg((JSON["message"] as? String)!)
                    }else if response.response?.statusCode == 500{
                        self.Alertmsg(("Internal Server Error."))
                    }else{
                        failure(response.error! as NSError)
                        
                    }
                    
                    
                }
                
            }//
            
        }
        else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
        
    }
    
    
    public func postMethod(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        dataTask(request: request, method: "POST", completion: completion)
        
    }
    
    //MARK:- PUT Methods
    func putApi(_ paramDict: [String : Any], webserviceURL:String, success: @escaping (_ response: [String:AnyObject]) -> Void, failure: @escaping (_ error: NSError?) -> Void) {
        if self.hasConnectivity() {
            // Show Loader.
            //   LoaderClass.sharedInstance.showLoader()
            
            Alamofire.request(webserviceURL, method: .put, parameters: paramDict, encoding: URLEncoding.default).responseJSON { (response) in
                
                if let httpStatus = response.response , httpStatus.statusCode == 200 {
                    
                    if response.result.isSuccess {
                        let JSON:[String:AnyObject] = response.result.value as! [String : AnyObject]
                        success(JSON)
                    } else {
                        failure(response.result.error! as NSError?)
                        //   self.Alertmsg(Constants.Register.serverError)
                    }
                    
                } else {
                    utilityMgr.hideIndicator()
                    print(response)
                    self.Alertmsg(Constants.Register.serverError)
                    
                }
                
            }//
            
        }
        else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
    }
    
    public func putMethod(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        dataTask(request: request, method: "PUT", completion: completion)
        
    }
    
    //MARK:- GET Methods
    /*
    func getRequest(_ param : NSMutableDictionary? , url : String , success: @escaping (_ response : [String:AnyObject]) -> Void , failure :@escaping (_ error: [String:AnyObject]) -> Void ) {
        
        if self.hasConnectivity() {
            let manager = AFHTTPSessionManager()
            manager.get(
                url,
                parameters: param,
                success:
                {
                    (operation, responseObject) in
                    
                    if let dic = responseObject as? [String: AnyObject] {
                        if dic["success"] as? String == "1" {
                            success(dic)
                        } else {
                            failure(dic)
                        }
                    }
                    
            },
                failure:
                {
                    (operation, error) in
                    utilityMgr.hideIndicator()
                    print("Error: " + error.localizedDescription)
                    self.Alertmsg(Constants.Register.serverError)
            })
        }
        else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
        
    }
 */

    
    ////////////////////////////// Get Api For Webservice to fetch the data from server //////////////////
    
    
    func GetApi(webserviceURL:String , success: @escaping (_ response: [String:AnyObject]) -> Void, failure: @escaping (_ error: NSError?) -> Void) {
        
        // Show Loader.
        
        if self.hasConnectivity() {
            let app = UIApplication.shared.delegate as! AppDelegate
            app.dataConsumptionCount += 1
            var headers = [
                "Auth-Key": SERVER_AUTH_KEY,
                ]
            if let token = utilityMgr.getUDVal(forKey: "token") as? String {
                headers["token"] = token

            }
            if let employeeid = utilityMgr.getUDVal(forKey: "employeeid") as? String {
                headers["employeeid"] = employeeid

            }
            print(headers)
            
            Alamofire.request(webserviceURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers:headers).responseJSON { (response) in
                
                if let httpStatus = response.response , httpStatus.statusCode == 200 {
                    
                    if response.result.isSuccess {
                        let JSON:[String:AnyObject] = response.result.value as! [String : AnyObject]
                        success(JSON)
                    } else {
                        failure(response.result.error! as NSError?)
                        //     self.Alertmsg(Constants.Register.serverError)
                    }
                    
                } else {
                    print(response.response?.statusCode)
                    print(response)
                    if let JSON:[String:AnyObject] = response.result.value as? [String : AnyObject]{
                    utilityMgr.hideIndicator()
                    print(response)
                    self.Alertmsg(JSON["message"] as! String)//Constants.Register.serverError
                    }
                }
            }
        }
        else {
            utilityMgr.hideIndicator()
            self.Alertmsg(Constants.Register.networkConnection)
        }
        
        
    }
    
    public func getMethod(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "GET", completion: completion)
        
    }

    // MARK:- Alert Show
    func Alertmsg(_ message: String) {
        
        let alertView = UIAlertController(title: APPNAME, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        
    }
    
    // MARK:- Connectivity Check
    func hasConnectivity() -> Bool {
       
        let reachability = Reachability()
        
        if (reachability?.isReachable)! {
            return true

        } else {
            return false

        }
    }
    
}
