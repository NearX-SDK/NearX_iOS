//
//  Cred.swift
//  NearX
//
//  Created by Kushagra on 26/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//


import Foundation

struct Cred {
    
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

// Struct to easily encode/decode locationData being recieved via api call

struct locationData : Codable {
        
        let id : String
        let canonicalName : String
        let latitude : Double
        let longitude : Double
        let radius : Int
        let locationName : String
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case canonicalName = "canonicalName"
            case latitude = "latitude"
            case longitude = "longitude"
            case radius = "radius"
            case locationName = "locationName"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.canonicalName = try container.decode(String.self, forKey: .canonicalName)
            self.latitude = try container.decode(Double.self, forKey: .latitude)
            self.longitude = try container.decode(Double.self, forKey: .longitude)
            self.radius = try container.decode(Int.self, forKey: .radius)
            self.locationName = try container.decode(String.self, forKey: .locationName)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.canonicalName, forKey: .canonicalName)
            try container.encode(self.latitude, forKey: .latitude)
            try container.encode(self.longitude, forKey: .longitude)
            try container.encode(self.radius, forKey: .radius)
            try container.encode(self.locationName, forKey: .locationName)
        }
    }

//    Struct to easily encode/decode api response for geofence data
    
    struct Response: Codable {
        
        let totalGeofences: Int
        let locations: [locationData]
        
        enum CodingKeys: String, CodingKey {
            case response = "Response"
            case totalGeofences = "totalGeofences"
            case locations = "locations"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
            self.totalGeofences = try container.decode(Int.self, forKey: .totalGeofences)
            self.locations = try container.decode([locationData].self, forKey: .locations)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
//            var response = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
            try container.encode(self.totalGeofences, forKey: .totalGeofences)
            try container.encode(self.locations, forKey: .locations)
        }
    }

    struct EventData: Codable {
        
        let eventType: String
        let locationNames: [String]
        let mobileNumber : String
        
        enum CodingKeys: String, CodingKey {
            case eventType = "eventType"
            case locationNames = "locationNames"
            case mobileNumber = "mobileNumber"
        }
    }

    struct Payload : Codable {
        let authKey: String
        var eventData: EventData
        
//        enum CodingKeys: String, CodingKey {
//            case authKey = "authKey"
//            case eventData = "eventData"
//        }
    }
