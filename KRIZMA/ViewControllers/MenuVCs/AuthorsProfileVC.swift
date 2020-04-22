//
//  AuthorsProfileVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 19/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class AuthorsProfileVC: UIViewController
{
    @IBOutlet var imgView:UIImageView!
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblAge:UILabel!
    @IBOutlet var lblGender:UILabel!
    @IBOutlet var lblCountry:UILabel!
    @IBOutlet var lblNoBooks:UILabel!
    
    @IBOutlet var typeScrollView:UIScrollView!
    @IBOutlet var languageBtn:UIButton!
    @IBOutlet var authorBtn:UIButton!
    @IBOutlet var genreBtn:UIButton!
    
    @IBOutlet var booksView:UIView!
    @IBOutlet var booksScrollView:UIScrollView!
    
    var languagesArray:[String] = []
    var generesArray:[String] = []
    var authorsArray:[String] = []
    
    var authorObj:UserObject!
    
    override func viewDidLoad()
    {
        imgView.layer.cornerRadius = 43
        imgView.layer.masksToBounds = true
        
        if authorObj.photo != nil
        {
            imgView.image = authorObj.photo
            photo = authorObj.photo
        }
        else
        {
            if authorObj.photoURL.length > 0
            {
                Alamofire.request(authorObj.photoURL as String).responseImage { response in
                    
                    if let image = response.result.value {
                        DispatchQueue.main.async() {
                            self.authorObj.photo = image
                            self.imgView.image = self.authorObj.photo
                            photo = self.authorObj.photo
                        }
                    }
                }
            }
        }
        
        lblName.text = String(format: "%@%@%@", authorObj.userName, authorObj.userMName.length > 0 ? String(format: " %@", authorObj.userMName) : "", authorObj.userLName.length > 0 ? String(format: " %@", authorObj.userLName) : "")
        lblAge.text =  String(format: "DOB: %@",authorObj.age)
        lblGender.text = authorObj.gender as String
        lblCountry.text = authorObj.country as String
        
        if authorObj.addedBooksArray.count > 0
        {
            lblNoBooks.alpha = 0
        }
        
        fillArrays()
        fillScrollView(type:3)
        fillBooksView()
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
    
    @IBAction func addedBookAction(_ button: UIButton)
    {
        let bookListVC = (self.storyboard?.instantiateViewController(withIdentifier: "BooksListViewController")) as! BooksListViewController
        bookListVC.fromAuthor = true
        bookListVC.authorObj = authorObj
        self.navigationController?.pushViewController(bookListVC, animated: true )
    }
    
    func fillArrays()
    {
        languagesArray = authorObj.languages.components(separatedBy: ",")
        generesArray = authorObj.generes.components(separatedBy: ",")
        authorsArray = authorObj.authors.components(separatedBy: ",")
    }
    
    func fillBooksView()
    {
        for view in booksScrollView.subviews
        {
            view.removeFromSuperview()
        }
        
        var xPos:Int = 0
        
        for i in 0..<authorObj.addedBooksArray.count
        {
            let bookObj:BookObject = authorObj.addedBooksArray.object(at: i) as! BookObject
            
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
    
    @IBAction func backBtnAction(_ button: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
    
    func changeButtons()
    {
        languageBtn.setImage(UIImage(named: "language"), for: .normal)
        authorBtn.setImage(UIImage(named: "author"), for: .normal)
        genreBtn.setImage(UIImage(named: "genre"), for: .normal)
    }
    
    @IBAction func messageBtnAction(sender: UIButton)
    {
        let chatManager = ALChatManager(applicationKey: ChatAPIKey as NSString)
        chatManager.launchChatForUser(String(format: "%i", authorObj.userID), fromViewController: self)
    }
}

