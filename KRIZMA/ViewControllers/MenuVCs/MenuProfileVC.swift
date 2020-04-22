//
//  MenuProfileVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 15/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import Alamofire

class MenuProfileVC: UIViewController
{
    @IBOutlet var imgView:UIImageView!
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblAge:UILabel!
    @IBOutlet var lblGender:UILabel!
    @IBOutlet var lblCountry:UILabel!
    
    @IBOutlet var typeScrollView:UIScrollView!
    @IBOutlet var languageBtn:UIButton!
    @IBOutlet var authorBtn:UIButton!
    @IBOutlet var genreBtn:UIButton!
    
    @IBOutlet var booksView:UIView!
    @IBOutlet var booksScrollView:UIScrollView!
    @IBOutlet var addBookBtn:UIButton!
    @IBOutlet var lblTap:UILabel!
    
    @IBOutlet var plusBtn:UIButton!
    
    var languagesArray:[String] = []
    var generesArray:[String] = []
    var authorsArray:[String] = []
    
    override func viewDidLoad()
    {
        imgView.layer.cornerRadius = 43
        imgView.layer.masksToBounds = true
        
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
        
        lblName.text = String(format: "%@%@%@", userObj.userName, userObj.userMName.length > 0 ? String(format: " %@", userObj.userMName) : "", userObj.userLName.length > 0 ? String(format: " %@", userObj.userLName) : "")
        lblAge.text =  String(format: "Age: %@",userObj.age)
        lblGender.text = userObj.gender as String
        lblCountry.text = userObj.country as String
        
        fillArrays()
        fillScrollView(type:3)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if userObj.addedBooksArray.count > 0
        {
            addBookBtn.alpha = 0
            lblTap.alpha = 0
            plusBtn.alpha = 1
        }
        else
        {
            addBookBtn.alpha = 1
            lblTap.alpha = 1
            plusBtn.alpha = 0
        }
        
        fillBooksView()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    func fillArrays()
    {
        languagesArray = userObj.languages.components(separatedBy: ",")
        generesArray = userObj.generes.components(separatedBy: ",")
        authorsArray = userObj.authors.components(separatedBy: ",")
    }
    
    func fillBooksView()
    {
        for view in booksScrollView.subviews
        {
            view.removeFromSuperview()
        }
        
        var xPos:Int = 0
        
        for i in 0..<userObj.addedBooksArray.count
        {
            let bookObj:BookObject = userObj.addedBooksArray.object(at: i) as! BookObject
            
            let bookBtn = UIButton()
            
            let width:Int = Int(booksScrollView.frame.height)
            
            bookBtn.frame = CGRect(x: xPos, y: 0, width: width, height: width)
            bookBtn.layer.cornerRadius = 5
            bookBtn.layer.masksToBounds = true
            
//            if i < 3
//            {
                bookBtn.setBackgroundImage(UIImage(named: "book_bg"), for: .normal)
                if bookObj.photo != nil
                {
                    bookBtn.setBackgroundImage(bookObj.photo, for: .normal)
                }
                else
                {
                    if bookObj.photoURL.length > 0
                    {
                        Alamofire.request(bookObj.photoURL as String).responseImage { response in
                            
                            if let image = response.result.value {
                                DispatchQueue.main.async() {
                                    bookObj.photo = image
                                    bookBtn.setBackgroundImage(bookObj.photo, for: .normal)
                                }
                            }
                        }
                    }
                }
                booksScrollView.addSubview(bookBtn)
//            }
//            else
//            {
//                bookBtn.setBackgroundImage(UIImage(named: "book_number_bg"), for: .normal)
//                let lblNumber = UILabel()
//                lblNumber.frame = CGRect(x: xPos, y: 0, width: width, height: width)
//                lblNumber.backgroundColor = UIColor.clear
//                lblNumber.textColor = UIColor.white
//                lblNumber.textAlignment = .center
//                lblNumber.text = String(format:"+%i",userObj.addedBooksArray.count - 3)
//                lblNumber.font = UIFont(name: "OpenSans-Semibold", size: 30.0)
//
//                booksView.addSubview(bookBtn)
//                booksView.addSubview(lblNumber)
//            }
            
            bookBtn.addTarget(self, action: #selector(addedBookAction(_:)), for: .touchUpInside)
            
            xPos = xPos + width + 7
        }
        
        booksScrollView.contentSize = CGSize(width: xPos, height: 0)
    }
    
    func fillScrollView(type: Int)
    {
        for view in typeScrollView.subviews
        {
            view.removeFromSuperview()
        }
        
        var xPos:Int = 0
        
        var interestsArray:[String] = []
        
        if type == 1
        {
            interestsArray = languagesArray
        }
        else if type == 2
        {
            interestsArray = authorsArray
        }
        else if type == 3
        {
            interestsArray = generesArray
        }
        
        for i in 0..<interestsArray.count
        {
            let title = interestsArray[i]
            
            if !title.isEmpty
            {
                let myString = title as NSString
                let attrs = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 13.0)] as [NSAttributedStringKey : Any]
                let size:CGSize = myString.size(withAttributes: attrs)
                
                let view = UIView()
                view.frame = CGRect(x: xPos, y: 18, width: Int(size.width) + 50, height: 32)
                
                if i == 0
                {
                    view.backgroundColor = UIColor(red: 0, green : 151/255, blue: 232/255, alpha: 1)
                }
                else if i == 1
                {
                    view.backgroundColor = UIColor(red: 242/255, green : 62/255, blue: 58/255, alpha: 1)
                }
                else if i == 2
                {
                    view.backgroundColor = UIColor(red: 105/255, green : 189/255, blue: 85/255, alpha: 1)
                }
                else if i == 3
                {
                    view.backgroundColor = UIColor(red: 0, green : 151/255, blue: 232/255, alpha: 1)
                }
                else if i == 4
                {
                    view.backgroundColor = UIColor(red: 242/255, green : 62/255, blue: 58/255, alpha: 1)
                }
                else if i == 5
                {
                    view.backgroundColor = UIColor(red: 105/255, green : 189/255, blue: 85/255, alpha: 1)
                }
                else if i == 6
                {
                    view.backgroundColor = UIColor(red: 0, green : 151/255, blue: 232/255, alpha: 1)
                }
                else if i == 7
                {
                    view.backgroundColor = UIColor(red: 242/255, green : 62/255, blue: 58/255, alpha: 1)
                }
                else if i == 8
                {
                    view.backgroundColor = UIColor(red: 105/255, green : 189/255, blue: 85/255, alpha: 1)
                }
                else
                {
                    view.backgroundColor = UIColor(red: 0, green : 151/255, blue: 232/255, alpha: 1)
                }
                
                view.layer.cornerRadius = 5
                view.layer.masksToBounds = true
                
                let lblTitle = UILabel()
                lblTitle.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                lblTitle.backgroundColor = UIColor.clear
                lblTitle.text = title
                lblTitle.font = UIFont(name: "Montserrat-Regular", size: 13.0)
                lblTitle.textColor = UIColor.white
                lblTitle.textAlignment = .center
                
                view.addSubview(lblTitle)
                typeScrollView.addSubview(view)
                
                xPos = xPos + Int(view.frame.size.width + 15)
            }
        }
        
        typeScrollView.contentSize = CGSize(width: xPos, height: 0)
    }
    
