//
//  MKMapView+Map.swift
//  MyMaps
//
//  Created by James Tang on 20/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import Foundation
import MapKit

final class AppleMapView : MKMapView, Map {
    var provider : MapProvider {
        return .Apple
    }
    var view : AppleMapView {
        return self
    }

    func addPlaces(places: [Place]) {
        self.addAnnotations(places)
    }

    func removePlaces(places: [Place]) {
        self.removeAnnotations(places)
    }

    func showPlaces(places: [Place], animated: Bool) {
        self.showAnnotations(places, animated: animated)
    }

    func selectPlace(place: Place, animated: Bool) {
        self.selectPlace(place, animated: animated)
    }
}