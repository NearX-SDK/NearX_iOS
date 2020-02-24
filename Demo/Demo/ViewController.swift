//
//  ViewController.swift
//  Demo
//
//  Created by Kushagra on 05/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import UIKit
import NearX

class ViewController: UIViewController, UITextFieldDelegate , UITextViewDelegate {
    
    let geofence: Geofence = Geofence()
        
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userMobile: UITextField!
    @IBOutlet weak var userKey: UITextView!
    @IBOutlet weak var submitBrn: UIButton!
    @IBOutlet weak var userName: UITextField!
    
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
        
        userName.delegate = self
        userMobile.delegate = self
        userKey.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
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

