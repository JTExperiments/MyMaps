//
//  Map.swift
//  MyMaps
//
//  Created by James Tang on 20/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit
import MapKit

protocol Map : class {

    var region : MKCoordinateRegion { get }
    var provider : MapProvider { get }
    var view : UIView { get }
    var enableUserLocation : Bool { get set }

    func addPlaces(places: [Place])
    func removePlaces(places: [Place])
    func showPlaces(places: [Place], animated: Bool)

    func deselectPlace()
    func selectPlace(place: Place, animated: Bool)
    func setRegion(region: MKCoordinateRegion, animated: Bool)
}

