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
    @IBOutlet var listHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var segment: UISegmentedControl!

    var places : [Place] = []
    var selectedPlace : Place?
    var searching: Bool = false { didSet { self.reloadState() }}
    var showList: Bool = false { didSet { self.reloadState() }}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }

    func reloadState() {
        if self.searching {
            self.loadingIndicator.startAnimating()
        } else {
            self.loadingIndicator.stopAnimating()
        }

        self.mapView.removePlaces(self.mapView.places)
        self.mapView.showPlaces(self.places)

        self.listHeightConstraint.constant = self.showList ? self.view.frame.size.height / 2 : 0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })

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
        self.view.endEditing(true)
    }

    func toggleList() {
        self.showList = !self.showList
        self.reloadState()
        self.view.endEditing(true)
    }

    // MARK: Action
    @IBAction func listButtonDidPress(sender: AnyObject) {
        self.toggleList()
    }

    @IBAction func searchButtonDidPress(sender: AnyObject) {
        self.search()
    }

    @IBAction func segmentDidChange(sender: AnyObject) {
        if self.segment.selectedSegmentIndex == 0 {
            self.mapView.provider = .Apple
        } else {
            self.mapView.provider = .Google
        }
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
        cell.accessoryType = place == self.selectedPlace ? .Checkmark : .None

        return cell
    }
}

extension MapViewController : MapViewDelegate {

    func mapView(mapView: MapView, didTapPlace place: Place) {
        self.selectedPlace = place
        if let row = find(self.places, place) {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            self.tableView.reloadData()
        }

    }

}