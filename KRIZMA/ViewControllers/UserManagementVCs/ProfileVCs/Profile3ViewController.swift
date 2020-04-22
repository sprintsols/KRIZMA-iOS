//
//  Profile3ViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 12/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD
import DropDown

class Profile3ViewController: UIViewController, UITextFieldDelegate, VENTokenFieldDelegate, VENTokenFieldDataSource
{
    @IBOutlet var skipBtn:UIButton!
    
    @IBOutlet var typeImgView:UIImageView!

    @IBOutlet var txtLanguage:VENTokenField!
    @IBOutlet var txtGenere:VENTokenField!
    @IBOutlet var txtAuthor:VENTokenField!
    
    @IBOutlet var langHeight:NSLayoutConstraint!
    @IBOutlet var genHeight:NSLayoutConstraint!
    @IBOutlet var authHeight:NSLayoutConstraint!
    
    var languagesArray = NSMutableArray()
    var generesArray = NSMutableArray()
    var authorsArray = NSMutableArray()
    
    let languageDropDown = DropDown()
    let genereDropDown = DropDown()
    
    let languagesList = populateLanguages()
    let generesList = populateGeneres()
    
    var lang = ""
    var gen = ""
    var auth = ""
    
    override func viewDidLoad()
    {
//        if fromProfile
//        {
//            skipBtn.alpha = 0
//        }
        
        self.txtLanguage.delegate = self
        self.txtLanguage.dataSource = self
        self.txtLanguage.delimiters = [",", ";", "--"]
        self.txtLanguage.placeholderText = NSLocalizedString("Languages", comment: "")
        self.txtLanguage.setColorScheme(UIColor(red: 0, green: 153/255.0, blue: 236/255.0, alpha: 1.0))
        self.txtLanguage.layer.borderColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1.0).cgColor
        self.txtLanguage.layer.borderWidth = 1
        self.txtLanguage.layer.cornerRadius = 5
        self.txtLanguage.layer.masksToBounds = true
        
