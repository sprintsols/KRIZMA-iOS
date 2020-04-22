//
//  NotificationsVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 19/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var txtSearch:UITextField!
    @IBOutlet var tblView:UITableView!
    @IBOutlet var lblNoRecord:UILabel!
    
    override func viewDidLoad()
    {
        if notificationsArray.count == 0
        {
            lblNoRecord.alpha = 1
        }
        else
        {
            lblNoRecord.alpha = 0
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
    
    @IBAction func menuBtnAction(_ button: UIButton)
    {
        if button.tag == 1002
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
        else if button.tag == 1005
        {
            let profileVC = (self.storyboard?.instantiateViewController(withIdentifier: "MenuProfileVC")) as! MenuProfileVC
            self.navigationController?.pushViewController(profileVC, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notificationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:MessageCell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        
        let notifObj:NotificationObject = notificationsArray.object(at: indexPath.row) as! NotificationObject
        
        cell.lblDescp.text = String(format: "%@", notifObj.message)
        cell.lblTime.text = String(format: "%@", notifObj.timeStr)
        
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


