//
//  MessagesVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 17/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit

class MessagesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    @IBOutlet var txtSearch:UITextField!
    @IBOutlet var tblView:UITableView!
    
    override func viewDidLoad()
    {
        
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
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1001
        {
            let notifVC = (self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC")) as! NotificationsVC
            self.navigationController?.pushViewController(notifVC, animated: false)
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
        else if button.tag == 1005
        {
            let profileVC = (self.storyboard?.instantiateViewController(withIdentifier: "MenuProfileVC")) as! MenuProfileVC
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:MessageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let deleteBtn = UITableViewRowAction(style: .destructive, title: "") { (action, indexPath) in
            // delete item at indexPath
        }
        
        deleteBtn.backgroundColor = UIColor(patternImage: UIImage(named: "delete")!)
        
        return [deleteBtn]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        txtSearch.resignFirstResponder()
    }
}

