//
//  GeofenceUtils.swift
//  NearX
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import Foundation

public class GeofenceUtils{
    
    
    public static let GEOFENCE_EXIT = "GEOFENCE_EXIT"
    public static let GEOFENCE_ENTRY = "GEOFENCE_ENTRY"
    
    // Add Provided credentials from user on UserDefaults
    
    public static func setName(name:String){
        UserDefaults.standard.set(name,forKey:Constants.PreferencesKeys.NAME)
    }
    
    public static func setMobileNumber(mobileNumber:String){
        UserDefaults.standard.set(mobileNumber,forKey:Constants.PreferencesKeys.MOBILE_NUMBER)
    }
    
    public static func setAuthKey(authKey:String){
        UserDefaults.standard.set(authKey,forKey:Constants.PreferencesKeys.AUTH_KEY)
    }
    
    public static func sendGeofenceEvent(eventType:String,locationName:String){
        
                print("")
                print(" ---  sendGeofenceEvent ---")
                print("")
                let authKey = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.AUTH_KEY)!
                let mobileNumber = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.MOBILE_NUMBER)!

                let eventData = [
                    "eventType":eventType,
                    "locationNames":[locationName],
                    "mobileNumber":mobileNumber
                ] as [String: Any]
        
                let payload = [
                    "authKey":authKey,
                    "eventData": eventData
                ] as! [String : String]


                let requestData = try! JSONSerialization.data(withJSONObject: payload, options: [])
                let session = URLSession.shared
                let url = URL(string: Constants.EVENT_URL)!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(authKey, forHTTPHeaderField: "token")
                
                let task = session.uploadTask(with: request , from: requestData) { data, response, error in

                    if error != nil || data == nil {
                        print("Client error!")
                        return
                    }

                    guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                        print("Server error!")
                        return
                    }

                    guard let mime = response.mimeType, mime == "application/json" else {
                        print("Wrong MIME type!")
                        return
                    }

                    do {
                        print("Geofence Event Success")
                        let responseData = try JSONSerialization.jsonObject(with: data!, options: [])
                        print("Event Response Data : ",responseData)
                    } catch {
                        print("JSON error: \(error.localizedDescription)")
                    }
                }

                task.resume()
    }
    
    
}

