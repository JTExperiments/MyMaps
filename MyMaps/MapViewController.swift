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
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

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
    }

    func search() {
        let address = self.addressTextField.text

        let searchOperation = SearchPlacesOperation(address: address, region: self.mapView.region)
        NSOperationQueue.mainQueue().addOperation(searchOperation)

        self.searching = true
        searchOperation.completion = { response, error in
            if let response = response {
                for item in response.mapItems {
                    if let item = item as? MKMapItem {
                        self.mapView.addAnnotation(item.placemark)

                    }
                }
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