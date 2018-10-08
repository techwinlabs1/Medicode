//
//  ChatVC.swift
//  Medication
//
//  Created by Techwin Labs on 4/10/18.
//  Copyright © 2018 techwin labs. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate,UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var heightChatview: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var txtViewMessage: MTextView!
    @IBOutlet weak var tblChat: UITableView!
 
    @IBOutlet weak var sendBtn: UIButton!
    private var messageArray:[Message] = [Message]()
    var receiver_id = ""
    private var employee_name = ""
    private var employee_picture = ""
    private var chatTimer : Timer?
    private var isMessageBeingSent = false
    
    // MARK:- Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        utilityMgr.addNavigationBar(leftImage: UIImage(named:"back-white") , rightImage: UIImage(named:"chat-more"),titleText: "", controller: self, isReveal : false)
        // KeyBoard Notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.applicationIconBadgeNumber = 0
       self.sendBtn.isUserInteractionEnabled = false
        DispatchQueue.global(qos: .userInitiated).async {
            utilityMgr.showIndicator()
            pageNo = 1
            let link = UrlConstants.BASE_URL+UrlConstants.view_Messages+self.receiver_id+"/\(pageNo)"
            self.webserviceCall(param: nil, link: link)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        DispatchQueue.main.async {
            self.chatTimer?.invalidate()
            self.chatTimer = nil
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    func checkForNewMessages() {
        DispatchQueue.global(qos: .background).async {
            if self.isMessageBeingSent == true {
                return
            }
            if self.messageArray.count > 0{
                let message_id = self.messageArray.last?.message_id!
                let link = UrlConstants.BASE_URL+UrlConstants.refreshChat+self.receiver_id+"/\(message_id!)"
                self.webserviceCall(param: nil, link: link)
            }else{
                let message_id = "0"
                let link = UrlConstants.BASE_URL+UrlConstants.refreshChat+self.receiver_id+"/\(message_id)"
                print(link)
                self.webserviceCall(param: nil, link: link)
            }
        }
    }
    // MARK:- Server Calls
    private func webserviceCall(param:[String:Any]?,link:String){
        if param != nil {
            apiMgr.PostApi(param!, webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "clear_Chat" {
                    DispatchQueue.main.async {
                        self.messageArray.removeAll()
                        self.tblChat.reloadData()
                    }
                } else if methodName == "send_newMessage" {
                    print("msg sent : \(response)")
                    self.isMessageBeingSent = false
                    self.sendBtn.isUserInteractionEnabled = true
                    self.txtViewMessage.isUserInteractionEnabled = true
                    DispatchQueue.main.async {
                        self.tblChat.reloadData()
                        self.txtViewMessage.text = "" // type here...
                        utilityMgr.hideIndicator()
                    }
                    
                }
            }, failure: { (error) in
                self.sendBtn.isUserInteractionEnabled = true
                self.txtViewMessage.isUserInteractionEnabled = true
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        } else {
            apiMgr.GetApi(webserviceURL: link, success: { (response) in
                utilityMgr.hideIndicator()
                let methodName = response["method"] as! String
                if methodName == "view_Messages" {
                    self.messageArray.removeAll()
                    self.employee_name = (response["receiver_data"] as! NSDictionary)["employee_name"] as! String
                    self.navigationItem.title = self.employee_name
                    self.employee_picture = (response["receiver_data"] as! NSDictionary)["employee_picture"] as! String
                    let data = response["data"] as! NSArray
                    let reversed = data.reversed()
                    for i in 0..<reversed.count{
                        let dict = reversed[i] as! NSDictionary
                        let message:Message = Message(message_id: dict["message_id"] as? String, sender_id: dict["sender_id"] as? String, thread_id: dict["thread_id"] as? String, message: dict["message"] as? String, sent_date: dict["sent_date"] as? String, is_read: dict["is_read"] as? String, receiver_image: self.employee_picture, type: dict["sender_id"] as! String == utilityMgr.getUDVal(forKey: "employeeid") as! String ? .sent : .received)
                        self.messageArray.append(message)
                    }
                    DispatchQueue.main.async {
                        self.tblChat.reloadData()
                        if self.messageArray.count > 0 {
                            self.tblChat.scrollToRow(at: IndexPath.init(row: self.tblChat.numberOfRows(inSection: 0)-1, section: 0), at: .bottom, animated: true)
                        }
//                        if self.messageArray.count > 0 {
                            if self.chatTimer == nil {
                                self.chatTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.checkForNewMessages), userInfo: nil, repeats: true)
                            } 
//                        } else {
//
//                        }
                    }
                } else if methodName == "refreshChat" {
                    let data = response["data"] as! NSArray
                    print(data)
                    let reversed = data.reversed()
                    for i in 0..<reversed.count{
                        let dict = reversed[i] as! NSDictionary
                        let message:Message = Message(message_id: dict["message_id"] as? String, sender_id: dict["sender_id"] as? String, thread_id: dict["thread_id"] as? String, message: dict["message"] as? String, sent_date: dict["sent_date"] as? String, is_read: dict["is_read"] as? String, receiver_image: self.employee_picture, type: dict["sender_id"] as! String == utilityMgr.getUDVal(forKey: "employeeid") as! String ? .sent : .received)
                        self.messageArray.append(message)
                    }
                    if reversed.count > 0 {
                        DispatchQueue.main.async {
                            self.tblChat.reloadData()
                            self.tblChat.scrollToRow(at: IndexPath.init(row: self.tblChat.numberOfRows(inSection: 0)-1, section: 0), at: .bottom, animated: true)
                        }
                    }
                }
            }, failure: { (error) in
                utilityMgr.hideIndicator()
                print(error ?? 0)
                self.kAlertView(title: APPNAME, message: Constants.Register.ERROR_MESSAGE)
            })
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func keyboardNotification(notification: NSNotification) {
        // scroll to last message here
        if messageArray.count > 0 {
            DispatchQueue.main.async {
                self.tblChat.scrollToRow(at: IndexPath.init(row: self.tblChat.numberOfRows(inSection: 0)-1, section: 0), at: .bottom, animated: true)
            }
        }
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomSpace?.constant = 0.0
            } else {
                self.bottomSpace?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.view.layoutIfNeeded()
            },
                           completion: nil)
        }
    }
    // MARK:- Textview methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.sendBtn.isUserInteractionEnabled = true
        if textView.text == "Write your Message....." { //type here...
            textView.text = ""
        }
    }
 
   
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let maxTextViewHeight:CGFloat = 120.0//ScreenSize.SCREEN_HEIGHT - (bottomSpace.constant + 164)
        if maxTextViewHeight > 70 + (newSize.height - ((textView.font?.lineHeight)! * 2)) {
            UIView.animate(withDuration: 0, animations: {
                if newSize.height - (textView.font?.lineHeight)! > 20 {
                    self.heightChatview.constant = 70 + (newSize.height - ((textView.font?.lineHeight)! * 2))
                    DispatchQueue.main.async(execute: {
                        textView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    })
                } else {
                    textView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    self.heightChatview.constant = 70
                }
            })
        }
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       guard range.location == 0 else{
            return true
        }
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
    }
    // MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let messageDataObject:Message = messageArray[indexPath.row]
        let textMessageView: MessageTextView = MessageTextView(messageData: messageDataObject)
        return textMessageView.frame.size.height + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        }
        cell?.tag = indexPath.row
        cell?.backgroundColor = UIColor.clear
        cell?.selectionStyle = .none
        for view in (cell?.contentView.subviews)! {
            view.removeFromSuperview()
        }
        let messageDataObject:Message = messageArray[indexPath.row]
        let textMessageView: MessageTextView = MessageTextView(messageData: messageDataObject)
        cell?.contentView.addSubview(textMessageView)
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressed(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.view?.tag = indexPath.row
        cell?.addGestureRecognizer(longPress)
        return cell!
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK:- IBActions
    @IBAction func sendMessage(_ sender: UIButton) {
        dismissKeyboard()
    let textToSend:String = txtViewMessage.text.trimmingCharacters(in: .whitespacesAndNewlines)
        print(textToSend)
        txtViewMessage.text = ""
        self.heightChatview.constant = 70
        if textToSend.characters.count > 0 {
//          let textMsg = textToSend.trimmingCharacters(in: .whitespacesAndNewlines)
            isMessageBeingSent = true
            self.txtViewMessage.isUserInteractionEnabled = false
            self.sendBtn.isUserInteractionEnabled = false
            DispatchQueue.global(qos: .background).async {
                utilityMgr.showIndicator()
                let param = ["receiver_id":self.receiver_id,"message":textToSend] as [String : Any]
                print(param)
                print(UrlConstants.BASE_URL+UrlConstants.send_newMessage)
                self.webserviceCall(param: param, link: UrlConstants.BASE_URL+UrlConstants.send_newMessage)
            }
        } else {
            DispatchQueue.main.async {
                self.txtViewMessage.text = ""
            
            }
        }
    }
    func longPressed(_ sender : UILongPressGestureRecognizer){
        if sender.state == .began {
            let deleteAlert:UIAlertController = UIAlertController(title: APPNAME, message: Constants.Register.DELETE_MESSAGE, preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { (yesA) in
                // delete message
                DispatchQueue.global(qos: .userInitiated).async {
                    utilityMgr.showIndicator()
                    self.webserviceCall(param: ["message_id":self.messageArray[(sender.view?.tag)!].message_id!], link: UrlConstants.BASE_URL+UrlConstants.delete_SingleMessage)
                    DispatchQueue.main.async {
                        self.messageArray.remove(at: (sender.view?.tag)!)
                        self.tblChat.beginUpdates()
                        self.tblChat.deleteRows(at: [IndexPath.init(row: (sender.view?.tag)!, section: 0)], with: .automatic)
                        self.tblChat.endUpdates()
                    }
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            deleteAlert.addAction(yes)
            deleteAlert.addAction(cancel)
            present(deleteAlert, animated: true, completion: nil)
        }
    }
    @IBAction func leftbarAction () {
        self.popView()
//     let vc = self.storyboard?.instantiateViewController(withIdentifier: "InboxVC") as! InboxVC
//        popTo(vc: vc)
    }
    
    @IBAction func rightbarAction(){
        dismissKeyboard()
        let clearAlert = UIAlertController(title: APPNAME, message: nil, preferredStyle: .actionSheet)
        let clear = UIAlertAction(title: "Clear chat", style: .destructive) { (clearC) in
           // clear chat
            if self.messageArray.count > 0 {
                DispatchQueue.global(qos: .userInitiated).async {
                    utilityMgr.showIndicator()
                    self.webserviceCall(param: ["thread_id":self.messageArray[0].thread_id!], link: UrlConstants.BASE_URL+UrlConstants.clear_Chat)
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        clearAlert.addAction(clear)
        clearAlert.addAction(cancel)
        if let popover = clearAlert.popoverPresentationController{
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
         present(clearAlert, animated: true, completion: nil)
    }
    
    func popTo(vc : UIViewController) {
        for controller in navigationController!.viewControllers as Array {
            if controller.isKind(of: InboxVC.self){
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
}
