//
//  FavouritesVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 18/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD

class FavouritesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    @IBOutlet var authorsTblView:UITableView!
    @IBOutlet var booksTblView:UITableView!
    @IBOutlet var leading:NSLayoutConstraint!
    @IBOutlet var authTblLeading:NSLayoutConstraint!
    @IBOutlet var bookTblLeading:NSLayoutConstraint!
    
    @IBOutlet var lblNoResult:UILabel!
    
    private var dateCellExpanded: Bool = false
    
    override func viewDidLoad()
    {
        if userObj.favAuthorsArray.count == 0
        {
            self.lblNoResult.alpha = 1
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        booksTblView.reloadData()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    @IBAction func categoryBtnAction(_ button: UIButton)
    {
         UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
        
            if button.tag == 1001
            {
                if userObj.favAuthorsArray.count > 0
                {
                    self.lblNoResult.alpha = 1
                }
                else
                {
                    self.lblNoResult.alpha = 0
                }
                
                self.leading.constant = 14
                self.authTblLeading.constant = 14
                self.bookTblLeading.constant = 28
                
                if userObj.favAuthorsArray.count == 0
                {
                    self.lblNoResult.alpha = 1
                }
                else
                {
                    self.lblNoResult.alpha = 0
                }
                self.authorsTblView.alpha = 1
            }
            else if button.tag == 1002
            {
                if userObj.favBooksArray.count > 0
                {
                    self.lblNoResult.alpha = 1
                }
                else
                {
                    self.lblNoResult.alpha = 0
                }
                
                screenSize
                
                self.leading.constant = 98
                self.authTblLeading.constant = -410
                self.bookTblLeading.constant = -389
                
                if userObj.favBooksArray.count == 0
                {
                    self.lblNoResult.alpha = 1
                }
                else
                {
                    self.lblNoResult.alpha = 0
                }
                self.authorsTblView.alpha = 0
            }
            self.view.layoutIfNeeded()
            
        }, completion: nil)
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
        else if button.tag == 1005
        {
            let profileVC = (self.storyboard?.instantiateViewController(withIdentifier: "MenuProfileVC")) as! MenuProfileVC
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.tag == 1001
        {
            return userObj.favAuthorsArray.count
        }
        else
        {
            return userObj.favBooksArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView.tag == 1001
        {
            let authorObj:UserObject = userObj.favAuthorsArray.object(at: indexPath.row) as! UserObject
            
            if authorObj.expandFlag
            {
                return 316
            }
        }
        return 112
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 1001
        {
            let cell:UserCell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            
            cell.subView.layer.cornerRadius = 10
            cell.subView.layer.masksToBounds = true
            
            cell.subView2.layer.cornerRadius = 10
            cell.subView2.layer.masksToBounds = true
            
            cell.imgView.layer.cornerRadius = 10
            cell.imgView.layer.masksToBounds = true
            
            let authorObj:UserObject = userObj.favAuthorsArray.object(at: indexPath.row) as! UserObject
            
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
            
            if authorObj.expandFlag
            {
                cell.btnExpand.setImage(#imageLiteral(resourceName: "minus"), for: .normal)
            }
            else
            {
                cell.btnExpand.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
            }
            
            cell.favBtn.addTarget(self, action: #selector(favAuthorBtnAction(_:)), for: .touchUpInside)
            cell.favBtn.tag = indexPath.row + 1000
            
            cell.btnExpand.addTarget(self, action: #selector(expandBtnAction(_:)), for: .touchUpInside)
            cell.btnExpand.tag = indexPath.row + 2000
            
            return cell
        }
        else
        {
            let cell:BookCell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
            
            if userObj.favBooksArray.count > 0
            {
                let bookObj:BookObject = userObj.favBooksArray.object(at: indexPath.row) as! BookObject
                
                cell.subView.layer.cornerRadius = 10
                cell.subView.layer.masksToBounds = true
                
                cell.subView2.layer.cornerRadius = 10
                cell.subView2.layer.masksToBounds = true
                
                cell.imgView.layer.cornerRadius = 10
                cell.imgView.layer.masksToBounds = true
                
                cell.lblName.text = bookObj.bookName as String
                cell.lblLanguage.text = bookObj.language as String
                cell.lblAuthor.text = bookObj.author as String
                
                cell.favBtn.addTarget(self, action: #selector(favBookBtnAction(_:)), for: .touchUpInside)
                cell.favBtn.tag = indexPath.row + 1000
                
                if bookObj.photo != nil
                {
                    cell.imgView.image = bookObj.photo
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 1001
        {
            let authorsProfileVC = (self.storyboard?.instantiateViewController(withIdentifier: "AuthorsProfileVC")) as! AuthorsProfileVC
            let authorObj:UserObject = userObj.favAuthorsArray.object(at: indexPath.row) as! UserObject
            authorsProfileVC.authorObj = authorObj
            self.navigationController?.pushViewController(authorsProfileVC, animated: true )
        }
    }
    
    @IBAction func expandBtnAction(_ button: UIButton)
    {
        let authorObj:UserObject = userObj.favAuthorsArray.object(at:  button.tag - 2000) as! UserObject
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
        
//        authorsTblView.reloadData()
        
        authorsTblView.beginUpdates()
        authorsTblView.endUpdates()
    }
    
    func changeExpandFlag(authorID: Int)
    {
        for i in 0..<authorsArray.count
        {
            let authorObj:UserObject = authorsArray.object(at:  i) as! UserObject
            
            if authorObj.userID != authorID
            {
                authorObj.expandFlag = false
            }
        }
    }
    
    @IBAction func favAuthorBtnAction(_ button: UIButton)
    {
        let alert = UIAlertController(title: "" , message: "Are you sure you want to remove this author from favourites?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "YES", style: .default)
        { (action:UIAlertAction) in
            
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            self.removeFavAuhtor(index: button.tag - 1000, favFlag: 0)
        }
        
        let no = UIAlertAction(title: "NO", style: .cancel)
        { (action:UIAlertAction) in
            
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func favBookBtnAction(_ button: UIButton)
    {
        let alert = UIAlertController(title: "" , message: "Are you sure you want to remove this book from favourites?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "YES", style: .default)
        { (action:UIAlertAction) in
            
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            self.removeFavBook(index: button.tag - 1000, favFlag: 0)
        }
        
        let no = UIAlertAction(title: "NO", style: .cancel)
        { (action:UIAlertAction) in
            
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    func removeFavAuhtor(index: Int, favFlag:Int)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/removeFavouriteUser")!)
            request.httpMethod = "POST"
            
            let authorObj:UserObject = userObj.favAuthorsArray.object(at:  index) as! UserObject
            
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
                        
                        userObj.favAuthorsArray.remove(authorObj)
                        
                        for i in 0..<authorsArray.count
                        {
                            let author:UserObject = authorsArray.object(at:  i) as! UserObject
                            
                            if author.userID == authorObj.userID
                            {
                                author.favFlag = 0
                            }
                        }
                        
                        self.authorsTblView.reloadData()
                        
                        if userObj.favAuthorsArray.count == 0
                        {
                            self.lblNoResult.alpha = 1
                        }
                        
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
    
    func removeFavBook(index: Int, favFlag:Int)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/removeFavouriteBook")!)
            request.httpMethod = "POST"
            
            let bookObj:BookObject = userObj.favBooksArray.object(at:  index) as! BookObject
            
            let postParameters = String(format:"u_id=%i&b_id=%i", userObj.userID, bookObj.bookID)
            
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
                        
                        userObj.favBooksArray.remove(bookObj)
                        
                        for i in 0..<authorsArray.count
                        {
                            let author:UserObject = authorsArray.object(at:  i) as! UserObject
                            
                            if author.userID == bookObj.authorID
                            {
                                for i in 0..<author.addedBooksArray.count
                                {
                                    let book:BookObject = author.addedBooksArray.object(at:  i) as! BookObject
                                    
                                    if book.bookID == bookObj.bookID
                                    {
                                        book.favFlag = 0
                                    }
                                }
                            }
                        }
                        
                        self.booksTblView.reloadData()
                        
                        if userObj.favAuthorsArray.count == 0
                        {
                            self.lblNoResult.alpha = 1
                        }
                        
                        alert.message = "Book has been removed from your favourites."
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
