//
//  GMSMapView+Map.swift
//  MyMaps
//
//  Created by James Tang on 20/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import Foundation
import GoogleMaps
import MapKit

final class GoogleMapView : GMSMapView, Map {

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
    var provider : MapProvider {
        return .Google
    }
    var view : GoogleMapView {
        return self
    }

    func addPlaces(places: [Place]) {
        for place in places {
            let marker = self.marker(place)
            marker.map = self
        }
    }

    func removePlaces(places: [Place]) {
        self.clear()
    }

    func showPlaces(places: [Place], animated: Bool) {
        var bounds = GMSCoordinateBounds()
        self.addPlaces(places)
        for place in places {
            bounds = bounds.includingCoordinate(place.coordinate)
        }
        let update = GMSCameraUpdate.fitBounds(bounds)
        self.moveCamera(update)
    }

    func selectPlace(place: Place, animated: Bool) {
        let marker = self.marker(place)
        marker.map = self
        self.selectedMarker = marker
    }

    // MARK: Helper

    func marker(annotation: MKAnnotation) -> GMSMarker {
        let marker = GMSMarker(position: annotation.coordinate)
        marker.title = annotation.title
        marker.snippet = annotation.subtitle
        return marker
    }
}