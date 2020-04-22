//
//  AboutViewController.swift
//  KRIZMA
//
//  Created by Macbook Pro on 19/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

//
//  AboutViewController.swift
//  FashionConnect
//
//  Created by Schnell on 06/11/2017.
//  Copyright © 2017 Sprint Solutions. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController
{
    @IBOutlet var bundleVersion: UILabel!
    @IBOutlet var lblCopyrights: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let version = "Version \(applicationVersion())"
        bundleVersion.text = version
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let dateStr = formatter.string(from: Date())
        lblCopyrights.text = String(format: "©%@ KRIZMA",dateStr)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        return .lightContent
    }
    
    func applicationVersion()-> String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func webBtnAction(_ sender: UIButton)
    {
        UIApplication.shared.openURL(URL(string: "http://www.sprintsols.com")!)
    }
}


