//
//  User.swift
//  KRIZMA
//
//  Created by Macbook Pro on 15/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell
{
    @IBOutlet var subView : UIView!
    @IBOutlet var subView2 : UIView!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblAge : UILabel!
    @IBOutlet var lblDistance : UILabel!
    @IBOutlet var lblGender : UILabel!
    @IBOutlet var lblAddress : UILabel!
    @IBOutlet var lblLanguages : UILabel!
    @IBOutlet var lblGeneres : UILabel!
    @IBOutlet var lblFavAuthors : UILabel!
    @IBOutlet var lblFavBooks : UILabel!
    
    @IBOutlet var favBtn:UIButton!
    @IBOutlet var btnSeeMore:UIButton!
    @IBOutlet var btnExpand:UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        selectionStyle = .none
    }
}
