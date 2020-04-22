//
//  SettingsVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 17/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import MessageUI

class SettingsVC: UIViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet var notifSwitch:UISwitch!
    
    override func viewDidLoad()
    {
        let notifFlag = userDefaults.integer(forKey: "notifFlag")
        
        if notifFlag == 0
        {
            notifSwitch.setOn(true, animated: false)
        }
        else
        {
            notifSwitch.setOn(false, animated: false)
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
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchBtnAction(_ notifSwitch:UISwitch)
    {
        if notifSwitch.isOn
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.configureUserNotifications()
            userDefaults.set(0, forKey: "notifFlag")
        }
        else
        {
            userDefaults.set(1, forKey: "notifFlag")
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    @IBAction func aboutBtnAction(_ button:UIButton)
    {
        let aboutVC = (self.storyboard?.instantiateViewController(withIdentifier: "AboutViewController")) as! AboutViewController
        self.navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    @IBAction func helpCenterBtnAction(_ button:UIButton)
    {
        let contactUsVC = (self.storyboard?.instantiateViewController(withIdentifier: "ContactUsVC")) as! ContactUsVC
        self.navigationController?.pushViewController(contactUsVC, animated: true)
    }
    
    @IBAction func logoutBtnAction(_ button:UIButton)
    {
        let alert = UIAlertController(title: nil , message: "Are you sure to logout?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "YES", style: .default)
        { (action:UIAlertAction) in
            
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
            photo = nil
            photoFlag = false
            userObj = UserObject()
            authorsArray = NSMutableArray()
            notificationsArray = NSMutableArray()
            userDefaults.set(0, forKey: "userID")
            
            let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            registerUserClientService.logout { (response, error) in
                if(error == nil && response!.status == "success") {
                    print("Logout success")
                } else {
                    print("Logout failed with response : %@", response!.response)
                }
            }
            
            
            let loginVC = (self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")) as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        
        let no = UIAlertAction(title: "NO", style: .cancel)
        { (action:UIAlertAction) in
            
        }
        
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func inviteBtnAction(_ button:UIButton)
    {
        let url:URL = URL(string: "itms-apps://itunes.apple.com/us/developer/Zain%20Ali/id1024978")!
        
        let activityViewController = UIActivityViewController(activityItems: ["KRIZMA App", url], applicationActivities: nil)

        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func privacyBtnAction(_ button:UIButton)
    {
        let privacyVC = (self.storyboard?.instantiateViewController(withIdentifier: "PrivacyViewController")) as! PrivacyViewController
        self.navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func feedbackBtnAction(_ button:UIButton)
    {
        let mailComposeViewController = configuredMailComposeViewController()
        
        if MFMailComposeViewController.canSendMail()
        {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else
        {
            showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["zain@sprintsols.com"])
        mailComposerVC.setSubject("KRIZMA App - Feedback")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert()
    {
        let sendMailErrorAlert = UIAlertView(title: "", message: "Your device could not send email. Please check email configuration in device settings and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result.rawValue
        {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResult.saved.rawValue:
           print("Mail saved")
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
        case MFMailComposeResult.failed.rawValue:
            print("Mail Failed")
        default:
            break
        }
    }
    
    @IBAction func rateBtnAction(_ button:UIButton)
    {
        if let url = URL(string: "itms-apps://itunes.apple.com/us/developer/Zain%20Ali/id1024978") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            }
            else
            {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
