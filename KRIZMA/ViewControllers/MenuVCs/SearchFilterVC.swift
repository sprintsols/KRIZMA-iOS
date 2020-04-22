//
//  SearchFilterVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 16/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import DropDown

class SearchFilterVC: UIViewController, UITextFieldDelegate, VENTokenFieldDelegate, VENTokenFieldDataSource
{
    @IBOutlet var nearBtn:UIButton!
    @IBOutlet var otherLocBtn:UIButton!
    @IBOutlet var countryBtn:UIButton!
    @IBOutlet var cityBtn:UIButton!
    @IBOutlet var countryArrow:UIImageView!
    @IBOutlet var cityArrow:UIImageView!
    @IBOutlet var lblCountries:UILabel!
    @IBOutlet var lblCities:UILabel!
    @IBOutlet var txtArea:UITextField!
    @IBOutlet var txtAuthor:UITextField!
    @IBOutlet var txtBook:UITextField!
    
    @IBOutlet var mainScrollView:UIScrollView!
    
    @IBOutlet var heightConstraint:NSLayoutConstraint!
    
    let countryDropDown = DropDown()
    let cityDropDown = DropDown()
    
    let languageDropDown = DropDown()
    let genereDropDown = DropDown()
    
    @IBOutlet var txtLanguage:VENTokenField!
    @IBOutlet var txtGenere:VENTokenField!
    
    var languagesArray = NSMutableArray()
    var generesArray = NSMutableArray()
    
    var lang = ""
    var gen = ""
    
    var tag = 0
    var countryFlag = false

    private var countryList = [Country]()
    let languagesList = populateLanguages()
    let generesList = populateGeneres()
    
    override func viewDidLoad()
    {
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
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        mainScrollView.contentSize = CGSize(width: 0, height: 800)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    func getCountires()
    {
        countryDropDown.anchorView = countryBtn
        countryDropDown.bottomOffset = CGPoint(x: 0, y: countryBtn.bounds.height)
        
        let countries = Countries()
        countryList = countries.countries
        
        var countriesList = [String]()
        countriesList.append("All Countries")
        for i in 1..<countryList.count
        {
            let countryObj:Country = countryList[i]
            countriesList.append(countryObj.name!)
        }
        
        countryDropDown.dataSource = countriesList
        
        countryDropDown.selectionAction = { [weak self] (index, item) in
            self?.lblCountries.text = item
            
            if index > 0
            {
                self!.countryFlag = true
            }
            else
            {
                self!.countryFlag = false
            }
        }
    }
    
    func getCities(country: String)
    {
        cityDropDown.anchorView = cityBtn
        cityDropDown.bottomOffset = CGPoint(x: 0, y: cityBtn.bounds.height)
        
        countryList = [Country]()
        var citiesList = [String]()
        if let path = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let cities = jsonResult[country] as? NSArray {
                   citiesList.append("All Cities")
                    for i in 1..<cities.count
                    {
                        let cityName = cities.object(at: i)
                        let cityObj:Country = Country(countryCode: String(format: "%ia",i), phoneExtension: "", cityName: cityName as! String)
                        countryList.append(cityObj)
                        citiesList.append(cityName as! String)
                    }
                }
            } catch {
                // handle error
            }
        }
        
        cityDropDown.dataSource = citiesList
        
