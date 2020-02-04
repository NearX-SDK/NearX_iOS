//
//  GeodenceUtils.swift
//  NearX_iOS
//
//  Created by Kushagra on 04/02/20.
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
        let headers = [
            "Content-Type": "application/json",
            "token":authKey
        ]
        let mobileNumber = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.MOBILE_NUMBER)!
        
        let eventData = [
            "eventType":eventType,
            "locationNames":[locationName],
            "mobileNumber":mobileNumber,
            ] as [String: Any]
        let data = [
            "authKey":authKey,
            "eventData": eventData
            ] as [String : Any]
        Alamofire.request(Constants.EVENT_URL, method:.post,
                          parameters:data,encoding:JSONEncoding.default, headers:headers)
            .validate()
            .debugLog()
            .responseJSON { response in
                print(response)
                guard response.result.isSuccess else {
                    print(response)
                    print("Error while receiving data")
                    return
                }
        }
    }
    
    
}

