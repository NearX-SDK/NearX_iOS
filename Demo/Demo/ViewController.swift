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
        
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userKey: UITextView!
    @IBOutlet weak var submitBrn: UIButton!
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onUserSubmit(_ sender: Any) {
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Form Ready!")
        if(UserDefaults.standard.object(forKey: Constants.PreferencesKeys.AUTH_KEY) != nil)
        {
            userKey.text = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.AUTH_KEY)!
        }
        if(UserDefaults.standard.object(forKey: Constants.PreferencesKeys.NAME) != nil)
        {
            userName.text = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.NAME)!
        }
        if(UserDefaults.standard.object(forKey: Constants.PreferencesKeys.MOBILE_NUMBER) != nil)
        {
            userMobile.text = UserDefaults.standard.string(forKey: Constants.PreferencesKeys.MOBILE_NUMBER)!
        }
    }
    
    func startTracking(user : String , number : String , apiKey : String)
    {
        GeofenceUtils.setName(name: user)
        GeofenceUtils.setMobileNumber(mobileNumber: number)
        GeofenceUtils.setAuthKey(authKey: apiKey)
        
        geofence.initializeGeofences()
        showTrackingAlert()
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showTrackingAlert() {
        let alert = UIAlertController(title: "Success!", message: "Geofences monitoring initiated",preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}

