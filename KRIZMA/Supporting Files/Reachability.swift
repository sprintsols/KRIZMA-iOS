//
//  Reachability.swift
//  FashionConnect
//
//  Created by Schnell on 22/11/2017.
//  Copyright © 2017 Sprint Solutions. All rights reserved.
//

import Foundation
public class Reachability {
    
    class func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: "https://www.google.com")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        var response: URLResponse?
        do {
            var data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as NSData?
        }
        catch {
            
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}
