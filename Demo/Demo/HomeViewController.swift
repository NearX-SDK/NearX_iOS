//
//  HomeViewController.swift
//  Demo
//
//  Created by Kushagra on 23/02/20.
//  Copyright © 2020 First Walkin Technologies. All rights reserved.
//

import UIKit
import NearX

class HomeViewController : UIViewController, UITableViewDataSource , UITableViewDelegate {
    
    let geofence: Geofence = Geofence()
    var totalFenceData : [String] = []
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    @IBAction func showSettings(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Geofence List Ready!")
        if(UserDefaults.standard.object(forKey: Constants.PreferencesKeys.AUTH_KEY) != nil)
        {
            totalFenceData = geofence.displayGeofences() as [String]
            tableView.reloadData()
            
        }
        else
        {
            showRegisterAlert()
        }
        
        if(totalFenceData.count > 0)
        {
            headerTitle.text = "Available Geofences : "
        }
        else
        {
            headerTitle.text = "No Geofence available"
        }
    }
    
    
    @IBAction func registerClicked(_ sender: Any) {
        
        if(UserDefaults.standard.object(forKey: Constants.PreferencesKeys.AUTH_KEY) != nil)
        {
            geofence.initializeGeofences()
            totalFenceData = geofence.displayGeofences() as [String]
            tableView.reloadData()
        }
        else
        {
            showRegisterAlert()
        }
        
        let count = geofence.getFenceCount()
        headerTitle.text = "Events : \(count)"
        
//        if(totalFenceData.count > 0)
//        {
//            headerTitle.text = "Available Geofences : "
//        }
//        else
//        {
//            headerTitle.text = "No Geofence available"
//        }
    }
    
    func showRegisterAlert() {
        let alert = UIAlertController(title: "Register!", message: "You need to register first to see the Geofences.",         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: {(_: UIAlertAction!) in
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.present(nextViewController, animated:true, completion:nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalFenceData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GeofenceCell",for: indexPath) as! GeofenceCell
        cell.fenceName.text = totalFenceData[indexPath.row]
        return cell
    }
}
