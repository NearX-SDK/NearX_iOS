//
//  Constants.swift
//  NearX
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import Foundation

struct Constants {
    
    static let NEARX_URL = "https://dev-api.getwalkin.in/nearx/consumer/"
    
    static let GEOFENCE_URL = NEARX_URL + "s3001/api/configure/locations/sdk?"
    static let EVENT_URL = NEARX_URL + "s3010/api/nearx/processEvent"
    
    static let GEOFENCE_EXIT = "GEOFENCE_EXIT"
    static let GEOFENCE_ENTRY = "GEOFENCE_ENTRY"
    static let STORE_GEOFENCE_ENTRY = "STORE_GEOFENCE_ENTRY"
    static let STORE_GEOFENCE_EXIT = "STORE_GEOFENCE_EXIT"
    
    static let STORE_GEOFENCE_CONTAINS = "STORE"
    
    static let TIME_BETWEEN_LOC_UPDATE_MIN = 1
    
    struct PreferencesKeys {
        static let MOBILE_NUMBER = "NearXMOBILE_NUMBER"
        static let FCM_TOKEN = "NearXFCM_TOKEN"
        static let NAME = "NearXName"
        static let AUTH_KEY = "NearXAuthKey"
    }
    
}
