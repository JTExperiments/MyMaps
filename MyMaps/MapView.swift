//
//  MapView.swift
//  MyMaps
//
//  Created by James Tang on 16/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

protocol MapViewDelegate : class {
    func mapView(mapView: MapView, didTapPlace place: Place)
}

class MapView: UIView, Map {

    private var maps : [MapProvider:Map] = [:]
    var provider : MapProvider {
        return .Custom
    }
    var displaying : MapProvider = .Apple {
        didSet {
            self.bringSubviewToFront(self.maps[self.displaying]!)
        }
    }
    var view : MapView {
        return self
    }
    weak var delegate : MapViewDelegate?
    private (set) var places : [Place] = []
    private (set) var selectedPlace : Place? {
        didSet {
            if let place = selectedPlace {
                self.maps
                for (provider, map) in self.maps {
                    map.region = self.region
                }
                self.delegate?.mapView(self, didTapPlace: place)
            } else {
            }
        }
    }
    var region : MKCoordinateRegion {
        didSet {
            for (provider, map) in self.maps {
                map.region = self.region
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let googleMap = GoogleMapView(frame: self.bounds)
        googleMap.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        googleMap.myLocationEnabled = true
        self.addSubview(googleMap)
        googleMap.delegate = self
        self.maps[.Google] = googleMap

        let appleMap = AppleMapView(frame: self.bounds)
        appleMap.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        appleMap.showsUserLocation = true
        self.addSubview(appleMap)
        appleMap.delegate = self
        self.maps[.Apple] = appleMap
    }

    func removePlaces(places: [Place]) {
        self.maps
    }

    func addPlaces(places: [Place]) {
        self.places += places
        self.appleMapView.addPlaces(places)
        self.googleMapView.addPlaces(places)
    }

    func showPlaces(places: [Place]) {
        self.places += places
        self.appleMapView.showPlaces(places, animated: true)
        self.googleMapView.showPlaces(places, animated: true)
    }

}

extension MapView : MKMapViewDelegate {
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if self.displaying == .Apple {
            println("Apple: changed region")
            self.region = self.appleMapView.region
            self.googleMapView.region = region
        }
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        for place in self.places {
            if view.annotation.coordinate.longitude == place.coordinate.longitude
                && view.annotation.coordinate.latitude == place.coordinate.latitude
                && view.annotation.title == place.title {
                    self.selectedPlace = place
                    break
            }
        }
    }

    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        self.selectedPlace = nil
    }
}

extension MapView : GMSMapViewDelegate {

    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        for place in self.places {
            if marker.position.longitude == place.coordinate.longitude
                && marker.position.latitude == place.coordinate.latitude
                && marker.title == place.title
                && marker.snippet == place.subtitle {
                    self.selectedPlace = place
                    return false
            }
        }
        return false
    }

    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        println("GMS: idle position \(position)")
        if self.displaying == .Google {
            self.region = self.googleMapView.region
            self.appleMapView.region = region
        }
    }
}
