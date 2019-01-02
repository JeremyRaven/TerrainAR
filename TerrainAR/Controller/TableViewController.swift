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
    @IBOutlet weak var removeSet: UILabel!
    
    var favCoordinatesArray: [CLLocationCoordinate2D]  = [CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)]
    var favouritesArray: [Favourites] = []
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("favourites.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.isEditing = false
        removeSet.text = "Remove"
        removeSet.textAlignment = .center
        
        loadFavourites()
    }
    
    @IBAction func editTableRows(_ sender: UIButton) {
        
        tableView.isEditing = !tableView.isEditing
        
        if tableView.isEditing {
            removeSet.text = "Return"
            removeSet.textAlignment = .center
        }else{
            removeSet.text = "Remove"
            removeSet.textAlignment = .center
        }
    }
    
    @IBAction func addFavourites(_ sender: UIButton) {
        
        // Make sure favCoordinatesArray is not empty
        if favCoordinatesArray[0].latitude == 0.0 {
            
            // Create alert if favCoordinatesArray < 2
            let alertVC = UIAlertController(title: "Wait", message: "You cannot add a new favourite without coordinates", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            
        } else {
            
            var textField = UITextField()
            
            let alert = UIAlertController(title: "Add to Favourites", message: "", preferredStyle: .alert)
            let addAction = UIAlertAction(title: "Add", style: .default) { (addAction) in
                
                let newFavourite = Favourites(title: textField.text!,
                                        latitude1: self.favCoordinatesArray[0].latitude,
                                        longitude1: self.favCoordinatesArray[0].longitude,
                                        latitude2: self.favCoordinatesArray[1].latitude,
                                        longitude2: self.favCoordinatesArray[1].longitude)
                
                self.favouritesArray.append(newFavourite)
                self.saveFavourites()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Place name"
                textField = alertTextField
            }
            
            alert.addAction(addAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveFavourites() {
        
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.favouritesArray)
            try data.write(to: self.dataFilePath!)
            } catch {
            print("Error encoding favourites array, \(error)")
            }
        self.tableView.reloadData()
    }
    
    func loadFavourites() {
        
        if let data = try? Data(contentsOf: self.dataFilePath!) {
            let decoder = PropertyListDecoder()
        do {
            favouritesArray = try decoder.decode([Favourites].self, from: data)
            } catch {
            print("Error decoding favourites array, \(error)")
            }
        }
    }
    
    //MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check View Controller desination
        if segue.destination is ARViewController {
            
            if favCoordinatesArray[0].latitude == 0.0 {
                
                let alertVC = UIAlertController(title: "Wait", message: "Please select a favourite", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
                
            } else {
                
                // Otherwise pass favCoordinatesArray to
                let vcAR = segue.destination as? ARViewController
                // Double check array is not empty
                if favCoordinatesArray[0].latitude != 0.0 {
                    vcAR?.ARcoordinatesArray = favCoordinatesArray
                } else {return}
            }
        }
    }
}

extension TableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouritesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = favouritesArray[indexPath.row].title
        return cell
    }
}

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let lat1 = favouritesArray[indexPath.row].latitude1
        let lat2 = favouritesArray[indexPath.row].latitude2
        let long1 = favouritesArray[indexPath.row].longitude1
        let long2 = favouritesArray[indexPath.row].longitude2
        
        favCoordinatesArray[0].latitude = lat1
        favCoordinatesArray[0].longitude = long1
        favCoordinatesArray[1].latitude = lat2
        favCoordinatesArray[1].longitude = long2
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            favouritesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
        }
        
        self.saveFavourites()
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }

}
