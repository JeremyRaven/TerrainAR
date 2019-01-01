//
//  FavouritesStruct.swift
//  TerrainAR
//
//  Created by Jeremy Raven on 1/01/19.
//  Copyright © 2019 Jeremy Raven. All rights reserved.
//

import Foundation
import CoreLocation

struct Favourites: Codable {
    
    var title: String
    var latitude1: Double
    var longitude1: Double
    var latitude2: Double
    var longitude2: Double
    var isSelected: Bool = false
    
    init(title: String, latitude1: Double, longitude1: Double, latitude2: Double, longitude2: Double, isSelected: Bool) {
        self.title = title
        self.latitude1 = latitude1
        self.longitude1 = longitude1
        self.latitude2 = latitude2
        self.longitude2 = longitude2
        self.isSelected = isSelected
    }
}
