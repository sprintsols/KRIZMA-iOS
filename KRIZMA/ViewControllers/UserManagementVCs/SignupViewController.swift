//
//  SignupViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 10/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignupViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet var txtName:UITextField!
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var txtPassword:UITextField!
    @IBOutlet var txtConfirmPassword:UITextField!
    
    @IBOutlet var termsBtn:UIButton!
    @IBOutlet var privacyBtn:UIButton!
    
    var termsFlag = false
    var privacyFlag = false
    
    override func viewDidLoad()
    {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            self.view.frame.origin.y -= keyboardSize.height
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            self.view.frame.origin.y += keyboardSize.height
//        }
//    }
    
    @IBAction func checkboxBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            termsFlag = true
        }
        else
        {
            privacyFlag = true
        }
        
        button.setImage(UIImage(named: "check"), for: .normal)
    }
    
    @IBAction func detailBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            termsFlag = true
            let termsVC = (self.storyboard?.instantiateViewController(withIdentifier: "TermsViewController"))as! TermsViewController
            self.navigationController?.pushViewController(termsVC, animated: true )
        }
        else
        {
            privacyFlag = true
            let privacyVC = (self.storyboard?.instantiateViewController(withIdentifier: "PrivacyViewController"))as! PrivacyViewController
            self.navigationController?.pushViewController(privacyVC, animated: true )
        }
    }
    
    @IBAction func signupBtnAction(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if (txtName.text?.isEmpty)!
        {
            alert.message = "Please enter your name."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtEmail.text?.isEmpty)!
        {
            alert.message = "Please enter your email address."
            self.present(alert, animated: true, completion: nil)
        }
        else if !isValidEmail(emailStr: txtEmail.text!)
        {
            alert.message = "Please enter a valid email address."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtPassword.text?.isEmpty)!
        {
            alert.message = "Please enter your password."
            self.present(alert, animated: true, completion: nil)
        }
        else if ((txtPassword.text?.characters.count)! < 6)
        {
            alert.message = "Password must be six characters."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtPassword.text != txtConfirmPassword.text)
        {
            alert.message = "Password does not match."
            self.present(alert, animated: true, completion: nil)
        }
        else if !termsFlag
        {
            alert.message = "Please accept terms & conditions."
            self.present(alert, animated: true, completion: nil)
        }
        else if !privacyFlag
        {
            alert.message = "Please accept privacy policy."
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            userSignup()
        }
    }
    
    func userSignup()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            let name = txtName.text! as String
            let email = txtEmail.text!  as String
            let password = txtPassword.text!  as String
            
            var request = URLRequest(url: URL(string: webURL + "/signup")!)
            
            print(request.url)
            request.httpMethod = "POST"
            //parameters
            
            //            parameters of signup: name, email, password, status, gender, age, location, country, city, area, description, avatar, languages, genres, authors, u_role, type, token
            
            let postParameters = String(format:"name=%@&email=%@&password=%@",name, email, password)
            
            request.httpBody = postParameters.data(using: .utf8)
            //print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async()
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    DispatchQueue.main.async {
                        alert.message = "The network connection was lost. Please try again."
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print(responseString)
                let jsonResult = convertToDictionary(text: responseString!)
                print(jsonResult)
//
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        let userDict:NSDictionary = jsonResult!["user"] as! NSDictionary
                        print(userDict)
                        userObj.userID = Int((userDict["u_id"] as! NSString) as String)!
                        userObj.code = Int((userDict["u_verify_code"] as! NSString) as String)!
                        userObj.userName = userDict["u_name"] as! NSString
                        userObj.userPassword = userDict["u_password"] as! NSString
                        userObj.userEmail = userDict["u_email"] as! NSString
                        
                        DispatchQueue.main.async()
                        {
                            let verifyCodeVC = (self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")) as! VerifyCodeVC
                            self.navigationController?.pushViewController(verifyCodeVC, animated: true )
                        }
                    }
                    else if loginCode == "103"
                    {
                        DispatchQueue.main.async {
                            alert.message = "This email belongs to another user."
                            self.present(alert, animated: true, completion: nil)
                        }
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
    
    
    @IBAction func loginBtnAction(_ sender: UIButton)
    {
        let loginVC = (self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController"))as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true )
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //        if textField == txtEmail
        //        {
        //            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate method
        //                self.addToolBar(textField: textField)
        //                self.view.layoutIfNeeded()
        //            }, completion: nil)
        //        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == txtName
        {
            txtEmail.becomeFirstResponder()
        }
        else if textField == txtEmail
        {
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword
        {
            txtConfirmPassword.becomeFirstResponder()
        }
        else if textField == txtConfirmPassword
        {
            textField.resignFirstResponder()
        }
        
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        //        if screenSize.height <= 568
        //        {
        //            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate method
        //                self.topConstraints.constant = -140
        //                self.view.layoutIfNeeded()
        //            }, completion: nil)
        //        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeyboard()
    }
    
    func hideKeyboard()
    {
        //        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate method
        //            self.topConstraints.constant = -20
        //            self.view.layoutIfNeeded()
        //        }, completion: nil)
        txtName.resignFirstResponder()
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
        txtConfirmPassword.resignFirstResponder()
    }
}
