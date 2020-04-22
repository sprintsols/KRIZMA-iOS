//
//  Profile2ViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 12/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD

class Profile2ViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet var skipBtn:UIButton!
    @IBOutlet var txtDescp:UITextView!
    
    override func viewDidLoad()
    {
//        if fromProfile
//        {
//            skipBtn.alpha = 0
//        }
        
        txtDescp.delegate = self
        
        txtDescp.text = userObj.descp as String
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
    
    @IBAction func skipBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: nil , message: "Do you want to save the new added information?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "YES", style: .default)
        { (action:UIAlertAction) in
            
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            self.updateUserProfile()
        }
        
        let no = UIAlertAction(title: "NO", style: .cancel)
        { (action:UIAlertAction) in
            
            if fromProfile
            {
                let profileVC = (self.storyboard?.instantiateViewController(withIdentifier: "MenuProfileVC")) as! MenuProfileVC
                self.navigationController?.pushViewController(profileVC, animated: true )
            }
            else
            {
                let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController"))as! SearchViewController
                self.navigationController?.pushViewController(searchVC, animated: true )
            }
        }
        
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnAction(_ button:UIButton)
    {
        let profile3VC = (self.storyboard?.instantiateViewController(withIdentifier: "Profile3ViewController")) as! Profile3ViewController
        descp = txtDescp.text!
        self.navigationController?.pushViewController(profile3VC, animated: true )
    }
    
    func updateUserProfile()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/updateUserDetail")!)
            request.httpMethod = "POST"
            
            var photoStr = ""
            
            if photoFlag
            {
                photoStr = convertImageToBase64(image: photo)
            }
            
            let userLat:String = userDefaults.string(forKey: "latitude")! as String
            let userLng:String = userDefaults.string(forKey: "longitude")! as String
            
            descp = txtDescp.text!
            
            let postParameters = String(format:"u_id=%i&name=%@&user_status=%@&gender=%@&age=%@&country=%@&city=%@&area=%@&description=%@&languages=%@&genres=%@&authors=%@&type=%@&image=%@&lat=%@&long=%@&u_location=%@", userObj.userID, userName, userStatus, gender, age, country, city, area, descp, userObj.languages, userObj.generes, userObj.authors, userObj.bookType, photoStr, userLat, userLng, locIndicator)
            
            request.httpBody = postParameters.data(using: .utf8)
            //            //print(postParameters)
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
                
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        userObj.userName = userName as NSString
                        userObj.userStatus = userStatus as NSString
                        userObj.gender = gender as NSString
                        userObj.age = age as NSString
                        userObj.country = country as NSString
                        userObj.city = city as NSString
                        userObj.area = area as NSString
                        userObj.descp = descp as NSString
                        userObj.bookType = bookType as NSString
                        userObj.photo = photo
                        
                        userDefaults.set(country, forKey: "country")
                        userDefaults.set(city, forKey: "city")
                        userDefaults.set(area, forKey: "area")
                        
                        userID = 0
                        code = 0
                        userName = ""
                        userPassword = ""
                        userEmail = ""
                        userStatus = ""
                        gender = ""
                        age = ""
                        locIndicator = ""
                        area = ""
                        city = ""
                        country = ""
                        descp = ""
                        languages = ""
                        generes = ""
                        authors = ""
                        bookType = ""
                        photoFlag = false
                        photo = nil
                        
                        DispatchQueue.main.async {
                            if fromProfile
                            {
                                let profileVC = (self.storyboard?.instantiateViewController(withIdentifier: "MenuProfileVC")) as! MenuProfileVC
                                self.navigationController?.pushViewController(profileVC, animated: true )
                            }
                            else
                            {
                                let addBookVC = (self.storyboard?.instantiateViewController(withIdentifier: "AddBookViewController")) as! AddBookViewController
                                self.navigationController?.pushViewController(addBookVC, animated: true )
                            }
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
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        addToolBar()
    }
    
    func addToolBar()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 42/255, green: 113/255, blue: 158/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        txtDescp.delegate = self
        txtDescp.inputAccessoryView = toolBar
    }
    
    @objc func donePressed()
    {
        txtDescp.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        txtDescp.resignFirstResponder()
    }
}
