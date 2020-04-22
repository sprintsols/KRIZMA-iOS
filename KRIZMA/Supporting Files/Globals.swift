//
//  Globals.swift
//  KRIZMA
//
//  Created by Macbook Pro on 22/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit

//var webURL = "http://krizma.me/dev"
var webURL = "http://krizma.me/admin"

let screenSize = UIScreen.main.bounds.size

var userObj:UserObject = UserObject()
var userDefaults = UserDefaults()

var clientID = "78vp9x78j1mgjo"
var clientSecret = "NjGDn03RL8SjQ8Fc"

var socialMediaInd = 0

var ChatAPIKey = "60c67c15742bd51763afddde168ee09f"

var authorsArray = NSMutableArray()
var notificationsArray = NSMutableArray()

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func convertImageToBase64(image:UIImage) -> String
{
    let imageData = UIImageJPEGRepresentation(image, 0.3)!
    let base64String = imageData.base64EncodedString(options: [])
    return base64String
}

func isValidEmail(emailStr:String) -> Bool
{
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let email = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return email.evaluate(with: emailStr)
}

func getElapsedInterval(fromDate: Date) -> String
{
    let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: fromDate)

    if let day = interval.day, day > 0 {
        return day == 1 ? "\(day)" + " " + "day ago" :
            "\(day)" + " " + "days ago"
    } else if let hour = interval.hour, hour > 0 {
        return hour == 1 ? "\(hour)" + " " + "hour ago" :
            "\(hour)" + " " + "hours ago"
    } else if let minute = interval.minute, minute > 0 {
        return minute == 1 ? "\(minute)" + " " + "minute ago" :
            "\(minute)" + " " + "minutes ago"
    } else if let second = interval.second, second > 0 {
        return second == 1 ? "\(second)" + " " + "second ago" :
            "\(second)" + " " + "seconds ago"
    } else {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from:fromDate)
    }
}

func populateGeneres() -> [String]
{
    let genresList = [
        "Science",
        "fiction",
        "Satire",
        "Drama",
        "Action and Adventure",
        "Romance",
        "Mystery",
        "Horror",
        "Self help",
        "Health",
        "Guide",
        "Travel",
        "Children's",
        "Religion, Spirituality & New Age",
        "Science",
        "History",
        "Math",
        "Anthology",
        "Poetry",
        "Encyclopedias",
        "Dictionaries",
        "Comics",
        "Comedy",
        "Art",
        "Cookbooks",
        "Diaries",
        "Journals",
        "Prayer books",
        "Series",
        "Trilogy",
        "Biographies",
        "Autobiographies",
        "Fantasy"]
    
    return genresList
}

func populateLanguages() -> [String]
{
    let genresList = [
        "Akan",
        "Amharic",
        "Arabic",
        "Assamese",
        "Awadhi",
        "Azerbaijani",
        "Balochi",
        "Belarusian",
        "Bengali",
        "Bhojpuri",
        "Burmese",
        "Cebuano",
        "Chewa",
        "Chhattisgarhi",
        "Chittagonian",
        "Czech",
        "Danish",
        "Deccan",
        "Dhundhari",
        "Dutch",
        "Eastern Min",
        "English",
        "French",
        "Fula",
        "Gan Chinese",
        "German",
        "Greek",
        "Gujarati",
        "Haitian Creole",
        "Hakka",
        "Haryanvi",
        "Hausa",
        "Hiligaynon/Ilonggo",
        "Hindi",
        "Hmong",
        "Hungarian",
        "Igbo",
        "Ilocano",
        "Italian",
        "Japanese",
        "Javanese",
        "Jin",
        "Kannada",
        "Kazakh",
        "Khmer",
        "Kinyarwanda",
        "Kirundi",
        "Konkani",
        "Korean",
        "Kurdish",
        "Madurese",
        "Magahi",
        "Maithili",
        "Malagasy",
        "Malay ",
        "Malayalam",
        "Mandarin",
        "Marathi",
        "Marwari",
        "Mossi",
        "Nepali",
        "Northern Min",
        "Norwegian",
        "Odia",
        "Oromo",
        "Pashto",
        "Persian",
        "Polish",
        "Portuguese",
        "Punjabi",
        "Quechua",
        "Romanian",
        "Russian",
        "Saraiki",
        "Serbo-Croatian",
        "Shona",
        "Sindhi",
        "Sinhalese",
        "Somali",
        "Southern Min",
        "Spanish",
        "Sundanese",
        "Swedish",
        "Sylheti",
        "Tagalog",
        "Tamil",
        "Telugu",
        "Thai",
        "Turkish",
        "Turkmen",
        "Ukrainian",
        "Urdu",
        "Uyghur",
        "Uzbek",
        "Vietnamese",
        "Wu/Shanghainese",
        "Xhosa",
        "Xiang/Hunanese",
        "Yoruba",
        "Yue",
        "Zhuang",
        "Zulu"]
    
    return genresList
}
