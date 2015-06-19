//
//  Map.swift
//  MyMaps
//
//  Created by James Tang on 20/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import Foundation
import MapKit

protocol Map : class {

    var region : MKCoordinateRegion { get set }
    var provider : MapProvider { get }
    var view : UIView { get }

    func addPlaces(places: [Place])
    func removePlaces(places: [Place])
    func showPlaces(places: [Place], animated: Bool)

    func selectPlace(place: Place, animated: Bool)

}

