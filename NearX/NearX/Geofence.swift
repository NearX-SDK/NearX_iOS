//
//  Geofence.swift
//  NearX
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import UIKit
import CoreLocation

public class Geofence:NSObject,CLLocationManagerDelegate{
    
    private var locationManager =  CLLocationManager()
    
    
    public func initializeGeofences(){
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
//        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                        print("No Location access provided")
                        locationManager.requestAlwaysAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                        print("Access")
                default:
                        print("")
            }
        } else {
            print("Location services are not enabled")
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        let name = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.NAME)!
        let mobileNumber = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.MOBILE_NUMBER)!
        
        print("Data Recieved by SDK.")
        print("Name : \(name) | Mobile Number : \(mobileNumber)")
        
    }
    
    public func displayGeofences() -> [String]
    {
        var totalFences : [String] = []
        print("")
        print("----------- GEOFENCES -----------")
        print("")
        for monitoredGeofence in locationManager.monitoredRegions {
            
            print(monitoredGeofence.identifier)
            totalFences.append(monitoredGeofence.identifier)
            
        }
        print("")
        print("---------------------------------")
        return totalFences
    }
    
    func getGeofencesAndRegister(latitude:String,longitude:String){
        let location = [
            "latitude": latitude,
            "longitude": longitude
        ]
        let authKey = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.AUTH_KEY)!
        let getgeofenceURL = Constants.GEOFENCE_URL +
            "latitude=\(location["latitude"]!)&longitude=\(location["longitude"]!)&within=1000000&limit=20"
        
        let session = URLSession.shared
        let url = URL(string: getgeofenceURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authKey, forHTTPHeaderField: "token")
        
        let task = session.dataTask(with: request) { data, response, error in

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
//                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                let decodedResponse = try JSONDecoder().decode(Response.self, from: data!)
                self.setGeofenceValues(decodedResponse.locations)
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    
    func setGeofenceValues(_ geofences: [locationData]) {
        print("")
        print(" ---  setGeofenceValues ---")
        print("")
        calculateAndRemoveGeofences(geofences)
        calculateAndAddGeofences(geofences)
    }
    
    
    //Remove all geofences that are present in monitoredRegions and not present in new regions(got from API)
    func calculateAndRemoveGeofences(_ geofences: [locationData]){
        print("")
        print(" ---  getGeofencesToBeRemoved ---")
        print("")
        var found = false;
        for monitoredGeofence in locationManager.monitoredRegions {
            found = false;
            for newGeoFence in geofences {
                if (monitoredGeofence.identifier == newGeoFence.canonicalName){
                    found = true
                }
            }
            if(!found){
                //That means that geofence exists in monitored and not in new regions
                //We should remove it
                print("Removing : ", monitoredGeofence.identifier)
                locationManager.stopMonitoring(for: monitoredGeofence)
            }
        }
    }
    
    //Add all geofences that are present in new regions(got from API) and not already present in monitored regions
    func calculateAndAddGeofences(_ geofences: [locationData]){
        print("")
        print(" ---  calculateAndAddGeofences ---")
        print("")
        var found = false;
        for newGeofence in geofences {
            found = false;
            for monitoredGeofence in locationManager.monitoredRegions {
                if(newGeofence.canonicalName == monitoredGeofence.identifier){
                    found = true
                }
            }
            if(!found){
                //That means that geofences exist in JSON and not in monitored
                //We should add this geofence
                addGeofence(data: newGeofence)
            }
        }
    }
    
    // Handling geofence entry/exit events
    func handleEvent(forRegion region: CLRegion! , event : String) {
        
        print("")
        print(" ---  Geofence Tracked ---")
        print("")
        print("Geofence Tracked on \(event) : ",region!)
        print("")
        GeofenceUtils.sendGeofenceEvent(eventType: event, locationName: region.identifier)
    }
    
    // Format data for adding Geofence found while monitoring
    func addGeofence(data: locationData){
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal;
        
        let lat = formatter.number(from:String(format:"%.1f",data.latitude))!
        let long = formatter.number(from:String(format:"%.1f",data.longitude))!
        let radius = data.radius
        let geofenceId = data.canonicalName
        
        print("Adding GeoFence : ", data.canonicalName)
        setGeofence(latitude: lat.floatValue , longitude: long.floatValue, radius: radius, id: geofenceId)
    }
    
    // Add Geofence in the region
    func setGeofence(latitude: Float, longitude: Float, radius: Int, id: String) {
        print("")
        print(" ---  setGeofence ---")
        print("")
        print("Setting geofence " + id)
        print("")
        let geoRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), radius: CLLocationDistance(radius), identifier: id)
        geoRegion.notifyOnExit = true
        geoRegion.notifyOnEntry = true
        locationManager.startMonitoring(for: geoRegion)
    }
    
    
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("")
        print("Monitoring failed for region with identifier: \(region!.identifier) \(error)")
        print("")
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
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error didFailWithError: \(error)")
    }
    
    
    // Provides all incoming location data from device sensors
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let objLocation = locations[0]
        print("Location: \(objLocation)")
        getGeofencesAndRegister(latitude: "\(objLocation.coordinate.latitude)", longitude: "\(objLocation.coordinate.longitude)")
    }
    
    // Deferred Location error
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Location error: \(error!)")
    }
    
    // called when user Exits a monitored region
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
           if region is CLCircularRegion {
               self.handleEvent(forRegion: region , event: "geofenceExit")
           }
       }
       
       // called when user Enters a monitored region
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
           if region is CLCircularRegion {
            self.handleEvent(forRegion: region , event: "geofenceEntry")
           }
       }
    
}
