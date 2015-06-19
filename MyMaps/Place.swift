//
//  Place.swift
//  MyMaps
//
//  Created by James Tang on 16/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit
import MapKit

public class Place : NSObject, MKAnnotation {

    let mapItem: MKMapItem

    public var title : String? {
        get {
            return mapItem.name
        }
    }

    public var subtitle : String? {
        get {
            return mapItem.placemark.title
        }
    }

    public var coordinate : CLLocationCoordinate2D {
        get {
            return mapItem.placemark.coordinate
        }
    }

    public init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
}

public func ==(lhs: Place, rhs: Place) -> Bool {

    if lhs.title == rhs.title
        && lhs.subtitle == rhs.subtitle
        && lhs.coordinate.latitude == rhs.coordinate.latitude
        && lhs.coordinate.longitude == rhs.coordinate.longitude {
            return true
    }
    return false
}