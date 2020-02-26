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
    private var totalFences : Int = 0
    
    private func addFenceCount()
    {
        totalFences = totalFences + 1
    }
    
    public func getFenceCount() -> Int
    {
        let count = totalFences
        return count
    }
    
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
    }
    
    public func displayGeofences() -> [String]
    {
        var totalFences : [String] = []
        for monitoredGeofence in locationManager.monitoredRegions {
            totalFences.append(monitoredGeofence.identifier)
        }
        return totalFences
    }
    
    func getGeofencesAndRegister(coord : CLLocationCoordinate2D){
        let location = [
            "latitude": "\(coord.latitude)",
            "longitude": "\(coord.longitude)"
        ]
        let authKey = UserDefaults.standard.string(forKey: Cred.PreferencesKeys.AUTH_KEY)!
        let getgeofenceURL = Cred.GEOFENCE_URL +
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
        calculateAndRemoveGeofences(geofences)
        calculateAndAddGeofences(geofences)
    }
    
    
    //Remove all geofences that are present in monitoredRegions and not present in new regions(got from API)
    func calculateAndRemoveGeofences(_ geofences: [locationData]){
        print(" ---  Unlisted Geofences Removed  ---")
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
        print(" ---  Calculate And Add Newly Listed Geofences ---")
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
        addFenceCount()
        GeofenceUtils.sendGeofenceEvent(eventType: event, locationName: region.identifier)
    }
    
    // Format data for adding Geofence found while monitoring
    func addGeofence(data: locationData){
        
        let lat = CLLocationDegrees(data.latitude)
        let long = CLLocationDegrees(data.longitude)
        let radius = data.radius
        let geofenceId = data.canonicalName
        
        print("Adding GeoFence : ", data.canonicalName)
        setGeofence(latitude: lat , longitude: long, radius: radius, id: geofenceId)
    }
    
    // Add Geofence in the region
    func setGeofence(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: Int, id: String) {
        print(" ---  setGeofence ---")
        let geoRegion:CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: CLLocationDistance(radius), identifier: id)
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
        print("Location: \(objLocation.coordinate.latitude)  |  \(objLocation.coordinate.longitude)")
        getGeofencesAndRegister(coord : objLocation.coordinate)
    }
    
    // Deferred Location error
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print("Location error: \(error!)")
    }
    
    // called when user Exits a monitored region
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
           if region is CLCircularRegion {
               self.handleEvent(forRegion: region , event: "GEOFENCE_EXIT")
           }
       }
       
       // called when user Enters a monitored region
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
           if region is CLCircularRegion {
            self.handleEvent(forRegion: region , event: "GEOFENCE_ENTRY")
           }
       }
    
}
