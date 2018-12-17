//
//  TableViewController.swift
//  TerrainAR
//
//  Created by Jeremy Raven on 2/12/18.
//  Copyright © 2018 Jeremy Raven. All rights reserved.
//

import UIKit
import CoreLocation

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var favouritesDictionary = [String: Array<Any>]()
    var testDict = [Int: String]()
    var favCoordinatesArray: [CLLocationCoordinate2D]? = []
    var arr : [(String, Array<Any>)] = [];
    
//    minLat = favCoordinatesArray![0].latitude
//    minLong = favCoordinatesArray![0].longitude
//
//    maxLat = favCoordinatesArray![1].latitude
//    maxLong = favCoordinatesArray![1].longitude
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        getDictionary(key: "favouritesDictionary")
        
        
        favouritesDictionary = ["Ruapehu": favCoordinatesArray, "Auckland": favCoordinatesArray] as! [String : Array<Any>]
        
        for (key, value) in favouritesDictionary {
            arr.append((key, value));
        }

        //print("These are the coords ", arr[0].1)

    }
    
    func getDictionary(key: String) -> Dictionary<Int, String> {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: key) != nil{
            let decoded = preferences.object(forKey: key)  as! Data
            let testDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! Dictionary<Int, String>

            return testDict
        } else {
            let emptyDict = Dictionary<Int, String>()
            return emptyDict
        }
    }
    //
    //    }
    //
    //    func saveDictionary(dict: Dictionary<Int, String>, key: String){
    //        let preferences = UserDefaults.standard
    //        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: dict)
    //        preferences.set(encodedData, forKey: key)
    //        // Checking the preference is saved or not
    //        didSave(preferences: preferences)
    //    }
    //

}

extension TableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arr[indexPath.row].0
        return cell
    }
    
}

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
