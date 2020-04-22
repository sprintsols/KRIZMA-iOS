//
//  ForgotPasswordVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 10/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForgotPasswordVC: UIViewController
{
    @IBOutlet var txtEmail:UITextField!
    
    override func viewDidLoad()
    {
        
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
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitBtnAction(_ button:UIButton)
    {
        if !isValidEmail(emailStr: txtEmail.text!)
        {
            let alert = UIAlertController(title: "", message: "Please enter a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            forgetPassword()
        }
    }
    
    func forgetPassword()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/forgotPassword")!)
            request.httpMethod = "POST"
            
            let postParameters = String(format:"email=%@", txtEmail.text!)
            
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
                    if loginCode == "102"
                    {
                        DispatchQueue.main.async {
                            alert.message = "This email does not belongs to you."
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else if loginCode == "101"
                    {
                        DispatchQueue.main.async {
                            let alert:UIAlertView = UIAlertView(title:"", message: "", delegate: nil,cancelButtonTitle: "OK")
                            alert.message = "An email is on it's way. Please check your inbox to set a new password."
                            alert.show()
                            self.navigationController?.popViewController(animated: true)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        txtEmail.resignFirstResponder()
    }
}
