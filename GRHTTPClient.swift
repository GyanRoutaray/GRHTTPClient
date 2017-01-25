//
//  GRHTTPClient.swift
//  JustStuck
//
//  Created by Gyan Routray on 23/01/17.
//  Copyright © 2017 Headerlabs. All rights reserved.
//

import Foundation

let kBaseAddress = "http://gyanaranjan.com"

func get(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: NSMutableDictionary, _ statusCode: Int) -> ()) {
    dataTask(request: request, method: "GET", completion: completion)
}
func post(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: NSMutableDictionary, _ statusCode: Int) -> ()) {
    dataTask(request: request, method: "POST", completion: completion)
}
func put(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: NSMutableDictionary, _ statusCode: Int) -> ()) {
    dataTask(request: request, method: "PUT", completion: completion)
}
func patch(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: NSMutableDictionary, _ statusCode: Int) -> ()) {
    dataTask(request: request, method: "PATCH", completion: completion)
}
func delete(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: NSMutableDictionary, _ statusCode: Int) -> ()) {
    dataTask(request: request, method: "DELETE", completion: completion)
}


private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: NSMutableDictionary, _ statusCode: Int) -> ()) {
    request.httpMethod = method
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let task =  session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
    if error != nil{
        print("error==== \(error?.localizedDescription)")
        let dict: [String: Any] = ["error": error?.localizedDescription ?? "Something went wrong. Please try again later."]
        let errorDict: NSMutableDictionary = NSMutableDictionary(dictionary: dict)
        
        guard let nsError = error as? NSError else{
            completion(false, errorDict, 0)
            return
        }
        completion(false, errorDict, nsError.code)
    }else{
        var statusCode = 0 // Replace a default value as your requirement.
         if let httpResponse = response as? HTTPURLResponse{
            statusCode = httpResponse.statusCode
            }
        print("Status Code:  \(statusCode)")
         if let responsData = data {
            //let json = try? JSONSerialization.jsonObject(with: data, options: [])
            let json : JSON = JSON(data: responsData)
            if let dataDict = json.dictionaryObject{
                // I have converted the data to NSMutableURLRequest to satisfy my requirement (I know I'll get a Dictionary always), you can change it as per yours.
                let dictMutable: NSMutableDictionary = NSMutableDictionary(dictionary: dataDict)
                    if  200...299 ~= statusCode {
                      completion(true, dictMutable, statusCode)
                    }
                    else{
                       completion(false, dictMutable, statusCode)
                    }
            }
            else{
                print("Response Data: \(json)")
                print("JSON Data is not in dictionary format.")
            }
        }
         else{
            print("Data: \(data)")
        }
    }
}
    task.resume()
}

func urlRequestWith(path: String, params: Dictionary<String, AnyObject>? = nil, authorize: Bool) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(url: NSURL(string: kBaseAddress+path)! as URL)
    request.addValue("application/json",forHTTPHeaderField: "Content-Type")
    request.addValue("application/json",forHTTPHeaderField: "Accept")
    
    if authorize {
        guard let userDict =  UserDefaults.standard.object(forKey: kUserDetailsKey) as? NSDictionary else{
            print("Needs authorization, but no saved user_details found")
            return request
        }
        guard let authToken = userDict.object(forKey: kAuthTokenKey) as? String else{
            print("Needs authorization, but no saved auth_token found in userdefault")
            return request
        }
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
    }
    
    guard let dict = params else {
        print(" -------Sendind Request with------- \nBody: \(params)\nURL: \(request.url) \nAuth_token: \(request.value(forHTTPHeaderField: "Authorization"))")
        print("Headers: \(request.allHTTPHeaderFields!)  ")
        return request
    }
    print("  -------Sendind Request with------- \nBody: \(dict)\nURL: \(request.url) \nAuth_token: \(request.value(forHTTPHeaderField: "Authorization"))")
    print("Headers: \(request.allHTTPHeaderFields!)  ")
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        request.httpBody =  jsonData
    }
    catch{
        
    }
    return request
}
