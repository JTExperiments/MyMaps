//
//  MapViewController.swift
//  MyMaps
//
//  Created by James Tang on 16/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: RootViewController {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var places : [Place] = []

    var searching: Bool = false {
        didSet {
            self.reloadState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func reloadState() {
        if self.searching {
            self.loadingIndicator.startAnimating()
        } else {
            self.loadingIndicator.stopAnimating()
        }

        self.mapView.removeAnnotations(self.mapView.annotations)
        for place in self.places {
            self.mapView.addAnnotation(place)
        }

        self.tableView.reloadData()
    }

    func search() {
        let address = self.addressTextField.text

        let searchOperation = SearchPlacesOperation(address: address, region: self.mapView.region)
        NSOperationQueue.mainQueue().addOperation(searchOperation)

        self.searching = true
        searchOperation.completion = { response, error in
            if let response = response {
                self.places = response
            }
            self.searching = false
        }
    }

    @IBAction func searchButtonDidPress(sender: AnyObject) {
        self.search()
    }

}

extension MapViewController : UITextFieldDelegate {

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.search()
        return true
    }

}

extension MapViewController : UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let place = self.places[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! PlaceTableViewCell

        cell.name = place.title
        cell.address = place.subtitle

        return cell
    }
}