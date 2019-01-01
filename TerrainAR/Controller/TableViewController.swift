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

    var favCoordinatesArray: [CLLocationCoordinate2D]? = []
    var favouritesArray: [Favourites] = []
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("favourites.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFavourites()
    }
    
    @IBAction func addFavourites(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add to Favourites", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (addAction) in
            
            let newFavourite = Favourites(title: textField.text!,
                                    latitude1: self.favCoordinatesArray![0].latitude,
                                    longitude1: self.favCoordinatesArray![0].longitude,
                                    latitude2: self.favCoordinatesArray![1].latitude,
                                    longitude2: self.favCoordinatesArray![1].longitude,
                                    isSelected: false)
            
            self.favouritesArray.append(newFavourite)
            self.saveFavourites()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Place Name"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
