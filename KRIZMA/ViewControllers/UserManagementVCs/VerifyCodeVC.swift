//
//  VerifyCodeVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 16/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD

class VerifyCodeVC: UIViewController, UITextFieldDelegate
{
    @IBOutlet var txtDidgit1:UITextField!
    @IBOutlet var txtDidgit2:UITextField!
    @IBOutlet var txtDidgit3:UITextField!
    @IBOutlet var txtDidgit4:UITextField!
    
    @IBOutlet var lblTime:UILabel!
    
    @IBOutlet var topConstraints:NSLayoutConstraint!
    @IBOutlet var codeConstraints:NSLayoutConstraint!
    
    var timer:Timer!
    
    var count = 3600
    
    var code:Int = 0
    
    var backgroundTask:UIBackgroundTaskIdentifier!
    
    override func viewDidLoad()
    {
        if screenSize.height <= 568
        {
            self.codeConstraints.constant = 0
        }
        
        txtDidgit1.becomeFirstResponder()
        
        if userObj.codeTime > 0
        {
            if userObj.codeTime > 60
            {
                count = userObj.codeTime
//                count = 100
                let minutes = (count % 3600) / 60
                let seconds = (count % 3600) % 60
                let sec = seconds < 10 ? String(format: "0%i",seconds) : String(format: "%i",seconds)
                lblTime.text = String(format: "%i:%@", minutes, sec)
                
                startTimer()
            }
            else
            {
                let alert = UIAlertController(title: "", message: "Code has been expired. Please resend code", preferredStyle: .alert)
                
                let resend = UIAlertAction(title: "Resend Code", style: .default)
                { (action:UIAlertAction) in
                    
                    DispatchQueue.main.async()
                    {
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                    }
                    self.resendCode()
                }
                
                alert.addAction(resend)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            startTimer()
        }
        
        self.backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in self?.startTimer()}
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    func startTimer()
    {
        if timer != nil
        {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update()
    {
        if(count > 0)
        {
            count -= 1
            let minutes = (count % 3600) / 60
            let seconds = (count % 3600) % 60
            let sec = seconds < 10 ? String(format: "0%i",seconds) : String(format: "%i",seconds)
            lblTime.text = String(format: "%i:%@", minutes, sec)
            
            userDefaults.set(count, forKey: "codeTime")
        }
        else
        {
            timer.invalidate()
            
            let alert = UIAlertController(title: "", message: "Code has been expired. Please resend code", preferredStyle: .alert)
            
            let resend = UIAlertAction(title: "Resend Code", style: .default)
            { (action:UIAlertAction) in
                
                DispatchQueue.main.async()
                    {
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                self.resendCode()
            }
            
            alert.addAction(resend)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func skipBtnAction(_ button:UIButton)
    {
        let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController"))as! SearchViewController
        self.navigationController?.pushViewController(searchVC, animated: true )
    }
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        let code1 = txtDidgit1.text! as String
        let code2 = txtDidgit2.text!  as String
        let code3 = txtDidgit3.text!  as String
        let code4 = txtDidgit4.text!  as String
        
        if code1.isEmpty || code2.isEmpty || code3.isEmpty || code4.isEmpty
        {
            alert.message = "Please enter four digit code."
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            code = Int(String(format: "%@%@%@%@", code1, code2, code3, code4))!
            
//            if code == userObj.code
//            {
                DispatchQueue.main.async {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                verifyCode()
//            }
//            else
//            {
//                alert.message = "Please enter a valid code."
//                self.present(alert, animated: true, completion: nil)
//            }
        }
    }
    
    @IBAction func resendCodeBtnAction(_ button:UIButton)
    {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        resendCode()
    }
    
    func verifyCode()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/verifyEmail")!)
            request.httpMethod = "POST"
            
            let postParameters = String(format:"u_id=%i&pin=%i", userObj.userID, code)
            
            request.httpBody = postParameters.data(using: .utf8)
            //print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async(){
                        MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    alert.message = "The network connection was lost. Please try again."
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                
                let jsonResult = convertToDictionary(text: responseString!)
//                print(jsonResult)
                //
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        self.timer.invalidate()
//                        self.startTimer()
                        
                        userDefaults.set(userObj.userID, forKey: "userID")
                        
                        DispatchQueue.main.async {
                            let profileVC = (self.storyboard?.instantiateViewController(withIdentifier: "Profile1ViewController")) as! Profile1ViewController
                            fromProfile = false
                            self.navigationController?.pushViewController(profileVC, animated: true )
                        }
                    }
                    else if loginCode == "102"
                    {
                        DispatchQueue.main.async {
                            alert.message = "Please enter a valid code."
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else if loginCode == "104"
                    {
                        let alert = UIAlertController(title: "", message: "Code has been expired. Please resend code to verify email.", preferredStyle: .alert)
                        
                        let resend = UIAlertAction(title: "Resend Code", style: .default)
                        { (action:UIAlertAction) in
                            
                            DispatchQueue.main.async()
                                {
                                    MBProgressHUD.showAdded(to: self.view, animated: true)
                            }
                            self.resendCode()
                        }
                        
                        alert.addAction(resend)
                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
                else
                {
                    DispatchQueue.main.async {
                        alert.message = "The network connection was lost. Please try again."
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            task.resume()
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                alert.message = "You are not connected to the internet. Please check your Wifi or Data network."
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func resendCode()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/resendCode")!)
            request.httpMethod = "POST"
            
            let postParameters = String(format:"email=%@", userObj.userEmail)
            
            request.httpBody = postParameters.data(using: .utf8)
            //print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async()
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    alert.message = "The network connection was lost. Please try again."
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                
                let jsonResult = convertToDictionary(text: responseString!)
//                print(jsonResult)
                //
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        userObj.code = Int((jsonResult!["pin_code"] as! NSString) as String)!
                        DispatchQueue.main.async()
                        {
                            self.txtDidgit1.text = ""
                            self.txtDidgit2.text = ""
                            self.txtDidgit3.text = ""
                            self.txtDidgit4.text = ""
                            self.txtDidgit1.becomeFirstResponder()
                            alert.message = "Code has been sent to you via email."
                            self.present(alert, animated: true, completion: nil)
                            self.count = 3600
                        }
                    }
                }
                else
                {
                    alert.message = "The network connection was lost. Please try again."
                    self.present(alert, animated: true, completion: nil)
                }
            }
            task.resume()
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            alert.message = "You are not connected to the internet. Please check your Wifi or Data network."
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func textFieldDidChangeAction(_ textfield:UITextField)
    {
        if textfield == txtDidgit1
        {
            if textfield.text?.characters.count == 1
            {
                textfield.resignFirstResponder()
                txtDidgit2.becomeFirstResponder()
            }
        }
        else if textfield == txtDidgit2
        {
            if textfield.text?.characters.count == 1
            {
                textfield.resignFirstResponder()
                txtDidgit3.becomeFirstResponder()
            }
        }
        else if textfield == txtDidgit3
        {
            if textfield.text?.characters.count == 1
            {
                textfield.resignFirstResponder()
                txtDidgit4.becomeFirstResponder()
            }
        }
        else if textfield == txtDidgit4
        {
            if textfield.text?.characters.count == 1
            {
                textfield.resignFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        hideKeyboard()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        addToolBar(textfield: textField)
        if screenSize.height <= 568
        {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.topConstraints.constant = -100
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        hideKeyboard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeyboard()
    }
    
    @objc func hideKeyboard()
    {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate
            self.topConstraints.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        txtDidgit1.resignFirstResponder()
        txtDidgit2.resignFirstResponder()
        txtDidgit3.resignFirstResponder()
        txtDidgit4.resignFirstResponder()
    }
    
    func addToolBar(textfield: UITextField)
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 42/255, green: 113/255, blue: 158/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(hideKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textfield.inputAccessoryView = toolBar
    }
}
