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
    var favArray: [Favourites] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
}

extension TableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //cell.textLabel?.text = arr[indexPath.row].0
        return cell
    }
    
}

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