        cityDropDown.selectionAction = { [weak self] (index, item) in
            self?.lblCities.text = item
        }
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
        }
    }
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
       self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func locationBtnAction(_ button:UIButton)
    {
        if button.tag == 1001
        {
            nearBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            otherLocBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            
            countryBtn.alpha = 0
            cityBtn.alpha = 0
            countryArrow.alpha = 0
            cityArrow.alpha = 0
            countryFlag = true
            
            lblCountries.text = userDefaults.string(forKey: "country")! as String
            lblCities.text = userDefaults.string(forKey: "city")! as String
            txtArea.text = userDefaults.string(forKey: "area")! as String
        }
        else
        {
            nearBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            otherLocBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            
            countryBtn.alpha = 1
            cityBtn.alpha = 1
            countryArrow.alpha = 1
            cityArrow.alpha = 1
            countryFlag = false
            
            lblCountries.text = "All Countries"
            lblCities.text = "All Cities"
            txtArea.text = ""
        }
    }
    
    @IBAction func clickBtnAction(_ button:UIButton)
    {
        if button.tag == 1001
        {
            tag = 1001
            getCountires()
            countryDropDown.show()
        }
        else
        {
            if countryFlag
            {
                tag = 1002
                getCities(country: lblCountries.text!)
                cityDropDown.show()
            }
            else
            {
                let alert = UIAlertController(title: "", message: "Please select country.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func searchBtnAction(_ button:UIButton)
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
        
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        advanceFilter()
    }
    
    @IBAction func keyboardBtnAction(_ button:UIButton)
    {
       hideKeyboard()
    }
    
    func advanceFilter()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/advanceSearch")!)
            request.httpMethod = "POST"
           
            let searchCountry = (lblCountries.text == "All Countries") ? "" : lblCountries.text
            let searchCity = (lblCities.text == "All Cities") ? "" : lblCities.text
            let searchArea = txtArea.text!
            
            let userLat:String = userDefaults.string(forKey: "latitude")! as String
            let userLng:String = userDefaults.string(forKey: "longitude")! as String
            
            let postParameters = String(format:"login_id=%i&lat=%@&long=%@&country=%@&city=%@&area=%@&languages=%@&genres=%@&loc_flag=0&author=%@&book=%@", userObj.userID, userLat, userLng, searchCountry!, searchCity!, searchArea, lang, gen, txtAuthor.text!, txtBook.text!)
            
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
                        self.loadAuthors(jsonResult: jsonResult!)
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
    
    func loadAuthors(jsonResult: [String: Any])
    {
        authorsArray = NSMutableArray()
        
        let authorsID = NSMutableArray()
        
        //Filtered Auhtors
        let authArray:NSArray = jsonResult["all_users"] as! NSArray
        
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
            
            if !authorsID.contains(authorObj.userID)
            {
                authorsID.add(authorObj.userID)
                authorsArray.add(authorObj)
            }
        }
        
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        hideKeyboard()
    
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == txtArea && !countryFlag
        {
            let alert = UIAlertController(title: nil , message: "Please select country.", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "OK", style: .cancel)
            { (action:UIAlertAction) in
                self.txtArea.resignFirstResponder()
            }
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
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
    
    func hideKeyboard()
    {
        txtArea.resignFirstResponder()
        txtAuthor.resignFirstResponder()
        txtBook.resignFirstResponder()
        txtGenere.resignFirstResponder()
        txtLanguage.resignFirstResponder()
    }
    
    func tokenField(_ tokenField: VENTokenField, didEnterText text: String)
    {
        if tokenField.tag == 1001
        {
            self.languagesArray.add(text)
            self.txtLanguage.reloadData()
        }
        else if tokenField.tag == 1002
        {
            self.generesArray.add(text)
            self.txtGenere.reloadData()
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate method
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func tokenField(_ tokenField: VENTokenField, didChangeText text: String?)
    {
        if tokenField.tag == 1001
        {
            if generesArray.count < 5
            {
                getLanguages(searchText: text!)
            }
            else
            {
                self.txtLanguage.reloadData()
            }
        }
        else if tokenField.tag == 1002
        {
            if generesArray.count < 3
            {
                getGeneres(searchText: text!)
            }
            else
            {
                txtGenere.resignFirstResponder()
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
        }
        else if tokenField.tag == 1002
        {
            self.generesArray.removeObject(at: Int(index))
            self.txtGenere.reloadData()
        }
    }
    
    func tokenField(_ tokenField: VENTokenField, titleForTokenAt index: UInt) -> String
    {
        if tokenField.tag == 1001
        {
            return self.languagesArray.object(at: Int(index)) as! String
        }
        else
        {
            return self.generesArray.object(at: Int(index)) as! String
        }
    }
    
    func numberOfTokens(in tokenField: VENTokenField) -> UInt
    {
        if tokenField.tag == 1001
        {
            return UInt(self.languagesArray.count)
        }
        else
        {
            return UInt(self.generesArray.count)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
