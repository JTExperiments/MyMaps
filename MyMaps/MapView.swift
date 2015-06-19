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

class MapView: UIView {

    enum Provider {
        case Apple
        case Google
    }

    private var appleMapView : MKMapView!
    private var googleMapView : GMSMapView!
    var provider : Provider = .Apple {
        didSet {
            switch (self.provider) {
            case .Google:
                self.bringSubviewToFront(self.googleMapView)
            default:
                self.bringSubviewToFront(self.appleMapView)
            }
        }
    }
    weak var delegate : MapViewDelegate?
    private (set) var places : [Place] = []
    var region : MKCoordinateRegion!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.googleMapView = GMSMapView(frame: self.bounds)
        self.googleMapView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.googleMapView.myLocationEnabled = true
        self.addSubview(googleMapView)
        self.googleMapView.delegate = self

        self.appleMapView = MKMapView(frame: self.bounds)
        self.appleMapView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.appleMapView.showsUserLocation = true
        self.addSubview(appleMapView)
        self.appleMapView.delegate = self
    }

    func removePlaces(places: [Place]) {
        self.appleMapView.removeAnnotations(places)
        self.googleMapView.removeAnnotations()
    }

    func addPlaces(places: [Place]) {
        self.places += places
        self.appleMapView.addAnnotations(places)
        self.googleMapView.addAnnotations(places)
    }
    func showPlaces(places: [Place]) {
        self.places += places
        self.appleMapView.showAnnotations(places, animated: true)
        self.googleMapView.addAnnotations(places)
    }

}

extension MapView : MKMapViewDelegate {
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        println("Apple: changed region")
        if self.provider == .Apple {
            self.region = self.appleMapView.region
            self.googleMapView.region = region
        }
    }


    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        for place in self.places {
            if view.annotation.coordinate.longitude == place.coordinate.longitude
                && view.annotation.coordinate.latitude == place.coordinate.latitude
                && view.annotation.title == place.title {
                    self.delegate?.mapView(self, didTapPlace: place)
                    break
            }
        }
    }

}

extension MapView : GMSMapViewDelegate {

    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        for place in self.places {
            if marker.position.longitude == place.coordinate.longitude
                && marker.position.latitude == place.coordinate.latitude
                && marker.title == place.title
                && marker.snippet == place.subtitle {
                    self.delegate?.mapView(self, didTapPlace: place)
                    return false
            }
        }
        return false
    }

    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        println("GMS: idle position \(position)")
        if self.provider == .Google {
            self.region = self.googleMapView.region
            self.appleMapView.region = region
        }
    }
}

extension GMSMapView {

    // stackoverflow http://stackoverflow.com/a/30938225/1013897
    var region : MKCoordinateRegion {
        get {
            let position = self.camera
            let visibleRegion = self.projection.visibleRegion()
            let bounds = GMSCoordinateBounds(region: visibleRegion)
            let latitudeDelta = bounds.northEast.latitude - bounds.southWest.latitude
            let longitudeDelta = bounds.northEast.longitude - bounds.southWest.longitude
            let center = CLLocationCoordinate2DMake(
                (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
                (bounds.southWest.longitude + bounds.northEast.longitude) / 2)
            let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
            return MKCoordinateRegionMake(center, span)
        }
        set {
            let northEast = CLLocationCoordinate2DMake(newValue.center.latitude - newValue.span.latitudeDelta/2, newValue.center.longitude - newValue.span.longitudeDelta/2)
            let southWest = CLLocationCoordinate2DMake(newValue.center.latitude + newValue.span.latitudeDelta/2, newValue.center.longitude + newValue.span.longitudeDelta/2)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let update = GMSCameraUpdate.fitBounds(bounds, withPadding: 0)
            self.moveCamera(update)
        }
    }

    func addAnnotations(annotations: [MKAnnotation]) {
        for annotation in annotations {
            let marker = GMSMarker(position: annotation.coordinate)
            marker.title = annotation.title
            marker.snippet = annotation.subtitle
            marker.map = self
        }
    }

    func removeAnnotations() {
        self.clear()
    }
}
