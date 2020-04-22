//
//  ProfileViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 10/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import MBProgressHUD
import DropDown

var userID = 0
var code = 0
var userName = ""
var userMName = ""
var userLName = ""
var userPassword = ""
var userEmail = ""
var userStatus = ""
var gender = ""
var age = ""
var locIndicator = ""
var area = ""
var city = ""
var country = ""
var descp = ""
var languages = ""
var generes = ""
var authors = ""
var bookType = ""
var photo:UIImage!
var photoFlag = false
var fromProfile = false

class Profile1ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var mainScrollView:UIScrollView!
    
    @IBOutlet var imgView:UIImageView!
    @IBOutlet var statusImgView:UIImageView!
    
    @IBOutlet var maleBtn:UIButton!
    @IBOutlet var femaleBtn:UIButton!
    @IBOutlet var nearBtn:UIButton!
    @IBOutlet var otherLocBtn:UIButton!
    @IBOutlet var skipBtn:UIButton!
    @IBOutlet var backBtn:UIButton!
    
    @IBOutlet var txtName:UITextField!
    @IBOutlet var txtMName:UITextField!
    @IBOutlet var txtLName:UITextField!
    @IBOutlet var txtAge:UITextField!
    @IBOutlet var txtCountry:UITextField!
    @IBOutlet var txtCity:UITextField!
    @IBOutlet var txtArea:UITextField!
    
    @IBOutlet var datePicker:UIDatePicker!
    
    @IBOutlet var topConstraint:NSLayoutConstraint!
    @IBOutlet var calendarConstraint:NSLayoutConstraint!
    
    @IBOutlet var locView:UIView!
    
    let imagePicker = UIImagePickerController()
    
    let countryDropDown = DropDown()
    let cityDropDown = DropDown()
    
    private var countryList = [Country]()
    
    override func viewDidLoad()
    {
        if fromProfile
        {
            backBtn.alpha = 1
//            skipBtn.alpha = 0
        }
        else
        {
            backBtn.alpha = 0
//            skipBtn.alpha = 1
        }
        
        self.imagePicker.delegate = self
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        
        if userObj.userID > 0
        {
            if userObj.photo != nil
            {
                imgView.image = userObj.photo
                photo = userObj.photo
            }
            else
            {
                if userObj.photoURL.length > 0
                {
                    Alamofire.request(userObj.photoURL as String).responseImage { response in
                        
                        if let image = response.result.value {
                            DispatchQueue.main.async() {
                                userObj.photo = image
                                self.imgView.image = userObj.photo
                                photo = userObj.photo
                            }
                        }
                    }
                }
            }
            
            userName = userObj.userName as String
            userMName = userObj.userMName as String
            userLName = userObj.userLName as String
            age = userObj.age as String
            country = userObj.country as String
            city = userObj.city as String
            area = userObj.area as String
            userStatus = userObj.userStatus as String
            gender = userObj.gender as String
            locIndicator = userObj.locIndicator as String
            descp = userObj.descp as String
            languages = userObj.languages as String
            generes = userObj.generes as String
            authors = userObj.authors as String
            bookType = userObj.bookType as String
        }
        else
        {
            country = userDefaults.string(forKey: "country")! as String
            city = userDefaults.string(forKey: "city")! as String
            area = userDefaults.string(forKey: "area")! as String
        }
        
        txtName.text = userName
        txtMName.text = userMName
        txtLName.text = userLName
        txtAge.text = age
        txtCountry.text = country
        txtCity.text = city
        txtArea.text = area
        
        if userStatus.isEqual("writer")
        {
            statusImgView.image = UIImage(named: "writer_active")
        }
        else if userStatus.isEqual("bookstore")
        {
            statusImgView.image = UIImage(named: "bookstore_active")
        }
        else
        {
            statusImgView.image = UIImage(named: "reader_active")
        }
        
        if gender.isEqual("Female")
        {
            maleBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            femaleBtn.setImage(UIImage(named: "radio_active"), for: .normal)
        }
        else
        {
            gender = "Male"
            maleBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            femaleBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
        }
        
        if locIndicator.isEqual("near")
        {
            locIndicator = "near"
            nearBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            otherLocBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            locView.alpha = 1
            topConstraint.constant = 200
        }
        else if locIndicator.isEqual("other")
        {
            locIndicator = "other"
            nearBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            otherLocBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            locView.alpha = 1
            topConstraint.constant = 200
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        mainScrollView.contentSize = CGSize(width: 0, height: 1000)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.mainScrollView.contentOffset.y = 0
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func hideKayboardAction(_ button:UIButton)
    {
        hideKeyboard()
    }
    
    @IBAction func ageBtnAction(_ button:UIButton)
    {
        hideKeyboard()
        calendarConstraint.constant = -240
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
            self.mainScrollView.contentOffset.y = 100
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func cancelBtnAction(_ button:UIButton)
    {
        calendarConstraint.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
            self.mainScrollView.contentOffset.y = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func doneBtnAction(_ button:UIButton)
    {
        calendarConstraint.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
            self.mainScrollView.contentOffset.y = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: datePicker.date)
        let date2 = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.year], from: date1, to: date2)
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy"
//        let dateStr = formatter.string(from: datePicker.date)
        txtAge.text = String(format: "%i", components.year!)
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
            
            userName = txtName.text!
            userMName = txtName.text!
            userLName = txtName.text!
            age = txtAge.text!
            country = txtCountry.text!
            city = txtCity.text!
            area = txtArea.text!
            
            let postParameters = String(format:"u_id=%i&f_name=%@&m_name=%@&l_name=%@&user_status=%@&gender=%@&age=%@&country=%@&city=%@&area=%@&description=%@&languages=%@&genres=%@&authors=%@&type=%@&image=%@&lat=%@&long=%@&u_location=%@", userObj.userID, userName, userMName,userLName, userStatus, gender, age, country, city, area, descp, userObj.languages, userObj.generes, userObj.authors, userObj.bookType, photoStr, userLat, userLng, locIndicator)
            
            request.httpBody = postParameters.data(using: .utf8)
//            print(postParameters)
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
                        userObj.locIndicator = locIndicator as NSString
                        
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
    
    @IBAction func cameraBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: nil , message: "", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default)
        { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                //let imagePicker = UIImagePickerController()
                self.imagePicker.sourceType =
                    UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let gallery = UIAlertAction(title: "Photo Library", style: .default)
        { (action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.savedPhotosAlbum)
            {
                //let imagePicker = UIImagePickerController()
                self.imagePicker.sourceType =
                    UIImagePickerControllerSourceType.photoLibrary
                //imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { (action:UIAlertAction) in
            
        }
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let image = resizeImage(image: img, toTheSize: CGSize(width: screenSize.width, height: screenSize.width))
        let size = CGSize(width: 184, height: 184)
        let image = img.af_imageAspectScaled(toFill: size)
        imgView.image = image
        photo = image
        photoFlag = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func statusBtnAction(_ button:UIButton)
    {
        if button.tag == 1001
        {
            userStatus = "1"
            statusImgView.image = UIImage(named: "reader_active")
        }
        else if button.tag == 1002
        {
            userStatus = "2"
            statusImgView.image = UIImage(named: "writer_active")
        }
        else if button.tag == 1003
        {
            userStatus = "3"
            statusImgView.image = UIImage(named: "bookstore_active")
        }
    }
    
    @IBAction func genderBtnAction(_ button:UIButton)
    {
        if button.tag == 1001
        {
            gender = "Male"
            maleBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            femaleBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
        }
        else
        {
            gender = "Female"
            maleBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            femaleBtn.setImage(UIImage(named: "radio_active"), for: .normal)
        }
    }
    
    @IBAction func locationBtnAction(_ button:UIButton)
    {
        topConstraint.constant = 200
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
            self.locView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        if button.tag == 1001
        {
            locIndicator = "near"
            nearBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            otherLocBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            
            txtCountry.text = userDefaults.string(forKey: "country")! as String
            txtCity.text = userDefaults.string(forKey: "city")! as String
            txtArea.text = userDefaults.string(forKey: "area")! as String
        }
        else
        {
            locIndicator = "other"
            nearBtn.setImage(UIImage(named: "radio_inactive"), for: .normal)
            otherLocBtn.setImage(UIImage(named: "radio_active"), for: .normal)
            
            txtCountry.text = ""
            txtCity.text = ""
            txtArea.text = ""
        }
    }
    
    @IBAction func nextBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if (txtName.text?.isEmpty)!
        {
            alert.message = "Please enter your first name."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtLName.text?.isEmpty)!
        {
            alert.message = "Please enter your last name."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtAge.text?.isEmpty)!
        {
            alert.message = "Please enter your age."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtCountry.text?.isEmpty)!
        {
            alert.message = "Please enter your country."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtCity.text?.isEmpty)!
        {
            alert.message = "Please your city."
            self.present(alert, animated: true, completion: nil)
        }
        else if (txtArea.text?.isEmpty)!
        {
            alert.message = "Please enter your area."
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            
            userName = txtName.text!
            userMName = txtMName.text!
            userLName = txtLName.text!
            age = txtAge.text!
            country = txtCountry.text!
            city = txtCity.text!
            area = txtArea.text!
            
            let address = area + ", " + city + ", " + country
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: self.view, animated: true)
                            
                            alert.message = "Unable to find your location. Please enter valid Country/City/Area."
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return
                    }
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                userDefaults.set(location.coordinate.latitude, forKey: "latitude")
                userDefaults.set(location.coordinate.longitude, forKey: "longitude")
               
                if fromProfile
                {
                    let profile2VC = (self.storyboard?.instantiateViewController(withIdentifier: "Profile2ViewController")) as! Profile2ViewController
                    self.navigationController?.pushViewController(profile2VC, animated: true )
                }
                else
                {
                    let profile3VC = (self.storyboard?.instantiateViewController(withIdentifier: "Profile3ViewController")) as! Profile3ViewController
                    self.navigationController?.pushViewController(profile3VC, animated: true )
                }
            }
        }
    }
    
    @IBAction func countryValueChanged(_ textField: UITextField)
    {
        let searchText = textField.text!
        
        countryDropDown.anchorView = txtCountry
        countryDropDown.bottomOffset = CGPoint(x: 0, y: txtCountry.bounds.height)
        
        let countries = Countries()
        let countryList = countries.countries
        
        var filteredList = [String]()
        
        for i in 0..<countryList.count
        {
            let countryObj:Country = countryList[i]
            
            let range = countryObj.name!.range(of: searchText, options: .caseInsensitive)
            
            if range != nil
            {
                filteredList.append(countryObj.name!)
            }
        }
        
        countryDropDown.dataSource = filteredList
        
        if filteredList.count > 0
        {
            countryDropDown.show()
        }
        else
        {
            countryDropDown.hide()
        }
        
        countryDropDown.selectionAction = { [weak self] (index, item) in
            self?.txtCountry.text = item
        }
    }
    
    @IBAction func cityValueChanged(_ textField: UITextField)
    {
        let searchText = textField.text!
        
        cityDropDown.anchorView = txtCity
        cityDropDown.bottomOffset = CGPoint(x: 0, y: txtCity.bounds.height)
        
        var filteredList = [String]()
        if let path = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let cities = jsonResult[txtCountry.text!] as? NSArray {
                    for i in 0..<cities.count
                    {
                        let cityName:String = cities.object(at: i) as! String
                        let range = cityName.range(of: searchText, options: .caseInsensitive)
                        
                        if range != nil && !(range?.isEmpty)!
                        {
                            filteredList.append(cityName)
                        }
                    }
                }
            } catch {
                // handle error
            }
        }
        
        cityDropDown.dataSource = filteredList
        
        if filteredList.count > 0
        {
            cityDropDown.show()
        }
        else
        {
            cityDropDown.hide()
        }
        
        cityDropDown.selectionAction = { [weak self] (index, item) in
            self?.txtCity.text = item
        }
    }
    
    func addToolBar(textField: UITextField)
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 42/255, green: 113/255, blue: 158/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed()
    {
        txtCountry.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
            self.mainScrollView.contentOffset.y = 300
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if textField == txtCountry || textField == txtCity || textField == txtArea
        {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
                self.mainScrollView.contentOffset.y = 300
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == txtName
        {
            txtMName.becomeFirstResponder()
        }
        else if textField == txtMName
        {
            txtLName.becomeFirstResponder()
        }
        else if textField == txtLName
        {
            txtCountry.becomeFirstResponder()
        }
        else if textField == txtCountry
        {
            txtCity.becomeFirstResponder()
        }
        else if textField == txtCity
        {
            txtArea.becomeFirstResponder()
        }
        else if textField == txtArea
        {
            hideKeyboard()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        countryDropDown.hide()
        cityDropDown.hide()
        
        if textField == txtAge
        {
            addToolBar(textField: textField)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeyboard()
    }
    
    func hideKeyboard()
    {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations:{
//            self.mainScrollView.contentOffset.y = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        txtName.resignFirstResponder()
        txtMName.resignFirstResponder()
        txtLName.resignFirstResponder()
        txtAge.resignFirstResponder()
        txtCountry.resignFirstResponder()
        txtCity.resignFirstResponder()
        txtArea.resignFirstResponder()
    }
}
