//
//  MKMapView+Map.swift
//  MyMaps
//
//  Created by James Tang on 20/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView : Map {
    var provider : MapProvider {
        return .Apple
    }
    var view : UIView {
        return self
    }
    var enableUserLocation : Bool {
        set {
            self.showsUserLocation = newValue
        }
        get {
            return self.showsUserLocation
        }
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
        self.selectAnnotation(place, animated: animated)
    }
    func deselectPlace() {
        for annotation in self.selectedAnnotations {
            self.deselectAnnotation(annotation, animated: false)
        }
    }
}