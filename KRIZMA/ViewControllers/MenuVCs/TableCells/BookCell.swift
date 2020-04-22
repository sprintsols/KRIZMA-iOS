//
//  BookCell.swift
//  KRIZMA
//
//  Created by Macbook Pro on 08/08/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import Foundation
import UIKit

class BookCell: UITableViewCell
{
    @IBOutlet var subView : UIView!
    @IBOutlet var subView2 : UIView!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblLanguage : UILabel!
    @IBOutlet var lblAuthor : UILabel!
    @IBOutlet var favBtn : UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        selectionStyle = .none
    }
}