    @IBAction func editBtnAction(_ button: UIButton)
    {
        let profile1VC = (self.storyboard?.instantiateViewController(withIdentifier: "Profile1ViewController")) as! Profile1ViewController
        fromProfile = true
        self.navigationController?.pushViewController(profile1VC, animated: true )
    }
    
    @IBAction func settingsBtnAction(_ button: UIButton)
    {
        let settingsVC = (self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC")) as! SettingsVC
        self.navigationController?.pushViewController(settingsVC, animated: true )
    }
    
    @IBAction func interestsBtnAction(_ button:UIButton)
    {
        changeButtons()
        var type = 0
        
        if button.tag == 1001
        {
            languageBtn.setImage(UIImage(named: "language_active"), for: .normal)
            type = 1
        }
        else if button.tag == 1002
        {
            authorBtn.setImage(UIImage(named: "author_active"), for: .normal)
            type = 2
        }
        else
        {
            genreBtn.setImage(UIImage(named: "genre_active"), for: .normal)
            type = 3
        }
        
        fillScrollView(type: type)
    }
    
    @IBAction func addedBookAction(_ button: UIButton)
    {
        let bookListVC = (self.storyboard?.instantiateViewController(withIdentifier: "BooksListViewController")) as! BooksListViewController
        bookListVC.fromAuthor = false
        self.navigationController?.pushViewController(bookListVC, animated: true )
    }
    
    @IBAction func addBookAction(_ button: UIButton)
    {
        let addBookVC = (self.storyboard?.instantiateViewController(withIdentifier: "AddUserBookVC")) as! AddUserBookVC
        self.navigationController?.pushViewController(addBookVC, animated: true )
    }
    
    func changeButtons()
    {
        languageBtn.setImage(UIImage(named: "language"), for: .normal)
        authorBtn.setImage(UIImage(named: "author"), for: .normal)
        genreBtn.setImage(UIImage(named: "genre"), for: .normal)
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
        else if button.tag == 1003
        {
            let searchVC = (self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController")) as! SearchViewController
            self.navigationController?.pushViewController(searchVC, animated: false)
        }
        else if button.tag == 1004
        {
            let favouritesVC = (self.storyboard?.instantiateViewController(withIdentifier: "FavouritesVC")) as! FavouritesVC
            self.navigationController?.pushViewController(favouritesVC, animated: false)
        }
    }
}
