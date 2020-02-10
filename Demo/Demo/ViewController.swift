//
//  ViewController.swift
//  Demo
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import UIKit
import NearX

class ViewController: UIViewController {
    
    let geofence: Geofence = Geofence()
    
    // Provide your auth key
    let AUTH_KEY = "";
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userKey: UITextView!
    @IBOutlet weak var submitBrn: UIButton!
    
    @IBAction func onUserSubmit(_ sender: Any) {
        
        print("UserName : ",userName.text!)
        print("Mobile Number : ",userMobile.text!)
        print("Api Key : ",userKey.text! )
        
        if((userName.text!).isEmpty)
        {
            showAlert(withTitle: "Error", message: "Please provide your name!")
            return
        }
        if((userMobile.text!).isEmpty)
        {
            showAlert(withTitle: "Error", message: "Please provide mobile number!")
            return
        }
        if((userKey.text!).isEmpty)
        {
            showAlert(withTitle: "Error", message: "Please provide your api key!")
            return
        }
        
        startTracking(user: userName.text!, number: userMobile.text!, apiKey: userKey.text!)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Demo App ready!")
    }
    
    func startTracking(user : String , number : String , apiKey : String)
    {
        GeofenceUtils.setName(name: user)
        GeofenceUtils.setMobileNumber(mobileNumber: number)
//        GeofenceUtils.setFCMToken(fcmToken: token)
        GeofenceUtils.setAuthKey(authKey: apiKey)
        
        geofence.initializeGeofences()
        showAlert(withTitle: "Success!", message: "Geofences monitoring initiated")
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }


}

