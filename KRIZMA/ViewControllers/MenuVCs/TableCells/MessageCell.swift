//
//  MessageCell.swift
//  KRIZMA
//
//  Created by Macbook Pro on 18/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell
{
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDescp : UILabel!
    @IBOutlet var lblTime : UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        selectionStyle = .none
    }
}
