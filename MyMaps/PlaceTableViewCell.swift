//
//  PlaceTableViewCell.swift
//  MyMaps
//
//  Created by James Tang on 16/6/15.
//  Copyright (c) 2015 James Tang. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    var name : String? { didSet { self.reloadData() } }
    var address : String? { didSet { self.reloadData() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func reloadData() {
        self.textLabel?.text = self.name
        self.detailTextLabel?.text = self.address
    }

}
