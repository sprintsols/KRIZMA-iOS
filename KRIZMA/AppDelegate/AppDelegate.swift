//
//  AppDelegate.swift
//  KRIZMA
//
//  Created by Macbook Pro on 10/07/2018.
//  Copyright © 2018 Macbook Pro. All rights reserved.
//

import UIKit
import GoogleSignIn
import UserNotifications
import Applozic
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{
    var window: UIWindow?
    var navigationController: UINavigationController?
    
    static let instance: NSCache<AnyObject, AnyObject> = NSCache()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let notifFlag = userDefaults.integer(forKey: "notifFlag")
        
        if notifFlag == 0
        {
            self.configureUserNotifications()
        }
        
        application.applicationIconBadgeNumber = 0
        
        //Tiwilio
        //SK76193f7b0b72ae24cbf0960d187b6e48
        //fizbomdxtGYsQXv1A1Tkl33nNwRix9EG
        
        // Override point for customization after application launch.
        let alApplocalNotificationHnadler : ALAppLocalNotifications =  ALAppLocalNotifications.appLocalNotificationHandler();
        alApplocalNotificationHnadler.dataConnectionNotificationHandler();
        
        if (launchOptions != nil) {
            
            let dictionary = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
            
            if (dictionary != nil) {
                print("launched from push notification")
                let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
                
                let appState: NSNumber = NSNumber(value: 0)
                let applozicProcessed = alPushNotificationService.processPushNotification(launchOptions,updateUI:appState)
                if (applozicProcessed) {
                    return true;
                }
            }
        }
        
        //Sendbird API
//        SBDMain.initWithApplicationId("3A3B8102-4247-44D0-B475-A6DCAF1658CE")
        
        GIDSignIn.sharedInstance().clientID = "958967229294-lj8vhnmtfmbneijevqi22d2hgd32kmvc.apps.googleusercontent.com"
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        navigationController = UINavigationController()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.navigationController?.isNavigationBarHidden = true
        
        let userID = userDefaults.integer(forKey: "userID")
        
//        if false
        if userID > 0
        {
            let homeVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            homeVC.userLoginFlag = false
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        else
        {
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
        
        self.window!.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if socialMediaInd == 2
        {
            if LinkedinSwiftHelper.shouldHandle(url) {
                return LinkedinSwiftHelper.application(app, open: url, sourceApplication: nil, annotation: nil)
            }
        }
        else if socialMediaInd == 3
        {
            return GIDSignIn.sharedInstance().handle(url as URL?,
                                              sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                              annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
    
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        let notificationName = Notification.Name("APP_ENTER_IN_BACKGROUND")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
        ALPushNotificationService.applicationEntersForeground()
        
        let notificationName = Notification.Name("APP_ENTER_IN_FOREGROUND")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        application.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {

        ALDBHandler.sharedInstance().saveContext()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        print(deviceTokenString)
        
        registerDeviceToken(deviceToken: deviceTokenString)
        
        if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString){
            
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                print (response)
            })
        }
        
        let pushKitVOIP = PKPushRegistry(queue: DispatchQueue.main)
        pushKitVOIP.desiredPushTypes = Set<PKPushType>([PKPushType.voIP])
        pushKitVOIP.delegate = self
    }
    
    private func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
        alPushNotificationService.notificationArrived(to: application, with: userInfo)
        completionHandler(.newData)
//        let applozicProcessed = alPushNotificationService.processPushNotification(userInfo, updateUI: application.applicationState == UIApplicationState.active) as Bool
//
//        //IF not a appplozic notification, process it
//
//        if (applozicProcessed) {
//            //Note: notification for app
//        }
    }
    
    func configureUserNotifications()
    {        
        // iOS 10 support
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                else{
                    //Do stuff if unsuccessful...
                }
            })
        }  // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }  // iOS 7 support
        else {
            UIApplication.shared.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
    }
    
    func registerDeviceToken(deviceToken: String)
    {
        if Reachability.isConnectedToNetwork()
        {
            var request = URLRequest(url: URL(string: webURL + "/getToken")!)
            request.httpMethod = "POST"
            
            let postParameters = String(format:"token=%@&type=i" ,deviceToken)
            
            request.httpBody = postParameters.data(using: .utf8)
//            print(postParameters)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                
                let jsonResult = convertToDictionary(text: responseString!)
                print(jsonResult)
                
                if jsonResult != nil
                {
                    let loginCode:String = jsonResult!["code"] as! String
                    
                    if loginCode == "101"
                    {
                        print("Token registered...")
                    }
                }
                else
                {
    
                }
            }
            task.resume()
        }
    }
    
    //curl -v -d '{"aps":{"alert":"hello"}}' --http2 --cert Certificates_voip.pem:sprint https://api.development.push.apple.com/3/device/1b28090ece30de44af9b31094ab07fb908a295b22a69787d34b28417f38c270c
}

extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        NSLog("PUSHKIT : VOIP_TOKEN_DATA : %@",credentials.token.description)
        
        let hexToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        NSLog("PUSHKIT : VOIP_TOKEN : %@",hexToken)
        
        if let apnToken = ALUserDefaultsHandler.getApnDeviceToken(), apnToken == hexToken {
            return
        }
        NSLog("PUSHKIT : VOIP_TOKEN_UPDATE_CALL")
        
        let registerUserClientService = ALRegisterUserClientService()
        registerUserClientService.updateApnDeviceToken(withCompletion: hexToken, withCompletion: {
            response, error in
            if error != nil {
                NSLog("PUSHKIT : VOIP TOKEN : REGISTRATION ERROR :: %@", error.debugDescription)
                return
            }
            
            NSLog("PUSHKIT : VOIP_TOKEN_UPDATE : %@", response?.description ?? "")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        NSLog("PUSHKIT : INVALID_PUSHKIT_TOKEN")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        NSLog("PUSHKIT : INCOMING VOIP NOTIFICATION : %@",payload.dictionaryPayload.description)
        
        let application = UIApplication.shared
        let pushNotificationService = ALPushNotificationService()
        pushNotificationService.notificationArrived(to: application, with: payload.dictionaryPayload)
        
        let payloadDict = payload.dictionaryPayload["aps"] as? [String: Any]
        let notifAlert = payloadDict?["alert"]
        let notifSound = payloadDict?["sound"]
        
        guard let alert = notifAlert as? String  else { return }
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            let messageContent = alert.components(separatedBy: ":")
            
            content.title = messageContent.count > 0 ? messageContent[0]: alert
            if notifSound != nil {
                content.sound = UNNotificationSound.default()
            }
            
            content.body = messageContent.count > 1 ? messageContent[1]: alert
            content.userInfo = payload.dictionaryPayload
            center.delegate = self
            let request = UNNotificationRequest(identifier: "VOIP_APNS", content: content, trigger: nil)
            center.add(request, withCompletionHandler: {
                error in
                if error == nil {
                    NSLog("PUSHKIT : Add NotificationRequest Succeeded!")
                }
            })
        } else {
            let localNotification = UILocalNotification()
            localNotification.alertBody = alert
            if notifSound != nil {
                localNotification.soundName = UILocalNotificationDefaultSoundName
            }
            
            localNotification.userInfo = payload.dictionaryPayload
            application.presentLocalNotificationNow(localNotification)
        }
    }
}

