//
//  ContactUsVC.swift
//  KRIZMA
//
//  Created by Macbook Pro on 19/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit

class ContactUsVC: UIViewController, UITextFieldDelegate, UITextViewDelegate
{
    @IBOutlet var txtName:UITextField!
    @IBOutlet var txtEmail:UITextField!
    @IBOutlet var txtMessage:UITextView!
    
    @IBOutlet var topConstraints:NSLayoutConstraint!
    
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
    
    @IBAction func backBtnAction(_ button:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        hideKeyboard()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView == txtMessage
        {
            addToolBar()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        hideKeyboard()
    }
    
    @objc func hideKeyboard()
    {
//        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {//delegate
//            self.topConstraints.constant = 0
//            self.view.layoutIfNeeded()
//        }, completion: nil)
//
        txtEmail.resignFirstResponder()
        txtName.resignFirstResponder()
        txtMessage.resignFirstResponder()
    }
    
    func addToolBar()
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 42/255, green: 113/255, blue: 158/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(hideKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        txtMessage.inputAccessoryView = toolBar
    }
}

