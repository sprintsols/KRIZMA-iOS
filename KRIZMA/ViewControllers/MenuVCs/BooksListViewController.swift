//
//  BooksListViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 08/08/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MBProgressHUD

class BooksListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate
{
    @IBOutlet var tblView:UITableView!
    @IBOutlet var addBookView:UIView!
    
    @IBOutlet var addBtn:UIButton!
    @IBOutlet var lblNoRecord:UILabel!
    
    var fromAuthor = false
    var authorObj:UserObject!
    
    
    
    override func viewDidLoad()
    {
//        let lpgr = UILongPressGestureRecognizer(target: self, action: Selector(("handleLongPress:")))
        if !fromAuthor
        {
            let lpgr:UILongPressGestureRecognizer! = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPres))
            lpgr.minimumPressDuration = 0.5
            lpgr.delaysTouchesBegan = true
            lpgr.delegate = self
            self.tblView.addGestureRecognizer(lpgr)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if fromAuthor
        {
            addBtn.alpha = 0
            if authorObj.addedBooksArray.count == 0
            {
                lblNoRecord.alpha = 1
            }
        }
        else
        {
            if userObj.addedBooksArray.count == 0
            {
                addBookView.alpha = 1
            }
        }
        
        tblView.reloadData()
    }
    
    @IBAction func backBtnAction(_ button: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBookAction(_ button: UIButton)
    {
        let addBookVC = (self.storyboard?.instantiateViewController(withIdentifier: "AddUserBookVC")) as! AddUserBookVC
        self.navigationController?.pushViewController(addBookVC, animated: true )
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if fromAuthor
        {
            return authorObj.addedBooksArray.count
        }
        else
        {
            return userObj.addedBooksArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:BookCell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        
        var bookObj:BookObject = BookObject()
        
        if fromAuthor
        {
            bookObj = authorObj.addedBooksArray.object(at: indexPath.row) as! BookObject
        }
        else
        {
            bookObj = userObj.addedBooksArray.object(at: indexPath.row) as! BookObject
        }
        
        if bookObj.favFlag == 1
        {
            cell.favBtn.setImage(UIImage(named: "fav_star_active"), for: .normal)
        }
        else
        {
            cell.favBtn.setImage(UIImage(named: "fav_star_inactive"), for: .normal)
        }
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if !fromAuthor
        {
            let addBookVC = (self.storyboard?.instantiateViewController(withIdentifier: "AddUserBookVC")) as! AddUserBookVC
            addBookVC.bookObj = userObj.addedBooksArray.object(at: indexPath.row) as? BookObject
            self.navigationController?.pushViewController(addBookVC, animated: true )
        }
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
//    {
//        if !fromAuthor
//        {
//            return true
//        }
//        else
//        {
//            return false
//        }
//    }
//
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
//    {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
//    {
//        let Delete = UITableViewRowAction(style: .normal, title: "") { action, index in
//            
//            let alert = UIAlertController(title: "Would you like to delete this book?", message: "", preferredStyle: .actionSheet)
//            
//            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ (UIAlertAction)in
//                DispatchQueue.main.async {
//                    MBProgressHUD.showAdded(to: self.view, animated: true)
//                }
//                self.removeBook(index: indexPath.row)
//            }))
//            
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
//            
//            self.present(alert, animated: true, completion: {
//                print("completion block")
//                
//            })
//        }
//        Delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete_icon")!)
//        
//        return [Delete]
//    }
    
    @objc func handleLongPres(gesture : UILongPressGestureRecognizer!)
    {
        let point = gesture.location(in: self.tblView)
        let indexPath = self.tblView.indexPathForRow(at: point)
        
        if let index = indexPath {
            
            let alert = UIAlertController(title: "Would you like to delete this book?", message: "", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{ (UIAlertAction)in
                DispatchQueue.main.async {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                self.removeBook(index: index.row)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func favBookBtnAction(_ button: UIButton)
    {
        var bookObj:BookObject!
        
        if fromAuthor
        {
            bookObj = authorObj.addedBooksArray.object(at: button.tag - 1000) as? BookObject
        }
        else
        {
            bookObj = userObj.addedBooksArray.object(at: button.tag - 1000) as? BookObject
        }
        
        if bookObj.favFlag == 1
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
        else
        {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            addFavBook(index: button.tag - 1000)
        }
    }
    
    func removeBook(index: Int)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/removeBook")!)
            request.httpMethod = "POST"
            
            let bookObj:BookObject = userObj.addedBooksArray.object(at:  index) as! BookObject
            
            let postParameters = String(format:"b_id=%i", bookObj.bookID)
            
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

                
                if jsonResult != nil
                {
                    DispatchQueue.main.async {
                        
                        userObj.addedBooksArray.remove(bookObj)
                        self.tblView.reloadData()
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
    
    func addFavBook(index: Int)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/addFavouriteBook")!)
            request.httpMethod = "POST"
            
            var bookObj:BookObject!
            
            if fromAuthor
            {
                bookObj = authorObj.addedBooksArray.object(at: index) as? BookObject
            }
            else
            {
                bookObj = userObj.addedBooksArray.object(at: index) as? BookObject
            }
            
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
                        
                        bookObj.favFlag = 1
                        userObj.favBooksArray.add(bookObj)
                        
                        self.tblView.reloadData()
                        
                        alert.message = "Book has been added in your favourites."
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
            
            var bookObj:BookObject!
            
            if fromAuthor
            {
                bookObj = authorObj.addedBooksArray.object(at: index) as? BookObject
            }
            else
            {
                bookObj = userObj.addedBooksArray.object(at: index) as? BookObject
            }
            
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
                        bookObj.favFlag = 0
                        
                        self.tblView.reloadData()
                        
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


