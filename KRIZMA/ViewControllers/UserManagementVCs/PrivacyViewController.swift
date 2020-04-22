//
//  PrivacyViewController.swift
//  KRIZMA
//
//  Created by Sprint on 04/03/2019.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController
{
    @IBOutlet var webView:UIWebView!
    
    override func viewDidLoad()
    {
        if let pdf = Bundle.main.url(forResource: "privacy_policy", withExtension: "pdf", subdirectory: nil, localization: nil)
        {
            let req = NSURLRequest(url: pdf)
            webView.loadRequest(req as URLRequest)
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
}

