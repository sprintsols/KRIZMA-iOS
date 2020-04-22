//
//  HomeViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 10/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD
import Alamofire
import Applozic

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate
{
    @IBOutlet var txtSearch:UITextField!
    @IBOutlet var tblView:UITableView!
    
    @IBOutlet var nearBtn:UIButton!
    @IBOutlet var recommendedBtn:UIButton!
    @IBOutlet var lblNoResult:UILabel!
    
    @IBOutlet var lblFilter:UILabel!
    @IBOutlet var filterView:UIView!
    
    var refresher:UIRefreshControl!
    
    private var dateCellExpanded: Bool = false
    
    var locationManager = CLLocationManager()
    
    var userLoginFlag = true
    
    var filteredArray = NSMutableArray()
    
    var nearFlag = false
    
    var filterType = 1001
    
    override func viewDidLoad()
    {
        nearFlag = false
        
        filterView.layer.cornerRadius = 5
        filterView.layer.masksToBounds = true
        filterView.layer.borderColor = UIColor.lightGray.cgColor
        filterView.layer.borderWidth = 1
        
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        else
        {
            let alert:UIAlertView = UIAlertView(title:"", message: "", delegate: nil,cancelButtonTitle: "OK")
            alert.message = "Please allow GPS from device settings to access the authors near your location."
            alert.show()
        }
        
        if !userLoginFlag
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            userLogin()
        }
        else
        {
            if userObj.userID > 0
            {
                self.connectUser()
            }
        }
        
        self.refresher = UIRefreshControl()
        self.tblView!.alwaysBounceVertical = true
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tblView!.addSubview(refresher)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        filteredArray = authorsArray
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
        
        if filteredArray.count == 0
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 1
            }
        }
        else
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 0
            }
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    func connectUser()
    {
        let alUser : ALUser =  ALUser()
        alUser.userId = String(format: "%i", userObj.userID)
        alUser.email = userObj.userEmail as String?
        alUser.imageLink = userObj.photoURL as String?
        alUser.displayName = userObj.userName as String?
        alUser.password = "Sprint1234!"
        
        
        //Saving these details
        ALUserDefaultsHandler.setUserId(alUser.userId)
        ALUserDefaultsHandler.setEmailId(alUser.email)
        ALUserDefaultsHandler.setDisplayName(alUser.displayName)
        
        
        //Registering or Login in the User
        let chatManager = ALChatManager(applicationKey: ChatAPIKey as NSString)
        chatManager.registerUser(alUser) { (response, error) in
            if (error == nil)
            {
                print("Error");
            }
            else
            {
                print("Login success")
            }
        }
    }
    
    @objc func loadData()
    {
        if nearFlag
        {
            advanceFilter(locFlag: true)
        }
        else
        {
            advanceFilter(locFlag: false)
        }
    }
    
    @IBAction func filterBtnAction(_ button:UIButton)
    {
        txtSearch.text = ""
        filterView.alpha = 1
    
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func filterSelectionBtnAction(_ button:UIButton)
    {
        filterType = button.tag
        lblFilter.text = button.titleLabel?.text
        filterView.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func advSearchBtnAction(_ button:UIButton)
    {
        txtSearch.text = ""
        let searchFilterVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchFilterVC")) as! SearchFilterVC
        self.navigationController?.pushViewController(searchFilterVC, animated: true )
    }
    
    @IBAction func sortBtnAction(_ button:UIButton)
    {
        txtSearch.text = ""
        if button.tag == 1001
        {
            nearBtn.setTitleColor(UIColor(red: 31/255, green: 151/255, blue: 243/255, alpha:1), for: .normal)
            recommendedBtn.setTitleColor(UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha:1), for: .normal)
            
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            advanceFilter(locFlag: true)
        }
        else
        {
            recommendedBtn.setTitleColor(UIColor(red: 31/255, green: 151/255, blue: 243/255, alpha:1), for: .normal)
            nearBtn.setTitleColor(UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha:1), for: .normal)
            
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            advanceFilter(locFlag: false)
        }
    }
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            let notifVC = (self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC")) as! NotificationsVC
            self.navigationController?.pushViewController(notifVC, animated: false)
        }
        else if button.tag == 1002
        {
            let chatManager = ALChatManager(applicationKey: ChatAPIKey as NSString)
            chatManager.launchChat(self)
        }
        else if button.tag == 1004
        {
            let favouritesVC = (self.storyboard?.instantiateViewController(withIdentifier: "FavouritesVC")) as! FavouritesVC
            self.navigationController?.pushViewController(favouritesVC, animated: false)
        }
        else if button.tag == 1005
        {
            let menuProfileVC = (self.storyboard?.instantiateViewController(withIdentifier: "MenuProfileVC")) as! MenuProfileVC
            self.navigationController?.pushViewController(menuProfileVC, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let authorObj:UserObject = filteredArray.object(at: indexPath.row) as! UserObject
        
        if authorObj.expandFlag
        {
            return 316
        }
        else
        {
            return 112
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UserCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
       
        cell.subView.layer.cornerRadius = 10
        cell.subView.layer.masksToBounds = true
        
        cell.subView2.layer.cornerRadius = 10
        cell.subView2.layer.masksToBounds = true
        
        cell.imgView.layer.cornerRadius = 10
        cell.imgView.layer.masksToBounds = true
        
        let authorObj:UserObject = filteredArray.object(at: indexPath.row) as! UserObject
        
        cell.lblName.text = String(format: "%@%@%@", authorObj.userName, authorObj.userMName.length > 0 ? String(format: " %@", authorObj.userMName) : "", authorObj.userLName.length > 0 ? String(format: " %@", authorObj.userLName) : "")
        cell.lblAge.text = authorObj.age as String
        cell.lblGender.text = authorObj.gender as String
        cell.lblAddress.text = String(format: "%@, %@, %@", authorObj.area, authorObj.city, authorObj.country)
        cell.lblGeneres.text = authorObj.generes as String
        cell.lblDistance.text = String(format: "%@ km", authorObj.distStr)
        cell.lblLanguages.text = authorObj.languages as String
        cell.lblFavBooks.text = authorObj.favBooksName as String
        cell.lblFavAuthors.text = authorObj.favAuthorsName as String
        
        if authorObj.photo != nil
        {
            cell.imgView.image = authorObj.photo
        }
        else
        {
            cell.imgView.image = UIImage(named: "prof_pic")
        }
        
        if authorObj.favFlag == 1
        {
            cell.favBtn.setImage(UIImage(named: "fav_star_active"), for: .normal)
        }
        else
        {
            cell.favBtn.setImage(UIImage(named: "fav_star_inactive"), for: .normal)
        }
        
        cell.favBtn.addTarget(self, action: #selector(favBtnAction(_:)), for: .touchUpInside)
        cell.favBtn.tag = indexPath.row + 1000
        
        cell.btnExpand.addTarget(self, action: #selector(expandBtnAction(_:)), for: .touchUpInside)
        cell.btnExpand.tag = indexPath.row + 2000
//        cell.btnSeeMore.addTarget(self, action: #selector(seeMoreBtnAction(_:)), for: .touchUpInside)
//        cell.btnSeeMore.tag = indexPath.row + 1000
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        txtSearch.text = ""
        let authorsProfileVC = (self.storyboard?.instantiateViewController(withIdentifier: "AuthorsProfileVC")) as! AuthorsProfileVC
        let authorObj:UserObject = filteredArray.object(at: indexPath.row) as! UserObject
        authorsProfileVC.authorObj = authorObj
        self.navigationController?.pushViewController(authorsProfileVC, animated: true )
    }
    
    @IBAction func expandBtnAction(_ button: UIButton)
    {
        let authorObj:UserObject = filteredArray.object(at:  button.tag - 2000) as! UserObject
        changeExpandFlag(authorID:authorObj.userID)
        authorObj.expandFlag = !authorObj.expandFlag
        
        if authorObj.expandFlag
        {
            button.setImage(#imageLiteral(resourceName: "minus"), for: .normal)
        }
        else
        {
            button.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        }
        
//        tblView.reloadData()
        
        tblView.beginUpdates()
        tblView.endUpdates()
    }
    
    func changeExpandFlag(authorID: Int)
    {
        for i in 0..<filteredArray.count
        {
            let authorObj:UserObject = filteredArray.object(at:  i) as! UserObject
            
            if authorObj.userID != authorID
            {
                authorObj.expandFlag = false
            }
        }
    }
    
    @IBAction func favBtnAction(_ button: UIButton)
    {
        let authorObj:UserObject = filteredArray.object(at:  button.tag - 1000) as! UserObject
        
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        if authorObj.favFlag == 1
        {
            removeFavAuhtor(index: button.tag - 1000)
        }
        else
        {
            addFavAuhtor(index: button.tag - 1000)
        }
    }
    
    @IBAction func handleValueChanged(_ textField: UITextField)
    {
        filteredArray = NSMutableArray()
        
        let searchText = txtSearch.text!
        
        for i in 0..<authorsArray.count
        {
            let authorObj:UserObject = authorsArray.object(at: i) as! UserObject
            
            if filterType == 1001
            {
                let name = authorObj.userName as String
                let range = name.range(of: searchText, options: .caseInsensitive)
                
                if range != nil
                {
                    filteredArray.add(authorObj)
                }
            }
            else if filterType == 1002
            {
                let langArray = authorObj.languages.components(separatedBy: ",")
                
                inner: for i in 0..<langArray.count
                {
                    let name:String = langArray[i]
                    if !name.isEmpty
                    {
                        let range = name.range(of: searchText, options: .caseInsensitive)
                        
                        if range != nil
                        {
                            filteredArray.add(authorObj)
                            break inner
                        }
                    }
                }
            }
            else if filterType == 1003
            {
                let genArray = authorObj.generes.components(separatedBy: ",")
                
                inner: for i in 0..<genArray.count
                {
                    let name:String = genArray[i]
                    if !name.isEmpty
                    {
                        let range = name.range(of: searchText, options: .caseInsensitive)
                        
                        if range != nil
                        {
                            filteredArray.add(authorObj)
                            break inner
                        }
                    }
                }
            }
            else if filterType == 1004
            {
                let userStatus = authorObj.userStatus as String
                let range = userStatus.range(of: searchText, options: .caseInsensitive)
                
                if range != nil
                {
                    filteredArray.add(authorObj)
                }
            }
            else
            {
                let booksArray = authorObj.addedBooksArray
                
                inner: for j in 0..<booksArray.count
                {
                    let bookObj:BookObject = booksArray.object(at: j) as! BookObject
                    
                    let bookName = bookObj.bookName as String
                    let range = bookName.range(of: searchText, options: .caseInsensitive)
                    
                    if range != nil
                    {
                        filteredArray.add(authorObj)
                        break inner
                    }
                }
            }
        }
        
        if (txtSearch.text?.isEmpty)!
        {
            filteredArray = authorsArray
        }
        
        tblView.reloadData()
        
        if filteredArray.count == 0
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 1
            }
        }
        else
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 0
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
        txtSearch.resignFirstResponder()
        
        filterView.alpha = 0
        
        UIView.animate(withDuration: 0.8, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation = locations.last
        
        if userLocation != nil
        {
            userDefaults.set(userLocation!.coordinate.latitude, forKey: "latitude")
            userDefaults.set(userLocation!.coordinate.longitude, forKey: "longitude")
            
            getAddressFromLocation(userLocation: userLocation!)
            
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        locationManager.stopUpdatingLocation()
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
    
    func userLogin()
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/userLogin")!)
            print(request)
            request.httpMethod = "POST"
            
            let userID:String = userDefaults.string(forKey: "userID")! as String
            let userLat:String = userDefaults.string(forKey: "latitude")! as String
            let userLng:String = userDefaults.string(forKey: "longitude")! as String
            
//            let userLat:String = "32.176661"
//            let userLng:String = "74.1900682"
            
            let postParameters = String(format:"u_id=%@&lat=%@&long=%@", userID, userLat, userLng)
            
            request.httpBody = postParameters.data(using: .utf8)
            //print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async(){
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.refresher.endRefreshing()
                }
                
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    DispatchQueue.main.async(){
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
                //                    print("responseString = \(String(describing: responseString))")
                
                let jsonResult = convertToDictionary(text: responseString!)
                print(jsonResult)
                
                if jsonResult != nil
                {
                    let loginCode:NSString = jsonResult!["code"] as! NSString
                    
                    if loginCode == "101"
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
                alert.message = "Internet Connection Problem. Please check your Wifi or Data network."
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loadUserData(jsonResult: [String: Any])
    {
        userObj = UserObject()
        authorsArray = NSMutableArray()
        notificationsArray = NSMutableArray()
        filteredArray = NSMutableArray()
        
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
        
        if userObj.userID > 0
        {
            self.connectUser()
        }
        
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
                            self.tblView.reloadData()
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
            filteredArray = authorsArray
        }
        
        if filteredArray.count > 0
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 0
                self.tblView.reloadData()
            }
        }
        else
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 1
            }
        }
    }
    
    func advanceFilter(locFlag:Bool)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var serviceName = ""
            var postParameters = ""
            
            let userLat:String = userDefaults.string(forKey: "latitude")! as String
            let userLng:String = userDefaults.string(forKey: "longitude")! as String
            
            if locFlag
            {
                serviceName = "/advanceSearch"
                postParameters = String(format:"login_id=%i&lat=%@&long=%@&loc_flag=1", userObj.userID, userLat, userLng)
            }
            else
            {
                var booksStr = ""
                
                for i in 0..<userObj.addedBooksArray.count
                {
                    let bookObj:BookObject = userObj.addedBooksArray.object(at: i) as! BookObject
                    
                    booksStr = String(format: "%@%@",booksStr, booksStr.isEmpty ? bookObj.bookName : "," + (bookObj.bookName as String))
                }
                
                serviceName = "/recomendedSearch"
                postParameters = String(format:"login_id=%i&lat=%@&long=%@&languages=%@&genres=%@&books=%@", userObj.userID, userLat, userLng, userObj.languages, userObj.generes, booksStr)
            }
            
            var request = URLRequest(url: URL(string: webURL + serviceName)!)
            request.httpMethod = "POST"
            
            request.httpBody = postParameters.data(using: .utf8)
            //print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async(){
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.refresher.endRefreshing()
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
                print(jsonResult)
                
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        self.nearFlag = locFlag
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
                            self.tblView.reloadData()
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
        filteredArray = authorsArray
        
        if filteredArray.count == 0
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 1
            }
        }
        else
        {
            DispatchQueue.main.async() {
                self.lblNoResult.alpha = 0
            }
        }
        
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
    }
    
    func addFavAuhtor(index: Int)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/addFavouriteUser")!)
            request.httpMethod = "POST"
            
            let authorObj:UserObject = filteredArray.object(at:  index) as! UserObject
            
            let postParameters = String(format:"u_id=%i&author_id=%i", userObj.userID, authorObj.userID)
            
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
                
                if jsonResult != nil
                {
                    DispatchQueue.main.async {
                        
                        authorObj.favFlag = 1
                        userObj.favAuthorsArray.add(authorObj)
                        
                        self.tblView.reloadData()
                        
                        alert.message = "Author has been added into your favourites."
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
    
    func removeFavAuhtor(index: Int)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/removeFavouriteUser")!)
            request.httpMethod = "POST"
            
            let authorObj:UserObject = filteredArray.object(at:  index) as! UserObject
            
            let postParameters = String(format:"u_id=%i&author_id=%i", userObj.userID, authorObj.userID)
            
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
                
                if jsonResult != nil
                {
                    DispatchQueue.main.async {
                        
                        authorObj.favFlag = 0
                        userObj.favAuthorsArray.remove(authorObj)
                       
                        self.tblView.reloadData()
                        
                        alert.message = "Author has been removed from your favourites."
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
}

