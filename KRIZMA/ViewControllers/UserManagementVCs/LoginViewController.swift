//
//  LoginViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 10/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import FacebookLogin
import FacebookCore
import GoogleSignIn
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, CLLocationManagerDelegate, GIDSignInDelegate
{
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var txtPassword:UITextField!
    
    var locationManager = CLLocationManager()
    
    var key = 0
    var socialID = ""
    var media = ""
    var name = ""
    var email = ""
    var photoURL = ""
    var contact = ""
    var location = ""
    
    let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "77tn2ar7gq6lgv", clientSecret: "iqkDGYpWdhf7WKzA", state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "https://github.com/tonyli508/LinkedinSwift"))
    
    override func viewDidLoad()
    {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
        }
        else
        {
            let alert:UIAlertView = UIAlertView(title:"", message: "", delegate: nil,cancelButtonTitle: "OK")
            alert.message = "Please allow GPS from device settings to access the authors near your location."
            alert.show()
        }
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
    
    @IBAction func forgotBtnAction(_ sender: UIButton)
    {
        let forgotVC = (self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC"))as! ForgotPasswordVC
        self.navigationController?.pushViewController(forgotVC, animated: true )
    }
    
    @IBAction func signupBtnAction(_ sender: UIButton)
    {
        let signupVC = (self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController"))as! SignupViewController
        self.navigationController?.pushViewController(signupVC, animated: true )
    }
    
    @IBAction func loginBtnAction(_ sender: UIButton)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if (txtEmail.text?.isEmpty)!
        {
            alert.message = "Please enter your email."
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
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            userLogin()
        }
    }
    
    func userLogin()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            let email = txtEmail.text!  as String
            let password = txtPassword.text!  as String
            
            var request = URLRequest(url: URL(string: webURL + "/userLogin")!)
            print(request)
            request.httpMethod = "POST"
            
            let userLat:String = userDefaults.string(forKey: "latitude")! as String
            let userLng:String = userDefaults.string(forKey: "longitude")! as String
            
            let postParameters = String(format:"email=%@&password=%@&lat=%@&long=%@", email, password, userLat, userLng)
            
            request.httpBody = postParameters.data(using: .utf8)
//            print(postParameters)
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
                //                    print("responseString = \(String(describing: responseString))")
                
                let jsonResult = convertToDictionary(text: responseString!)
//                print(jsonResult)
                
                if jsonResult != nil
                {
                    let loginCode:NSString = jsonResult!["code"] as! NSString
                    
                    if loginCode == "102"
                    {
                        DispatchQueue.main.async()
                        {
                            alert.message = "Invalid username or password."
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else if loginCode == "103"
                    {
                        userObj.userEmail = jsonResult!["email"] as! NSString
                        userObj.userID = Int((jsonResult!["u_id"] as! NSString) as String)!
                        userObj.userName = jsonResult!["name"] as! NSString
                        userObj.codeTime = Int(String(format: "%@",(jsonResult!["remaining_time"] as! NSNumber)))!
                        
                        DispatchQueue.main.async()
                        {
                            let verifyAlert = UIAlertController(title: "", message: "Email verification code has been expired. Please resend code to verify your email.", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let verify = UIAlertAction(title: "Verify Email", style: .default)
                            { (action:UIAlertAction) in
                                
                                DispatchQueue.main.async(){
                                    let verifyCodeVC = (self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")) as! VerifyCodeVC
                                    self.navigationController?.pushViewController(verifyCodeVC, animated: true )
                                }
                            }
                            
                            let resend = UIAlertAction(title: "Resend Code", style: .default)
                            { (action:UIAlertAction) in
                                
                                DispatchQueue.main.async()
                                {
                                    MBProgressHUD.showAdded(to: self.view, animated: true)
                                }
                                self.resendCode()
                            }
                            
                            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                            { (action:UIAlertAction) in
                                
                                
                            }
                            
//                            let skip = UIAlertAction(title: "Skip", style: .cancel)
//                            { (action:UIAlertAction) in
//
////                                let userDict:NSDictionary = jsonResult!["user"] as! NSDictionary
//
////                                userObj.userID = Int((jsonResult!["u_id"] as! NSString) as String)!
////                                userObj.userName = jsonResult!["name"] as! NSString
////                                userObj.userEmail = jsonResult!["email"] as! NSString
////                                userObj.photoURL = userDict["u_avatar"] as! NSString
//
////                                if userObj.photoURL.length > 0
////                                {
////                                    Alamofire.request(userObj.photoURL as String).responseImage { response in
////
////                                        if let image = response.result.value {
////                                            DispatchQueue.main.async() {
////                                                userObj.photo = image
////                                            }
////                                        }
////                                    }
////                                }
//
//                                DispatchQueue.main.async(){
//                                    let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController")) as! SearchViewController
//                                    self.navigationController?.pushViewController(searchVC, animated: true )
//                                }
//                            }
                            
                            if userObj.codeTime > 60
                            {
                                verifyAlert.addAction(verify)
                                verifyAlert.message = "Please verify your email."
                            }
                            verifyAlert.addAction(resend)
//                            verifyAlert.addAction(skip)
                            verifyAlert.addAction(cancel)
                            self.present(verifyAlert, animated: true, completion: nil)
                        }
                    }
                    else if loginCode == "101"
                    {
                        self.loadUserData(jsonResult: jsonResult!)
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
            }
            
            alert.message = "Internet Connection Problem. Please check your Wifi or Data network."
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadUserData(jsonResult: [String: Any])
    {
        let userDict:NSDictionary = jsonResult["user"] as! NSDictionary
        
        userObj.userID = Int((userDict["u_id"] as! NSString) as String)!
        userObj.userName = userDict["u_name"] as! NSString
        userObj.userMName = userDict["u_mname"] as! NSString
        userObj.userLName = userDict["u_lname"] as! NSString
        userObj.userEmail = userDict["u_email"] as! NSString
        userObj.photoURL = userDict["u_avatar"] as! NSString
        userObj.age = userDict["u_age"] as! NSString
        userObj.gender = userDict["u_gender"] as! NSString
        userObj.country = userDict["u_country"] as! NSString
        userObj.city = userDict["u_city"] as! NSString
        userObj.area = userDict["u_area"] as! NSString
        userObj.locIndicator = userDict["u_location"] as! NSString
        userObj.descp = userDict["u_description"] as! NSString
        userObj.languages = userDict["u_languages"] as! NSString
        userObj.authors = userDict["u_authors"] as! NSString
        userObj.generes = userDict["u_genres"] as! NSString
        userObj.bookType = userDict["u_type"] as! NSString
        
        userDefaults.set(userObj.userID, forKey: "userID")
        
        if userObj.photoURL.length > 0
        {
            Alamofire.request(userObj.photoURL as String).responseImage { response in
                
                if let image = response.result.value {
                    DispatchQueue.main.async() {
                        userObj.photo = image
                    }
                }
            }
        }
        
        let notifArray:NSArray = jsonResult["notifications"] as! NSArray
        
        for i in 0..<notifArray.count
        {
            let notifDict:NSDictionary = notifArray.object(at: i) as! NSDictionary
            
            let notifObj = NotificationObject()
            
            notifObj.notifID = notifDict["id"] as! Int
            notifObj.message = notifDict["notification"] as! NSString
            notifObj.createdDate = notifDict["created_at"] as! NSString
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let cDate = dateFormatter.date(from: notifObj.createdDate as String)
            notifObj.timeStr = getElapsedInterval(fromDate: cDate!) as NSString
            
            notificationsArray.add(notifObj)
        }
        
        let booksArray:NSArray = userDict["books"] as! NSArray
        
        for i in 0..<booksArray.count
        {
            let booksDict:NSDictionary = booksArray.object(at: i) as! NSDictionary
            
            let bookObj = BookObject()
            
            bookObj.bookID = Int((booksDict["b_id"] as! NSString) as String)!
            bookObj.authorID = Int((booksDict["u_id"] as! NSString) as String)!
            bookObj.bookName = booksDict["b_name"] as! NSString
            bookObj.photoURL = booksDict["b_image"] as! NSString
            bookObj.language = booksDict["b_language"] as! NSString
            bookObj.author = booksDict["b_author"] as! NSString
            bookObj.bookType = booksDict["b_type"] as! NSString
            
            if bookObj.photoURL.length > 0
            {
                Alamofire.request(bookObj.photoURL as String).responseImage { response in
                    
                    if let image = response.result.value {
                        DispatchQueue.main.async() {
                            bookObj.photo = image
                        }
                    }
                }
            }
            
            userObj.addedBooksArray.add(bookObj)
        }
        
        //Favourite Auhtors
        let favAuthArray:NSArray = userDict["favourite_users"] as! NSArray
        
        for i in 0..<favAuthArray.count
        {
            let authorDict:NSDictionary = favAuthArray.object(at: i) as! NSDictionary
            
            let authorObj = UserObject()
            
            authorObj.userID = Int((authorDict["u_id"] as! NSString) as String)!
            authorObj.userName = authorDict["u_name"] as! NSString
            authorObj.userEmail = authorDict["u_email"] as! NSString
            authorObj.photoURL = authorDict["u_avatar"] as! NSString
            authorObj.age = authorDict["u_age"] as! NSString
            authorObj.gender = authorDict["u_gender"] as! NSString
            authorObj.country = authorDict["u_country"] as! NSString
            authorObj.city = authorDict["u_city"] as! NSString
            authorObj.area = authorDict["u_area"] as! NSString
            authorObj.descp = authorDict["u_description"] as! NSString
            authorObj.languages = authorDict["u_languages"] as! NSString
            authorObj.authors = authorDict["u_authors"] as! NSString
            authorObj.generes = authorDict["u_genres"] as! NSString
            authorObj.bookType = authorDict["u_type"] as! NSString
            authorObj.favBooksName = authorDict["fav_books"] as! NSString
            authorObj.favAuthorsName = authorDict["fav_users_name"] as! NSString
            authorObj.distStr = authorDict["dist_str"] as! NSString
            authorObj.favFlag = 1
            
            if authorObj.photoURL.length > 0
            {
                Alamofire.request(authorObj.photoURL as String).responseImage { response in
                    
                    if let image = response.result.value {
                        DispatchQueue.main.async() {
                            authorObj.photo = image
                        }
                    }
                }
            }
            
            let booksArray:NSArray = authorDict["user_books"] as! NSArray
            
            for i in 0..<booksArray.count
            {
                let booksDict:NSDictionary = booksArray.object(at: i) as! NSDictionary
                
                let bookObj = BookObject()
                
                bookObj.bookID = Int((booksDict["b_id"] as! NSString) as String)!
                bookObj.authorID = Int((booksDict["u_id"] as! NSString) as String)!
                bookObj.bookName = booksDict["b_name"] as! NSString
                bookObj.photoURL = booksDict["b_image"] as! NSString
                bookObj.language = booksDict["b_language"] as! NSString
                bookObj.author = booksDict["b_author"] as! NSString
                bookObj.bookType = booksDict["b_type"] as! NSString
                bookObj.favFlag = booksDict["favourite_flag"] as! Int
                
                if bookObj.photoURL.length > 0
                {
                    Alamofire.request(bookObj.photoURL as String).responseImage { response in
                        
                        if let image = response.result.value {
                            DispatchQueue.main.async() {
                                bookObj.photo = image
                            }
                        }
                    }
                }
                
                authorObj.addedBooksArray.add(bookObj)
            }
            userObj.favAuthorsArray.add(authorObj)
        }
        
        //Favourite Books
        let favBooksArray:NSArray = userDict["favourite_books"] as! NSArray
        
        for i in 0..<favBooksArray.count
        {
            let booksDict:NSDictionary = favBooksArray.object(at: i) as! NSDictionary
            
            let bookObj = BookObject()
            
            bookObj.bookID = Int((booksDict["b_id"] as! NSString) as String)!
            bookObj.authorID = Int((booksDict["u_id"] as! NSString) as String)!
            bookObj.bookName = booksDict["b_name"] as! NSString
            bookObj.photoURL = booksDict["b_image"] as! NSString
            bookObj.language = booksDict["b_language"] as! NSString
            bookObj.author = booksDict["b_author"] as! NSString
            bookObj.bookType = booksDict["b_type"] as! NSString
            bookObj.favFlag = 1
            
            if bookObj.photoURL.length > 0
            {
                Alamofire.request(bookObj.photoURL as String).responseImage { response in
                    
                    if let image = response.result.value {
                        DispatchQueue.main.async() {
                            bookObj.photo = image
                        }
                    }
                }
            }
            
            userObj.favBooksArray.add(bookObj)
        }
        
        //Filtered Auhtors
        let authArray:NSArray = jsonResult["all_users"] as! NSArray
        
        let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController")) as! SearchViewController
        
        for i in 0..<authArray.count
        {
            let authorDict:NSDictionary = authArray.object(at: i) as! NSDictionary
            
            let authorObj = UserObject()
            
            authorObj.userID = Int((authorDict["u_id"] as! NSString) as String)!
            authorObj.userName = authorDict["u_name"] as! NSString
            authorObj.userEmail = authorDict["u_email"] as! NSString
            authorObj.photoURL = authorDict["u_avatar"] as! NSString
            authorObj.age = authorDict["u_age"] as! NSString
            authorObj.gender = authorDict["u_gender"] as! NSString
            authorObj.country = authorDict["u_country"] as! NSString
            authorObj.city = authorDict["u_city"] as! NSString
            authorObj.area = authorDict["u_area"] as! NSString
            authorObj.descp = authorDict["u_description"] as! NSString
            authorObj.languages = authorDict["u_languages"] as! NSString
            authorObj.authors = authorDict["u_authors"] as! NSString
            authorObj.generes = authorDict["u_genres"] as! NSString
            authorObj.bookType = authorDict["u_type"] as! NSString
            authorObj.favBooksName = authorDict["fav_books_name"] as! NSString
            authorObj.favAuthorsName = authorDict["fav_users_name"] as! NSString
            authorObj.distStr = authorDict["dist_str"] as! NSString
            authorObj.favFlag = authorDict["favourite_flag"] as! Int
            
            if authorObj.photoURL.length > 0
            {
                Alamofire.request(authorObj.photoURL as String).responseImage { response in
                    
                    if let image = response.result.value {
                        DispatchQueue.main.async() {
                            authorObj.photo = image
                            searchVC.tblView.reloadData()
                        }
                    }
                }
            }
            
            let booksArray:NSArray = authorDict["user_books"] as! NSArray
            
            for i in 0..<booksArray.count
            {
                let booksDict:NSDictionary = booksArray.object(at: i) as! NSDictionary
                
                let bookObj = BookObject()
                
                bookObj.bookID = Int((booksDict["b_id"] as! NSString) as String)!
                bookObj.authorID = Int((booksDict["u_id"] as! NSString) as String)!
                bookObj.bookName = booksDict["b_name"] as! NSString
                bookObj.photoURL = booksDict["b_image"] as! NSString
                bookObj.language = booksDict["b_language"] as! NSString
                bookObj.author = booksDict["b_author"] as! NSString
                bookObj.bookType = booksDict["b_type"] as! NSString
                bookObj.favFlag = booksDict["favourite_flag"] as! Int
                
                if bookObj.photoURL.length > 0
                {
                    Alamofire.request(bookObj.photoURL as String).responseImage { response in
                        
                        if let image = response.result.value {
                            DispatchQueue.main.async() {
                                bookObj.photo = image
                            }
                        }
                    }
                }
                
                authorObj.addedBooksArray.add(bookObj)
            }
            authorsArray.add(authorObj)
        }
        
        DispatchQueue.main.async()
            {
                self.navigationController?.pushViewController(searchVC, animated: true )
        }
    }
    
    @IBAction func fbBtnAction(_ sender: UIButton)
    {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions:[.publicProfile, .email], viewController: self) { loginResult in
            
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_,_,_):
               
                DispatchQueue.main.async()
                {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                
                self.getFBUserData { userInfo, error in
                    if let error = error
                    {
                        print(error.localizedDescription)
                    }
                    
                    if let userInfo = userInfo, let name = userInfo["name"], let id = userInfo["id"], let email = userInfo["email"]
                    {
                        self.key = 1
                        self.media = "fb_id"
                        self.socialID = id as! String
                        self.name = name as! String
                        self.email = email as! String
                        self.photoURL = String(format: "http://graph.facebook.com/\(id)/picture?type=large")
                        
                        self.mediaLogin()
                    }
                }
            }
        }
    }
    
    func mediaLogin()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/signupWithDifferentAccount")!)
            
            print(request.url)
            request.httpMethod = "POST"
            //parameters
            
            //            parameters of signup: key, fb_id, li_id, gp_id, name, user_status, gender, age, location, type, country, city, area, description, language, author, genre, user_type
            
            let postParameters = String(format:"key=%i&%@=%@&name=%@&email=%@&image=%@", key, media, socialID, name, email, photoURL)
            
            request.httpBody = postParameters.data(using: .utf8)
//            print(postParameters)
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
//                print(responseString)
                let jsonResult = convertToDictionary(text: responseString!)
                print(jsonResult)
                
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        let userDict:NSDictionary = jsonResult!["user"] as! NSDictionary
                        print(userDict)
                        userObj.userID = Int((userDict["u_id"] as! NSString) as String)!
                        userObj.userName = self.name as NSString
                        userObj.userEmail = self.email as NSString
                        userObj.photoURL = self.photoURL as NSString
                        
                        userDefaults.set(userObj.userID, forKey: "userID")
                        
                        if userObj.photoURL.length > 0
                        {
                            Alamofire.request(userObj.photoURL as String).responseImage { response in
                                
                                if let image = response.result.value {
                                    DispatchQueue.main.async() {
                                        let size = CGSize(width: 184, height: 184)
                                        let newImage = image.af_imageAspectScaled(toFill: size)
                                        userObj.photo = newImage
                                    }
                                }
                            }
                        }
                        
                        let newSignupFlag:Int = jsonResult!["flag"] as! Int
                        
                        if newSignupFlag == 1
                        {
                            DispatchQueue.main.async()
                            {
                                let profile1VC = (self.storyboard?.instantiateViewController(withIdentifier: "Profile1ViewController")) as! Profile1ViewController
                                self.navigationController?.pushViewController(profile1VC, animated: true )
                            }
                        }
                        else
                        {
                            self.loadUserData(jsonResult: jsonResult!)
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
    
    func getFBUserData(completion: @escaping (_ : [String: Any]?, _ : Error?) -> Void)
    {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id,email,picture.type(large),name"])
        request.start { response, result in
            switch result {
            case .failed(let error):
                completion(nil, error)
            case .success(let graphResponse):
                completion(graphResponse.dictionaryValue, nil)
            }
        }
    }
    
    @IBAction func linkedinBtnAction(_ sender: UIButton)
    {
        socialMediaInd = 2
        linkedinHelper.authorizeSuccess({ [unowned self] (lsToken) -> Void in
            
            print("Login success lsToken: \(lsToken)")
            DispatchQueue.main.async()
            {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            self.requestProfile()
            }, error: { [unowned self] (error) -> Void in
                
                print("Encounter error: \(error.localizedDescription)")
            }, cancel: { [unowned self] () -> Void in
                
                print("User Cancelled!")
        })
    }

    func requestProfile()
    {
        linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,email-address,picture-url,picture-urls::(original),positions,date-of-birth,phone-numbers,location)?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
            
            print("Request success with response: \(response)")
            
            
            let JSON = response.jsonObject as! Dictionary<String, NSObject>
           
            self.key = 2
            self.media = "li_id"
            self.socialID = JSON["id"] as! String
            self.email = JSON["emailAddress"] as! String
            let fName = JSON["firstName"] as! String
            let lName = JSON["lastName"] as! String
            self.name = fName + " " + lName
//            self.location = JSON["location"] as! String
            self.photoURL = JSON["pictureUrl"] as! String
            print(self.photoURL)

            self.mediaLogin()
            
        }) { [unowned self] (error) -> Void in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                let alert = UIAlertController(title: "", message: "Something went wrong. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            print("Encounter error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func gplusBtnAction(_ sender: UIButton)
    {
        socialMediaInd = 3
        DispatchQueue.main.async()
        {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        GIDSignIn.sharedInstance().signIn()
    }

    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID
            let idToken = user.authentication.idToken
            let email = user.profile.email
            let fullName = user.profile.name
            let imgURL = user.profile.imageURL(withDimension: 184)
            
            self.key = 3
            self.media = "gp_id"
            self.socialID = userId!
            self.name = fullName!
            self.email = email!
            self.photoURL = (imgURL?.absoluteString)!
            
            self.mediaLogin()
        }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
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
//            print(postParameters)
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
                        userObj.codeTime = 3600
                        
                        let verifyAlert = UIAlertController(title: "", message: "Code has been sent you via email.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let verify = UIAlertAction(title: "Verify Email", style: .default)
                        { (action:UIAlertAction) in
                            
                            DispatchQueue.main.async(){
                                let verifyCodeVC = (self.storyboard?.instantiateViewController(withIdentifier: "VerifyCodeVC")) as! VerifyCodeVC
                                self.navigationController?.pushViewController(verifyCodeVC, animated: true )
                            }
                        }
                        
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
                        { (action:UIAlertAction) in
                            
                        }
                        
                        verifyAlert.addAction(verify)
                        verifyAlert.addAction(cancel)
                        DispatchQueue.main.async(){
                            self.present(verifyAlert, animated: true, completion: nil)
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async()
                    {
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
            }
            
            alert.message = "You are not connected to the internet. Please check your Wifi or Data network."
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addToolBar(textField: UITextField)
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
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed()
    {
        self.hideKeyboard()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate method
            
            //            self.topConstraints.constant = -20
            self.view.layoutIfNeeded()
        }, completion: nil)
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
        textField.resignFirstResponder()
        
//        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate method
//            textField.resignFirstResponder()
//            self.topConstraints.constant = -20
//            self.view.layoutIfNeeded()
//        }, completion: nil)
        
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
    
    func isValidEmail(emailStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return email.evaluate(with: emailStr)
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
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last
    
        if userLocation != nil
        {
            userDefaults.set(userLocation!.coordinate.latitude, forKey: "latitude")
            userDefaults.set(userLocation!.coordinate.longitude, forKey: "longitude")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            getAddressFromLocation(userLocation: userLocation!)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        locationManager.stopUpdatingLocation()
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        print("Error: \(error)")
    }
    
    func getAddressFromLocation(userLocation: CLLocation)
    {
        let geoCoder: CLGeocoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(userLocation, completionHandler:
            {(placemarks, error) in
                
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                    return
                }
                
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0
                {
                    let pm = placemarks![0]
                    
                    if pm.country != nil && pm.locality != nil
                    {
                        userDefaults.set(pm.country!, forKey: "country")
                        userDefaults.set(pm.locality!, forKey: "city")
                        userDefaults.set(pm.thoroughfare, forKey: "area")
                    }
                }
        })
    }
}
