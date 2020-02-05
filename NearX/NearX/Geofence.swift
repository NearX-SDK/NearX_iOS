//
//  Geofence.swift
//  NearX
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

public class Geofence:NSObject,CLLocationManagerDelegate{
    
    private var locationManager =  CLLocationManager()
    
    
    public func initializeGeofences(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
        
        let name = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.NAME)!
        let mobileNumber = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.MOBILE_NUMBER)!
        let fcmToken = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.FCM_TOKEN)!
        
        print("Allows background location updates")
        
        print("initializeGeofences")
        print("name")
        print(name)
        print("mobile")
        print(mobileNumber)
        print("FCM")
        print(fcmToken)
        
    }
    
    
    func getGeofencesAndRegister(latitude:String,longitude:String){
        let location = ["latitude": latitude,
                        "longitude": longitude]
        
        let authKey = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.AUTH_KEY)!
        let headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "token": authKey
        ]
        
        let getgeofenceURL = Constants.GEOFENCE_URL +
            "latitude=\(location["latitude"]!)&longitude=\(location["longitude"]!)&within=1000000&limit=20"
        
        AF.request(getgeofenceURL, method: .get, headers:headers)
            .validate()
//            .debugLog()
            
            .responseJSON { response in
                switch response.result
                {
                    case .success(let value):
                        let jsonResponse = JSON(value)
                        self.onCompleteGetGeofences(value: jsonResponse)
                    case .failure(let error):
                        print(error)
                }
//                print(response)
//                guard response.result.isSuccess else {
//                    print(response)
//                    print("Error while receiving data")
//                    return
//                }
                
//                let value = response.result.value
//                let jsonResponse = JSON(value!)
//                self.onCompleteGetGeofences(value: jsonResponse)
                
                
        }
        

//        AF.request("\(url)\(path)").responseData {
//            response in switch response.result { case .success(let value): print(String(data: value, encoding: .utf8)!) completion(try? SomeRequest(protobuf: value)) case .failure(let error): print(error) completion(nil) }
//
//        }
    }
    
    func onCompleteGetGeofences(value:JSON){
        print("onCompleteGetGeofences")
        let locations = value["locations"]
        self.setGeofenceValues(locations)
    }
    
    
    
    //Remove all geofences that are present in monitoredRegions and not present in new regions(got from API)
    func calculateAndRemoveGeofences(_ geofences: JSON){
        print("getGeofencesToBeRemoved")
        var found = false;
        for monitoredGeofence in locationManager.monitoredRegions {
            found = false;
            for (_, newGeofence) in geofences {
                if (monitoredGeofence.identifier == newGeofence["canonicalName"].stringValue){
                    found = true
                }
            }
            if(!found){
                //That means that geofence exists in monitored and not in new regions
                //We should remove it
                print("Removing ---", monitoredGeofence.identifier)
                locationManager.stopMonitoring(for: monitoredGeofence)
            }
        }
    }
    
    //Add all geofences that are present in new regions(got from API) and not already present in monitored regions
    func calculateAndAddGeofences(_ geofences: JSON){
        print("calculateAndAddGeofences")
        var found = false;
        for (_, newGeofence) in geofences {
            found = false;
            for monitoredGeofence in locationManager.monitoredRegions {
                if(newGeofence["canonicalName"].stringValue == monitoredGeofence.identifier){
                    found = true
                }
            }
            if(!found){
                //That means that geofences exist in JSON and not in monitored
                //We should all these geofences
                addGeofence(data: newGeofence)
            }
        }
    }
    
    func addGeofence(data: JSON){
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal;
        
        let lat = formatter.number(from:data["latitude"].stringValue)!
        let long = formatter.number(from:data["longitude"].stringValue)!
        let radius = Int(data["radius"].stringValue)!
        let geofenceId = data["canonicalName"].stringValue
        print("Adding ---", data["canonicalName"].stringValue)
        setGeofence(latitude: lat.floatValue , longitude: long.floatValue, radius: radius, id: geofenceId)
    }
    
    func setGeofenceValues(_ geofences: JSON) {
        print("setGeofenceValues")
        calculateAndRemoveGeofences(geofences)
        calculateAndAddGeofences(geofences)
    }
    
    func setGeofence(latitude: Float, longitude: Float, radius: Int, id: String) {
        print("setGeofence")
        print("Setting geofence " + id)
        let geoRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), radius: CLLocationDistance(radius), identifier: id)
        geoRegion.notifyOnExit = true
        geoRegion.notifyOnEntry = true
        locationManager.startMonitoring(for: geoRegion)
    }
    
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier) \(error)")
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if #available(iOS 9.0, *) {
                locationManager.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
            locationManager.startUpdatingLocation()
        case .denied:
            
            print("Location error: Permission not given")
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error didFailWithError: \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let objLocation = locations[0]
        print("Location: \(objLocation)")
        getGeofencesAndRegister(latitude: "\(objLocation.coordinate.latitude)", longitude: "\(objLocation.coordinate.longitude)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Location error: \(error!)")
    }
    
    
}


extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint(self)
        #endif
        return self
    }
}
