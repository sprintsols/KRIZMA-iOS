//
//  UserObject.swift
//  KRIZMA
//
//  Created by Macbook Pro on 23/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit

class UserObject: NSObject
{
    var userID:Int = 0
    var code:Int = 0
    var favFlag:Int = 0
    var codeTime:Int = 0
    var expandFlag = false
    var userName:NSString = ""
    var userMName:NSString = ""
    var userLName:NSString = ""
    var userPassword:NSString = ""
    var distStr:NSString = ""
    var userEmail:NSString = ""
    var photoURL:NSString = ""
    var userStatus:NSString = ""
    var gender:NSString = ""
    var age:NSString = ""
    var locIndicator:NSString = ""
    var area:NSString = ""
    var city:NSString = ""
    var country:NSString = ""
    var descp:NSString = ""
    var languages:NSString = ""
    var generes:NSString = ""
    var authors:NSString = ""
    var bookType:NSString = ""
    var favBooksName:NSString = ""
    var favAuthorsName:NSString = ""
    var photo:UIImage!
    var addedBooksArray = NSMutableArray()
    var favAuthorsArray = NSMutableArray()
    var favBooksArray = NSMutableArray()
}
