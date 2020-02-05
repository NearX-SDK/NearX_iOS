//
//  GeofenceUtils.swift
//  NearX
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import Foundation
import Alamofire

public class GeofenceUtils{
    
    
    public static let GEOFENCE_EXIT = "GEOFENCE_EXIT"
    public static let GEOFENCE_ENTRY = "GEOFENCE_ENTRY"
    public static func setName(name:String){
        UserDefaults.standard.set(name,forKey:Constants.PreferencesKeys.NAME)
    }
    
    public static func setMobileNumber(mobileNumber:String){
        UserDefaults.standard.set(mobileNumber,forKey:Constants.PreferencesKeys.MOBILE_NUMBER)
    }
    
    public static func setFCMToken(fcmToken:String){
        UserDefaults.standard.set(fcmToken,forKey:Constants.PreferencesKeys.FCM_TOKEN)
    }
    
    public static func setAuthKey(authKey:String){
        UserDefaults.standard.set(authKey,forKey:Constants.PreferencesKeys.AUTH_KEY)
    }
    
    public static func sendGeofenceEvent(eventType:String,locationName:String){
        print("sendGeofenceEvent")
        let authKey = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.AUTH_KEY)!
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "token":authKey
        ]
        let mobileNumber = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.MOBILE_NUMBER)!
        
        let eventData = [
            "eventType":eventType,
            "locationNames":[locationName],
            "mobileNumber":mobileNumber
            ] as [String: Any]
        let data = [
            "authKey":authKey,
            "eventData": eventData
            ] as! [String : String]
        
        AF.request(Constants.EVENT_URL,method: .post,parameters:data,encoder: JSONParameterEncoder.default, headers:headers)
            .validate()
//            .debugLog()
            .responseJSON { response in
            switch response.result
            {
                case .success(let value):
                    print("Geofence Success : ",value)
                case .failure(let error):
                    print("Error while recieving data : ",error)
            }
        }
    }
    
    
}

