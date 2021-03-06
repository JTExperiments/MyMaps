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
import CoreLocation

protocol MapViewDelegate : class {
    func mapView(mapView: MapView, didTapPlace place: Place)
}

class MapView: UIView, Map {

    enum TrackingState {
        case Disabled
        case Tracking
        case Located
        case Zoomed
        case Detached
    }

    let locationManager = CLLocationManager()
    private var maps : [MapProvider:Map] = [:]
    var provider : MapProvider {
        return .Custom
    }
    var displaying : MapProvider = .Apple {
        didSet {
            self.bringSubviewToFront(self.maps[self.displaying]!.view)
        }
    }
    var view : UIView {
        return self
    }
    var enableUserLocation : Bool = false {
        didSet {
            for (_, map) in self.maps {
                map.enableUserLocation = self.enableUserLocation
            }

            if enableUserLocation {
                self.trackingState = .Tracking
            } else {
                self.trackingState = .Disabled
            }
        }
    }
    weak var delegate : MapViewDelegate?
    private (set) var places : [Place] = []
    private (set) var selectedPlace : Place? {
        didSet {
            if let place = selectedPlace {
                self.delegate?.mapView(self, didTapPlace: place)
            }
        }
    }
    var region : MKCoordinateRegion = MKCoordinateRegion() {
        didSet {
            for (provider, map) in self.maps {
                if provider != self.displaying {
                    map.setRegion(region, animated: false)
                }
            }
        }
    }
    private var trackingState : TrackingState = .Disabled
    func setRegion(region: MKCoordinateRegion, animated: Bool) {
        self.region = region
    }


    override func awakeFromNib() {
        super.awakeFromNib()

        let googleMap = GMSMapView(frame: self.bounds)
        googleMap.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(googleMap)
        googleMap.delegate = self
        self.maps[.Google] = googleMap

        let appleMap = MKMapView(frame: self.bounds)
        appleMap.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        self.addSubview(appleMap)
        appleMap.delegate = self
        self.maps[.Apple] = appleMap

        appleMap.userTrackingMode = .Follow
    }

    func removePlaces(places: [Place]) {
        for (_, map) in self.maps {
            map.removePlaces(places)
        }
    }

    func addPlaces(places: [Place]) {
        self.places += places
        for (_, map) in self.maps {
            map.addPlaces(places)
        }
    }

    func showPlaces(places: [Place], animated:Bool) {
        self.places += places
        for (_, map) in self.maps {
            map.showPlaces(places, animated: animated)
        }
    }

    func selectPlace(place: Place, animated: Bool) {
        self.selectedPlace = place
        for (_, map) in self.maps {
            map.selectPlace(place, animated: animated)
        }
    }

    func deselectPlace() {
        self.selectedPlace = nil
        for (_, map) in self.maps {
            map.deselectPlace()
        }
    }
}

extension MapView : MKMapViewDelegate {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.displaying == .Apple {
            print("Apple: changed region")
            self.region = mapView.region
        }

        if self.trackingState == .Located {
            self.trackingState = .Zoomed
        } else if self.trackingState == .Zoomed {
            self.trackingState = .Detached
        }
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        for place in self.places {
            if view.annotation!.coordinate.longitude == place.coordinate.longitude
                && view.annotation!.coordinate.latitude == place.coordinate.latitude
                && view.annotation!.title! == place.title {
                    self.selectPlace(place, animated: false)
                    break
            }
        }
    }

    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        self.deselectPlace()
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if self.trackingState == .Tracking {
            self.trackingState = .Located
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation.self) {
            return nil
        }

        let view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotation") ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")

//        view.canShowCallout = true
//        let addButton = UIButton(type: UIButtonType.ContactAdd)
//        addButton.frame = CGRectMake(0, 0, 44, 44)
//        view.rightCalloutAccessoryView = addButton

        return view
    }
//
//    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("accessoryControl tapped: \(control)")
//    }

}

extension MapView : GMSMapViewDelegate {

    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        for place in self.places {
            if marker.position.longitude == place.coordinate.longitude
                && marker.position.latitude == place.coordinate.latitude
                /* && marker.title == place.title
                && marker.snippet == place.subtitle */ {
                    self.selectPlace(place, animated: false)
                    return false
            }
        }
        return false
    }

    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.deselectPlace()
    }

    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        print("GMS: idle position \(position)")
        if self.displaying == .Google {
            self.region = mapView.region
        }
    }


}