        self.txtGenere.delegate = self
        self.txtGenere.dataSource = self
        self.txtGenere.delimiters = [",", ";", "--"]
        self.txtGenere.placeholderText = NSLocalizedString("Generes", comment: "")
        self.txtGenere.setColorScheme(UIColor(red: 0, green: 153/255.0, blue: 236/255.0, alpha: 1.0))
        self.txtGenere.layer.borderColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1.0).cgColor
        self.txtGenere.layer.borderWidth = 1
        self.txtGenere.layer.cornerRadius = 5
        self.txtGenere.layer.masksToBounds = true
        
        self.txtAuthor.delegate = self;
        self.txtAuthor.dataSource = self;
        self.txtAuthor.delimiters = [",", ";", "--"]
        self.txtAuthor.placeholderText = NSLocalizedString("Authors", comment: "")
        self.txtAuthor.setColorScheme(UIColor(red: 0, green: 153/255.0, blue: 236/255.0, alpha: 1.0))
        self.txtAuthor.layer.borderColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1.0).cgColor
        self.txtAuthor.layer.borderWidth = 1
        self.txtAuthor.layer.cornerRadius = 5
        self.txtAuthor.layer.masksToBounds = true
        
        if !languages.isEmpty
        {
            let langArray = languages.components(separatedBy: ",")
            
            for i in 0..<langArray.count
            {
                let name:String = langArray[i]
                if !name.isEmpty
                {
                    languagesArray.add(name)
                }
            }
            
            txtLanguage.reloadData()
        }
        if !generes.isEmpty
        {
            let genArray = generes.components(separatedBy: ",")
            
            for i in 0..<genArray.count
            {
                let name:String = genArray[i]
                if !name.isEmpty
                {
                    generesArray.add(name)
                }
            }
            
            txtGenere.reloadData()
        }
        
        if !authors.isEmpty
        {
            let authArray = authors.components(separatedBy: ",")
            
            for i in 0..<authArray.count
            {
                let name:String = authArray[i]
                if !name.isEmpty
                {
                    authorsArray.add(name)
                }
            }
            
            txtAuthor.reloadData()
        }
        
        if bookType == "used"
        {
            typeImgView.image = UIImage(named: "used_active")
        }
        else if bookType == "both"
        {
            typeImgView.image = UIImage(named: "both_active")
        }
        else
        {
            bookType = "new"
            typeImgView.image = UIImage(named: "new_active")
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
    
    func getLanguages(searchText: String)
    {
        languageDropDown.anchorView = txtLanguage
        languageDropDown.bottomOffset = CGPoint(x: 0, y: txtLanguage.bounds.height)
        
        var filteredList = [String]()
        
        for i in 0..<languagesList.count
        {
            let languageStr:String = languagesList[i] as String
            
            let range = languageStr.range(of: searchText, options: .caseInsensitive)
            
            if range != nil
            {
                filteredList.append(languageStr)
            }
        }
        
        languageDropDown.dataSource = filteredList
        
        if filteredList.count > 0
        {
            languageDropDown.show()
        }
        else
        {
            languageDropDown.hide()
        }
        
        languageDropDown.selectionAction = { [weak self] (index, item) in
            self?.languagesArray.add(item)
            self?.txtLanguage.reloadData()
            self!.langHeight.constant = self!.txtLanguage.frame.size.height
        }
    }
    
    func getGeneres(searchText: String)
    {
        genereDropDown.anchorView = txtGenere
        genereDropDown.bottomOffset = CGPoint(x: 0, y: txtGenere.bounds.height)
        
        var filteredList = [String]()
        
        for i in 0..<generesList.count
        {
            let genereStr:String = generesList[i] as String
            
            let range = genereStr.range(of: searchText, options: .caseInsensitive)
            
            if range != nil
            {
                filteredList.append(genereStr)
            }
        }
        
        genereDropDown.dataSource = filteredList
        
        if filteredList.count > 0
        {
            genereDropDown.show()
        }
        else
        {
            genereDropDown.hide()
        }
        
        genereDropDown.selectionAction = { [weak self] (index, item) in
            self?.generesArray.add(item)
            self?.txtGenere.reloadData()
            self!.genHeight.constant = self!.txtGenere.frame.size.height
        }
    }
    
    @IBAction func skipBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: nil , message: "Do you want to save the new added information?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "YES", style: .default)
        { (action:UIAlertAction) in
            
            for i in 0..<self.languagesArray.count
            {
                let name:String = self.languagesArray.object(at: i) as! String
                self.lang = String(format: "%@%@",self.lang, self.lang.isEmpty ? name : "," + name)
            }
            
            for i in 0..<self.generesArray.count
            {
                let name:String = self.generesArray.object(at: i) as! String
                self.gen = String(format: "%@%@",self.gen, self.gen.isEmpty ? name : "," + name)
            }
            
            for i in 0..<self.authorsArray.count
            {
                let name:String = self.authorsArray.object(at: i) as! String
                self.auth = String(format: "%@%@",self.auth, self.auth.isEmpty ? name : "," + name)
            }
            
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
    
    @IBAction func typeBtnAction(_ button:UIButton)
    {
        if button.tag == 1001
        {
            bookType = "new"
            typeImgView.image = UIImage(named: "new_active")
        }
        else if button.tag == 1002
        {
            bookType = "used"
            typeImgView.image = UIImage(named: "used_active")
        }
        else
        {
            bookType = "both"
            typeImgView.image = UIImage(named: "both_active")
        }
    }
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnAction(_ button:UIButton)
    {
        for i in 0..<languagesArray.count
        {
            let name:String = languagesArray.object(at: i) as! String
            lang = String(format: "%@%@",lang, lang.isEmpty ? name : "," + name)
        }
        
        for i in 0..<generesArray.count
        {
            let name:String = generesArray.object(at: i) as! String
            gen = String(format: "%@%@",gen, gen.isEmpty ? name : "," + name)
        }
        
        for i in 0..<authorsArray.count
        {
            let name:String = authorsArray.object(at: i) as! String
            auth = String(format: "%@%@",auth, auth.isEmpty ? name : "," + name)
        }
        
        print(languages)
        
        if languagesArray.count > 0
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            updateUserProfile()
        }
        else
        {
            let alert = UIAlertController(title: "", message: "Please add atleast one language.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
            
            let postParameters = String(format:"u_id=%i&name=%@&mname=%@&lname=%@&user_status=%@&gender=%@&age=%@&country=%@&city=%@&area=%@&description=%@&languages=%@&genres=%@&authors=%@&type=%@&image=%@&lat=%@&long=%@&location=%@", userObj.userID, userName, userMName, userLName, userStatus, gender, age, country, city, area, descp, lang, gen, auth, bookType, photoStr, userLat, userLng, locIndicator)
            
            request.httpBody = postParameters.data(using: .utf8)
            print(postParameters)
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
                        userObj.userMName = userMName as NSString
                        userObj.userLName = userLName as NSString
                        userObj.userStatus = userStatus as NSString
                        userObj.gender = gender as NSString
                        userObj.age = age as NSString
                        userObj.country = country as NSString
                        userObj.city = city as NSString
                        userObj.area = area as NSString
                        userObj.locIndicator = locIndicator as NSString
                        userObj.descp = descp as NSString
                        userObj.languages = self.lang as NSString
                        userObj.generes = self.gen as NSString
                        userObj.authors = self.auth as NSString
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
                        self.lang = ""
                        self.gen = ""
                        self.auth = ""
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
//                                let addBookVC = (self.storyboard?.instantiateViewController(withIdentifier: "AddBookViewController")) as! AddBookViewController
//                                self.navigationController?.pushViewController(addBookVC, animated: true )
                                
                                let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController")) as! SearchViewController
                                self.navigationController?.pushViewController(searchVC, animated: true )
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeyboard()
    }
    
    func hideKeyboard()
    {
        txtLanguage.resignFirstResponder()
        txtGenere.resignFirstResponder()
        txtAuthor.resignFirstResponder()
    }
    
    func tokenField(_ tokenField: VENTokenField, didEnterText text: String)
    {
        if tokenField.tag == 1001
        {
            if tokenField.frame.size.height > 62
            {
                langHeight.constant = tokenField.frame.size.height
            }
            
            self.languagesArray.add(text)
            self.txtLanguage.reloadData()
        }
        else if tokenField.tag == 1002
        {
//            if tokenField.frame.size.height > 62
//            {
//                genHeight.constant = tokenField.frame.size.height
//            }
            
            self.generesArray.add(text)
            self.txtGenere.reloadData()
        }
        else if tokenField.tag == 1003
        {
            if tokenField.frame.size.height > 62
            {
                authHeight.constant = tokenField.frame.size.height
            }
            
            self.authorsArray.add(text)
            self.txtAuthor.reloadData()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func tokenField(_ tokenField: VENTokenField, didChangeText text: String?)
    {
        if tokenField.tag == 1001
        {
            getLanguages(searchText: text!)
        }
        else if tokenField.tag == 1002
        {
            if generesArray.count < 3
            {
                getGeneres(searchText: text!)
            }
            else
            {
                self.txtGenere.reloadData()
            }
        }
    }
    
    func tokenField(_ tokenField: VENTokenField, didDeleteTokenAt index: UInt)
    {
        if tokenField.tag == 1001
        {
            self.languagesArray.removeObject(at: Int(index))
            self.txtLanguage.reloadData()
            self.langHeight.constant = self.txtLanguage.frame.size.height
        }
        else if tokenField.tag == 1002
        {
            self.generesArray.removeObject(at: Int(index))
            self.txtGenere.reloadData()
            self.genHeight.constant = self.txtGenere.frame.size.height
        }
        else if tokenField.tag == 1003
        {
            self.authorsArray.removeObject(at: Int(index))
            self.txtAuthor.reloadData()
            self.authHeight.constant = self.txtAuthor.frame.size.height
        }
    }
    
    func tokenField(_ tokenField: VENTokenField, titleForTokenAt index: UInt) -> String
    {
        if tokenField.tag == 1001
        {
           return self.languagesArray.object(at: Int(index)) as! String
        }
        else if tokenField.tag == 1002
        {
            return self.generesArray.object(at: Int(index)) as! String
        }
        else
        {
           return self.authorsArray.object(at: Int(index)) as! String
        }
    }
    
    func numberOfTokens(in tokenField: VENTokenField) -> UInt
    {
        if tokenField.tag == 1001
        {
            return UInt(self.languagesArray.count)
        }
        else if tokenField.tag == 1002
        {
            return UInt(self.generesArray.count)
        }
        else
        {
            return UInt(self.authorsArray.count)
        }
    }
}

